module rosidl_parser.definition.structure;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

import rosidl_parser.definition.type;

struct Include
{
    string locator;
}

struct Annotation
{
    string name;
    string value;
}

mixin template Annotatable()
{
    Annotation[] annotations;

    auto getAnnotationValues(in string name) const
    {
        return annotations.filter!(a => a.name == name)
            .map!(a => a.value)
            .array;
    }

    auto getAnnotationValue(in string name) const
    {
        const a = getAnnotationValues(name);
        assert(a.length == 1, a.to!string);
        return a[0];
    }

    bool hasAnnotation(in string name) const
    {
        return getAnnotationValues(name).length == 1;
    }

    bool hasAnnotations(in string name) const
    {
        return getAnnotationValues(name).length > 0;
    }
}

struct Member
{
    AbstractType type;
    string name;

    mixin Annotatable;

    string toString() const
    {
        return format!"%s\t%s\t%s"(type, name, annotations);
    }
}

struct Structure
{
    NamespacedType namespacedType;
    Member[] members;

    mixin Annotatable;

    string toString() const
    {
        return format!"%s:\n%-(  %s\n%)"(namespacedType.joinedName, members);
    }
}

struct Constant
{
    AbstractType type;
    string name;
    string value;

    mixin Annotatable;

    string toString() const
    {
        return format!"%s\t%s\t%s"(type.to!string, name, value);
    }
}
