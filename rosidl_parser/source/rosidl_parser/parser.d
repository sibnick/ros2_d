module rosidl_parser.parser;

import rosidl_parser.definition;
import rosidl_parser.util;
import pegged.grammar;
import std.algorithm.comparison;
import std.algorithm;
import std.typecons;
import std.conv;
import std.array;
import std.stdio : writeln;

mixin(grammar(import("rosidl.peg")));
mixin peggedHelper!"ROSIDL";

struct ParsedData
{
    Message[string] messages;
    Include[] includes;
    AbstractType[AbstractType] typedefMap;
}

class Parser
{
    string[] namespaces;
    ParsedData data;

    void parse(in ParseTree p)
    {
        treeMatch(p.getFirst, "Specification", &parseSpecification);
    }

private:
    void parseIncludeDirective(in ParseTree p)
    {
        data.includes ~= Include(p.matches[1 .. $].join());
    }

    // (1)
    void parseSpecification(in ParseTree p)
    {
        foreach (c; p.children)
        {
            treeMatch(c,
                "Definition", &parseDefinition,
                "IncludeDirective", &parseIncludeDirective,
            );
        }
    }

    // (2)
    void parseDefinition(in ParseTree p)
    {
        treeMatch(p.getFirst,
            "ModuleDcl", &parseModuleDcl,
            "ConstDcl", &parseConstDcl,
            "TypeDcl", &parseTypeDcl,
        );
    }

    // (3)
    void parseModuleDcl(in ParseTree p)
    {
        namespaces ~= p.getAt("Identifier").getData;
        p.getAll("Definition").each!(d => parseDefinition(d));
        namespaces.length--;
    }

    // (4)
    AbstractType getScopedName(in ParseTree p)
    {
        const identifier = p.getAt("Identifier").getData;
        if (p.has("ScopedName"))
        {
            return new NamespacedType(p.getAt("ScopedName").getData.split("::"), identifier);
        }
        else
        {
            return new NamedType(identifier);
        }
    }

    // (5)
    void parseConstDcl(in ParseTree p)
    {
        auto type = getConstType(p.getAt("ConstType"));
        const identifier = p.getAt("Identifier").getData;
        const expr = p.getAt("ConstExpr").getData;

        const currentNamespace = namespaces.join("::");
        assert(currentNamespace.endsWith(constantModuleSuffix));

        const target = currentNamespace[0 .. $ - constantModuleSuffix.length];
        data.messages.require(target, new Message()).constants ~= Constant(type, identifier, expr);
    }

    // (6)
    AbstractType getConstType(in ParseTree p)
    {
        return treeMatch(p.getFirst,
            "ScopedName", &getScopedName,
            "StringType", &getStringType,
            "WideStringType", &getWideStringType,
            "FixedPtConstType", &getFixedPtConstType,
            (in ParseTree p) { return new BasicType(p.matches.join(" ")); }
        );
    }

    // (20)
    void parseTypeDcl(in ParseTree p)
    {
        treeMatch(p.getFirst,
            "ConstrTypeDcl", &parseConstrTypeDcl,
            "TypedefDcl", &parseTypedefDcl,
        );
    }

    // (21), (216)
    AbstractType getTypeSpec(in ParseTree p)
    {
        return treeMatch(p.getFirst,
            "TemplateTypeSpec", &getTemplateTypeSpec,
            "SimpleTypeSpec", &getSimpleTypeSpec,
        );
    }

    // (22)
    AbstractType getSimpleTypeSpec(in ParseTree p)
    {
        return treeMatch(p.getFirst,
            "BaseTypeSpec", &getBaseTypeSpec,
            "ScopedName", &getScopedName,
        );
    }

    // (23)
    AbstractType getBaseTypeSpec(in ParseTree p)
    {
        return new BasicType(p.getFirst.matches.join(" "));
    }

    // (38)
    AbstractType getTemplateTypeSpec(in ParseTree p)
    {
        return treeMatch(p.getFirst,
            "SequenceType", &getSequenceType,
            "StringType", &getStringType,
            "WideStringType", &getWideStringType,
        );
    }

    // (39)
    AbstractType getSequenceType(in ParseTree p)
    {
        auto typeSpec = cast(AbstractNestableType) getTypeSpec(p.getAt("TypeSpec"));
        if (p.has("PositiveIntConst"))
        {
            return new BoundedSequence(typeSpec, p.getAt("PositiveIntConst").getData);
        }
        else
        {
            return new UnboundedSequence(typeSpec);
        }
    }

    // (40)
    AbstractType getStringType(in ParseTree p)
    {
        if (p.has("PositiveIntConst"))
        {
            return new BoundedString(p.getAt("PositiveIntConst").getData);
        }
        else
        {
            return new UnboundedString();
        }
    }

    // (41)
    AbstractType getWideStringType(in ParseTree p)
    {
        if (p.has("PositiveIntConst"))
        {
            return new BoundedWString(p.getAt("PositiveIntConst").getData);
        }
        else
        {
            return new UnboundedWString();
        }
    }

    // (42)
    AbstractType getFixedPtConstType(in ParseTree p)
    {
        // TODO: No plan to implement
        assert(false, "Not implemented");
    }

    // (44)
    void parseConstrTypeDcl(in ParseTree p)
    {
        treeMatch(p.getFirst, "StructDcl", &parseStructDcl);
    }

    // (45), (46)
    void parseStructDcl(in ParseTree p)
    {
        const structDef = p.getAt("StructDef");
        const identifier = structDef.getAt("Identifier").getData;
        auto members = reduce!((a, b) => a ~= getMembers(b))(
            new Member[0], structDef.getAll("Member"));
        auto s = Structure(new NamespacedType(namespaces, identifier), members);

        const target = s.namespacedType.joinedName;
        data.messages.require(target, new Message()).structure = s;
    }

    // (47), (67)
    Member[] getMembers(in ParseTree p)
    {
        auto typeSpec = getTypeSpec(p.getAt("TypeSpec"));

        auto anno = p.getAll("AnnotationAppl").map!(c => getAnnotationAppl(c)).array;

        auto members = p.getAt("Declarators").getAll("Declarator")
            .map!(c => getDeclarator(c))
            .map!(c => c.predSwitch!((a, b) => (a[1] != null) == b)(
                    true, Member(new ArrayType(cast(AbstractNestableType) typeSpec, c[1]), c[0]),
                    false, Member(typeSpec, c[0])
            ))
            .map!((c) { c.annotations ~= anno; return c; });

        return members.array;
    }

    // (66)
    void parseTypedefDcl(in ParseTree p)
    {
        auto typeDeclarator = p.getAt("TypeDeclarator");
        auto typeSpec = getTypeSpec(typeDeclarator);
        typeDeclarator.getAt("AnyDeclarators").getAll("AnyDeclarator")
            .map!(c => getAnyDeclarator(c))
            .each!((c) {
                auto key = new NamespacedType(namespaces, c[0]);
                assert(key !in data.typedefMap);
                if (c[1])
                {
                    data.typedefMap[key] = new ArrayType(cast(AbstractNestableType) typeSpec, c[1]);
                }
                else
                {
                    data.typedefMap[key] = typeSpec;
                }

            });
    }

    // (66)
    alias getAnyDeclarator = getDeclarator;

    // (68), (217)
    auto getDeclarator(in ParseTree p)
    {
        const unwrap = p.getFirst;
        const identifier = unwrap.searchFirst("Identifier").getData;
        string size = null;
        if (unwrap.name == tag("ArrayDeclarator"))
        {
            const arraySizes = unwrap.getAll("FixedArraySize");
            assert(arraySizes.length == 1);
            size = arraySizes[0].getAt("PositiveIntConst").getData;
        }
        return tuple(identifier, size);
    }

    // (225)
    Annotation getAnnotationAppl(in ParseTree p)
    {
        auto name = p.getAt("ScopedName").getData;
        if (p.has("AnnotationAPplPArams"))
        {
            return Annotation(name, p.getAt("AnnotationApplParams").getData);
        }
        else
        {
            return Annotation(name, null);
        }
    }

    @("parse") unittest
    {
        auto parser = new Parser();
        parser.parse(ROSIDL(import("test/msg.idl")));

        auto data = parser.data;
        assert(data.messages.length == 1);
        assert(data.messages.values[0].constants.length == 7);

    }

}

auto parseAsMessage(string text)
{
    auto idl = ROSIDL(text);
    auto p = new Parser();
    p.parse(idl);

    assert(p.data.messages.length == 1);

    return IdlFile!Message(p.data.includes, p.data.typedefMap, p.data.messages.values[0]);

}

@("parseAsMessage") unittest
{
    auto msg = parseAsMessage(import("test/msg.idl"));
}

auto parseAsService(string text)
{
    auto idl = ROSIDL(text);
    auto p = new Parser();
    p.parse(idl);

    assert(p.data.messages.length == 2);

    return IdlFile!Service(p.data.includes, p.data.typedefMap, new Service(p.data.messages.values));
}

@("parseAsService") unittest
{
    auto msg = parseAsService(import("test/srv.idl"));
}

auto parseAsAction(string text)
{
    auto idl = ROSIDL(text);
    auto p = new Parser();
    p.parse(idl);

    assert(p.data.messages.length == 3);

    return IdlFile!Action(p.data.includes, p.data.typedefMap, new Action(p.data.messages.values));
}

@("parseAsAction") unittest
{
    auto msg = parseAsAction(import("test/action.idl"));
}
