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

/**
 * Member representation of Structure
 */
struct Member
{
    /// Type of the member
    AbstractType type;
    /// Name of the member
    string name;

    ///
    mixin Annotatable;

    /// Will return `"<type> <name> [annotations]"`.
    string toString() const
    {
        return format!"%s\t%s\t%s"(type, name, annotations);
    }
}

/**
 * Structure representation
 *
 * The structure must have namespace and be identified as unique name.
 */
struct Structure
{
    /// Type of the structure
    NamespacedType namespacedType;
    /// Its members
    Member[] members;

    ///
    mixin Annotatable;

    /**
     * Will return
     * ----------
     * <Typename>:
     *   - <member>
     *   - ...
     * ----------
     */
    string toString() const
    {
        return format!"%s:\n%-(  %s\n%)"(namespacedType.joinedName, members);
    }
}

/**
 * Constant representation
 */
struct Constant
{
    /// Type of the constant
    AbstractType type;
    /// Name of the constant
    string name;
    /// VAlue of the constant
    string value;

    ///
    mixin Annotatable;

    /// WIll return `"<type> <name> <value>"`.
    string toString() const
    {
        return format!"%s\t%s\t%s"(type.to!string, name, value);
    }
}

private mixin template Annotatable()
{
    /// Annotations
    Annotation[] annotations;

    /**
     * Get annotations whose name is `name`
     *
     * Params:
     *   name = Target annotation name
     * Returns: A list of annotations
     */
    auto getAnnotationValues(in string name) const
    {
        return annotations.filter!(a => a.name == name)
            .map!(a => a.value)
            .array;
    }

    /**
     * Get an annotation whose name is `name`
     *
     * Unlike `getAnnotationValues` collects multiple annotations, this function get only one
     * annotation for the name. If there is no annotation nor more than two annotation, an
     * assertion will be raised.
     *
     * Params:
     *   name = Target annotation name
     * Returns: An annotation
     */
    auto getAnnotationValue(in string name) const
    {
        const a = getAnnotationValues(name);
        assert(a.length == 1, a.to!string);
        return a[0];
    }

    /**
     * Check if **one** `name` annotation is available.
     *
     * Params:
     *   name = Target annotation name
     * Returns: Check result
     */
    bool hasAnnotation(in string name) const
    {
        return getAnnotationValues(name).length == 1;
    }

    /**
     * Check if (more than one) `name` annotations are available.
     * Params:
     *   name = Target annotation name
     * Returns: Check result
     */
    bool hasAnnotations(in string name) const
    {
        return getAnnotationValues(name).length > 0;
    }
}
