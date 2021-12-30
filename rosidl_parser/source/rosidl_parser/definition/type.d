/**
 * Define ROSIDL types.
 *
 * All types can be compared like struct.
 */
module rosidl_parser.definition.type;

import rosidl_parser.util : makeToHash, makeToString, makeHashEquals;
import rosidl_parser.definition.identifier : basicTypes;
import std.algorithm : canFind;
import std.array : join;

/**
 * AbstractType
 */
abstract class AbstractType
{
    mixin makeToString;
    mixin makeToHash;
    mixin makeHashEquals;
}

// Nestable types
/**
 * AbstractNestableType
 */
abstract class AbstractNestableType : AbstractType
{
}

/**
 * BasicType (e.g. boolean)
 */
final class BasicType : AbstractNestableType
{
    /// Typename (e.g. boolean)
    const(string) name;

    this(in string name)
    {
        assert(basicTypes.canFind(name), name);
        this.name = name;
    }

    mixin makeToString!(name);
    mixin makeToHash!(name);
}

/**
 * NamedType (neither BasicType nor NamespecedType, e.g. boolean__3)
 */
final class NamedType : AbstractNestableType
{
    /// Typename
    const(string) name;

    this(in string name)
    {
        this.name = name;
    }

    mixin makeToString!(name);
    mixin makeToHash!(name);
}

/**
 * NapespacedType (e.g. pkgname::msg::MyMessage)
 */
final class NamespacedType : AbstractNestableType
{
    /// Namespace (e.g. [pkgname, msg])
    const(string)[] namespaces;
    /// Typename (e.g. MyMessage)
    const(string) name;

    this(in string[] namespaces, in string name)
    {
        assert(namespaces.length > 0);
        this.namespaces = namespaces;
        this.name = name;
    }

    auto joinedName(in string sep = "::") const
    {
        return (namespaces ~ name).join(sep);
    }

    mixin makeToString!(joinedName);
    mixin makeToHash!(namespaces, name);
}

mixin template makeBounded()
{
    const(string) maximumSize;
    this(in string maximumSize)
    {
        this.maximumSize = maximumSize;
    }

    mixin makeToString!(maximumSize);
    mixin makeToHash!(maximumSize);
}

// Strings

abstract class AbstractGenericString : AbstractNestableType
{
}

abstract class AbstractString : AbstractGenericString
{
}

final class BoundedString : AbstractString
{
    mixin makeBounded;
}

final class UnboundedString : AbstractString
{
}

abstract class AbstractWString : AbstractGenericString
{
}

final class BoundedWString : AbstractWString
{
    mixin makeBounded;
}

final class UnboundedWString : AbstractWString
{
}

// Nested Types

abstract class AbstractNestedType : AbstractType
{
    const(AbstractNestableType) valueType;

    this(in AbstractNestableType valueType)
    {
        this.valueType = valueType;
    }

    mixin makeToString!(valueType);
    mixin makeToHash!(valueType);
}

class ArrayType : AbstractNestedType
{
    string size;

    this(in AbstractNestableType valueType, in string size)
    {
        super(valueType);
        this.size = size;
    }

    mixin makeToString!(valueType, size);
    mixin makeToHash!(size);
}

abstract class AbstractSequence : AbstractNestedType
{
    this(in AbstractNestableType valueType)
    {
        super(valueType);
    }
}

class BoundedSequence : AbstractSequence
{
    string maximumSize;

    this(in AbstractNestableType valueType, in string maximumSize)
    {
        super(valueType);
        this.maximumSize = maximumSize;
    }

    mixin makeToString!(valueType, maximumSize);
    mixin makeToHash!(maximumSize);
}

class UnboundedSequence : AbstractSequence
{
    this(in AbstractNestableType valueType)
    {
        super(valueType);
    }
}
