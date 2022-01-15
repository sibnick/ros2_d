module rosidl_parser.parser;

import rosidl_parser.definition;
import pegged.grammar;
import std.algorithm.comparison;
import std.algorithm;
import std.typecons;
import std.conv;
import std.array;
import std.stdio : writeln;

/**
 * Parse IDL text as Message
 *
 * Params:
 *   text = Input text of IDL file
 * Returns: IdlFile!Message
 */
auto parseAsMessage(string text)
{
    auto idl = ROSIDL(text);
    auto p = new Parser();
    p.parse(idl);

    assert(p.data.messages.length == 1, text);

    return IdlFile!Message(p.data.includes, p.data.typedefMap, p.data.messages.values[0]);

}

@("parseAsMessage") unittest
{
    import test_helper.test_msgs;
    import std.format;

    static foreach (type; __traits(allMembers, TestMsgs.Msg))
    {
        {
            const reference = mixin(format!"TestMsgsData.Msg.%s"(type));
            const answer = parseAsMessage(mixin(format!"TestMsgs.Msg.%s"(type)));

            validateMessage(answer.data, reference);
        }
    }

}

/**
 * Parse IDL text as Service
 *
 * Params:
 *   text = Input text of IDL file
 * Returns: IdlFile!Service
 */
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
    import test_helper.test_msgs;
    import std.format;

    static foreach (type; __traits(allMembers, TestMsgs.Srv))
    {
        {
            const reference = mixin(format!"TestMsgsData.Srv.%s"(type));
            const answer = parseAsService(mixin(format!"TestMsgs.Srv.%s"(type)));

            assert(answer.data.type.name == reference.name);

            validateMessage(answer.data.request, reference.request);
            validateMessage(answer.data.response, reference.response);
        }
    }
}

/**
 * Parse IDL text as Action
 *
 * Params:
 *   text = Input text of IDL file
 * Returns: IdlFile!Action
 */
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
    import test_helper.test_msgs;
    import std.format;

    static foreach (type; __traits(allMembers, TestMsgs.Action))
    {
        {
            const reference = mixin(format!"TestMsgsData.Action.%s"(type));
            const answer = parseAsAction(mixin(format!"TestMsgs.Action.%s"(type)));

            assert(answer.data.type.name == reference.name);

            validateMessage(answer.data.goal, reference.goal);
            validateMessage(answer.data.result, reference.result);
            validateMessage(answer.data.feedback, reference.feedback);

            assert(answer.data.sendGoalService.type.name == reference.sendGoalService.name);
            validateMessage(answer.data.sendGoalService.request,
                reference.sendGoalService.request);
            validateMessage(answer.data.sendGoalService.response,
                reference.sendGoalService.response);

            assert(answer.data.getResultService.type.name == reference.getResultService.name);
            validateMessage(answer.data.getResultService.request,
                reference.getResultService.request);
            validateMessage(answer.data.getResultService.response,
                reference.getResultService.response);

            validateMessage(answer.data.feedbackMessage, reference.feedbackMessage);
        }
    }
}

version (unittest)
{
    void validateMessage(T, U)(T a, U b)
    {
        auto as = a.structure;
        auto bs = b.structure;
        auto ac = a.constants;
        auto bc = b.constants;

        assert(as.namespacedType.name == bs.name, a.to!string ~ " <-> " ~ b.to!string);
        assert(as.members.length == bs.members.length, a.to!string ~ "<->" ~ b.to!string);
        foreach (i; 0 .. bs.members.length)
        {
            assert(as.members[i].name == bs.members[i].name,
                as.members[i].to!string ~ "<->" ~ bs.members[i].to!string ~ " @" ~ bs
                    .name);
        }

        assert(ac.length == bc.length, a.to!string ~ "<->" ~ b.to!string);
        foreach (i; 0 .. bc.length)
        {
            assert(ac[i].name == bc[i].name, ac[i].to!string ~ "<->" ~ bc[i].to!string ~ " @" ~ bs
                    .name);
        }
    }
}

private mixin(grammar(import("rosidl.peg")));
private mixin peggedHelper!"ROSIDL";

private struct ParsedData
{
    Message[string] messages;
    Include[] includes;
    AbstractType[AbstractType] typedefMap;
}

private class Parser
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
                // Do not check because there are some cases which have same typedef declaration
                //assert(key !in data.typedefMap, key.to!string ~ " -> " ~ data.typedefMap.to!string);
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
}

private mixin template peggedHelper(string prefix)
{
    import pegged.grammar;

    /**
     * Create a PEG tag with prefix
     *
     * Params:
     *   k = Tag name
     * Returns: `<prefix>.<k>`
     */
    string tag(string k)
    {
        import std.array : join;

        return [prefix, k].join(".");
    }

    /**
     * Get all child element with name `k`.
     *
     * Params:
     *   p = ParseTree
     *   k = Target tag name
     * Returns: A list of extracted child elements.
     */
    auto getAll(in ParseTree p, in string k)
    {
        import std.algorithm : filter;
        import std.array : array;

        return p.children.filter!(a => a.name == tag(k)).array;
    }

    /**
     * Get first child element.
     *
     * If `p` does not have any child element, an assertion will be raised.
     * Params:
     *   p = ParseTree
     * Returns: Extracted element.
     */
    auto getFirst(in ParseTree p)
    {
        assert(p.children.length > 0);
        return p.children[0];
    }

    /**
     * Get `at`-th child element with name `k`.
     *
     * If `p` does not have `at`-th `k` child element, an assertion will be raised.
     * Params:
     *   p = ParseTree
     *   k = Target tag name
     * Returns: Extracted element.
     */
    auto getAt(in ParseTree p, in string k, size_t at = 0U)
    {
        import std.conv : to;
        import std.array : array;

        assert(p.has(k), p.to!string);
        const all = p.getAll(k).array;
        assert(all.length > at, all.to!string);
        return all[at];
    }

    /**
     * Check if `p` has `k` child element.
     *
     * Params:
     *   p = ParseTree
     *   k = Target tag name
     * Returns: Check result
     */
    bool has(in ParseTree p, in string k)
    {
        import std.algorithm : any;

        return p.children.any!(a => a.name == tag(k));
    }

    /**
     * Get matched data as a string.
     *
     * If `p` still has multiple child element, this function just concat its string.
     *
     * Params:
     *   p = ParseTree
     * Returns: Extracted string
     */
    string getData(in ParseTree p)
    {
        import std.array : join;

        return p.matches[].join("");
    }

    /**
     * Search tag name recursively
     *
     * This function finds `k` with depth-wise searching. If the tag is not found, an assertion will be raised.
     * Params:
     *   p = ParseTree
     *   k =Target tag name
     * Returns: Extracted element.
     */
    auto searchFirst(in ParseTree p, in string k)
    {
        import std.conv : to;

        ParseTree ret;
        bool impl(in ParseTree pp)
        {
            if (pp.has(k))
            {
                ret = pp.getAt(k).dup;
                return true;
            }
            else
            {
                foreach (c; pp.children)
                {
                    if (impl(c))
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        auto found = impl(p);

        assert(found, p.to!string);
        return ret;
    }

    /**
     * Match function for ParseTree.
     *
     * `choices` field is a list of combination of key and delegate. Key is a tag for PEG and used
     * with <prefix>. Delegate need to have an argument for `in ParseTree` and can return any types.
     * including void.
     * If the number of `choices` is odd, the last delegate will be a default rule. If no default
     * choice is specified and no choices are matched, an assertion will be raised.
     *
     * Examples:
     * ----------
     * // Print "Matched Foo" if p.name == `"<prefix>.Foo"`.
     * treeMatch(p,
     *   "Foo", (in ParseTree p) { writeln("Matched Foo", p); },
     *   "Bar", (in ParseTree p) { writeln("Matched Bar", p); },
     * );
     *
     * // Return a string
     * auto ret = treeMatch(p,
     *   "Foo", (in ParseTree p) { return "Matched Foo"; },
     *   "Bar", (in ParseTree p) { return "Matched Bar"; },
     * );
     * ----------
     * Params:
     *   p = ParseTree
     *   choices = A list of combination of key and delegate
     */
    auto treeMatch(R...)(in ParseTree p, lazy R choices)
    {
        import core.exception : SwitchError;

        foreach (index, ChoiceType; R)
        {
            static if (index % 2 == 1)
            {
                if (p.name == tag(choices[index - 1]))
                {
                    static if (is(typeof(choice[index]()(p)) == void))
                    {
                        choices[index]()(p);
                        return;
                    }
                    else
                    {
                        return choices[index]()(p);
                    }
                }
            }

        }

        static if (R.length % 2 == 1)
        {
            static if (is(typeof(choice[index]()(p)) == void))
            {
                choices[$ - 1]()(p);
                return;
            }
            else
            {
                return choices[$ - 1]()(p);
            }
        }
        else
        {
            assert(false, p.name);
        }
    }

}
