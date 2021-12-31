/**
 * Define IDL types.
 *
 * <img src="img/rosidl_parser/types.drawio.svg"/>
 *
 * All types are class but can be calculated hash and compared like struct.
 */
module rosidl_parser.definition.type;

import rosidl_parser.definition.identifier : basicTypes;
import std.algorithm : canFind;
import std.array : join;

/**
 * AbstractType
 *
 * All subclasses override `toString`, `toHash` and `opEquals`.
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
 * BasicType
 *
 * The following identifiers will be BasicType (comes from `rosidl_parser.definition.identifier.basicTypes`)
 * - `short`
 * - `long`
 * - `long long`
 * - `unsined short`
 * - `unsigned long`
 * - `unsigned long long`
 * - `float`
 * - `double`
 * - `long double`
 * - `char`
 * - `wchar`
 * - `boolean`
 * - `octet`
 * - `int8`
 * - `int16`
 * - `int32`
 * - `int64`
 * - `uint8`
 * - `uint16`
 * - `uint32`
 * - `uint64`
 */
final class BasicType : AbstractNestableType
{
    /// Typename (e.g. boolean)
    const(string) name;

    ///
    this(in string name)
    {
        assert(basicTypes.canFind(name), name);
        this.name = name;
    }

    mixin makeToString!(name);
    mixin makeToHash!(name);
}

/**
 * NamedType
 *
 * NamedType is a type which is neither BasicType nor NamespecedType. (e.g. `boolean__3`)
 */
final class NamedType : AbstractNestableType
{
    /// Typename
    const(string) name;

    ///
    this(in string name)
    {
        this.name = name;
    }

    mixin makeToString!(name);
    mixin makeToHash!(name);
}

/**
 * NamespacedType
 *
 * NamespacedType is a type who has namespace. To extract namespace, the identifier must have at
 * least two sub identifiers separated by `::`, or must be constructed with namespaces like module.
 * (e.g. `pkgname::msg::MyMessage`)
 */
final class NamespacedType : AbstractNestableType
{
    /// Namespace (e.g. [pkgname, msg])
    const(string)[] namespaces;
    /// Typename (e.g. MyMessage)
    const(string) name;

    ///
    this(in string[] namespaces, in string name)
    {
        assert(namespaces.length > 0);
        this.namespaces = namespaces;
        this.name = name;
    }

    /**
     * Get a fullname joined by `sep`.
     *
     * Params:
     *   sep = Separator
     * Returns: Joined name
     */
    auto joinedName(in string sep = "::") const
    {
        return (namespaces ~ name).join(sep);
    }

    mixin makeToString!(joinedName);
    mixin makeToHash!(namespaces, name);
}

// Strings

/**
 * AbstractGenericString
 */
abstract class AbstractGenericString : AbstractNestableType
{
}

/**
 * AbstractString
 */
abstract class AbstractString : AbstractGenericString
{
}

/**
 * BoundedString
 *
 * String with `maximumSize`
 */
final class BoundedString : AbstractString
{
    /// Maximum size of the string
    const(string) maximumSize;

    ///
    this(in string maximumSize)
    {
        this.maximumSize = maximumSize;
    }

    mixin makeToString!(maximumSize);
    mixin makeToHash!(maximumSize);
}

/**
 * UnboundedString
 *
 * String without capacity
 */
final class UnboundedString : AbstractString
{
}

/**
 * AbstractWString
 */
abstract class AbstractWString : AbstractGenericString
{
}

/**
 * BoundedWString
 *
 * Wide String with `maximumSize`
 */
final class BoundedWString : AbstractWString
{
    /// Maximum size of the string
    const(string) maximumSize;

    ///
    this(in string maximumSize)
    {
        this.maximumSize = maximumSize;
    }

    mixin makeToString!(maximumSize);
    mixin makeToHash!(maximumSize);
}

/**
 * UnboundedWString
 *
 * Wide String without capacity
 */
final class UnboundedWString : AbstractWString
{
}

// Nested Types

/**
 * AbstractNestedType
 *
 * NestedType will hold the other **NestableType**.
 */
abstract class AbstractNestedType : AbstractType
{
    /// Value type
    const(AbstractNestableType) valueType;

    ///
    this(in AbstractNestableType valueType)
    {
        this.valueType = valueType;
    }

    mixin makeToString!(valueType);
    mixin makeToHash!(valueType);
}

/**
 * ArrayType
 *
 * Array type will be a static array
 */
class ArrayType : AbstractNestedType
{
    /// Size of array
    string size;

    ///
    this(in AbstractNestableType valueType, in string size)
    {
        super(valueType);
        this.size = size;
    }

    mixin makeToString!(valueType, size);
    mixin makeToHash!(size);
}

/**
 * AbstractSequence
 *
 * AbstractSequence will be a dynamic array
 */
abstract class AbstractSequence : AbstractNestedType
{
    ///
    this(in AbstractNestableType valueType)
    {
        super(valueType);
    }
}

/**
 * BoundedSequence
 *
 * BoundedSequence is a dynamic array but has capacity `maximumSize`.
 */
class BoundedSequence : AbstractSequence
{
    /// Maximum size of the sequence.
    string maximumSize;

    ///
    this(in AbstractNestableType valueType, in string maximumSize)
    {
        super(valueType);
        this.maximumSize = maximumSize;
    }

    mixin makeToString!(valueType, maximumSize);
    mixin makeToHash!(maximumSize);
}

/**
 * UnboundedSequence
 *
 * UnboundedSequence is a dynamic array without capacity.
 */
class UnboundedSequence : AbstractSequence
{
    ///
    this(in AbstractNestableType valueType)
    {
        super(valueType);
    }
}

private mixin template makeToString(args...)
{
    override string toString() const
    {
        import std.format;
        import std.conv;
        import std.array;

        const __name = typeid(this).to!string.split(".")[$ - 1];
        static if (args.length > 0)
        {
            string[] __items;
            foreach (__a; args)
            {
                __items ~= __a.to!string;
            }
            return format!"%s(%-(%s,%))"(__name, __items);
        }
        else
        {
            return __name;
        }
    }
}

private mixin template makeToHash(args...)
{
    override size_t toHash() @safe nothrow const
    {
        static if (args.length == 0)
        {
            return hashOf(typeid(this));
        }
        else
        {
            auto __h = super.toHash();
            foreach (__a; args)
            {
                //__h ^= hashOf(__a);
            }
            return __h;
        }

    }
}

private mixin template makeHashEquals()
{
    override bool opEquals(const Object other) const
    {
        return hashOf(this) == hashOf(other);
    }
}
