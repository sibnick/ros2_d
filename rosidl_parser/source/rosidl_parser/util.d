module rosidl_parser.util;

/**
 * Create a pegged helper functions
 * Params:
 *   prefix = PEG prefix
 */
mixin template peggedHelper(string prefix)
{
    import pegged.grammar;

    string tag(string k)
    {
        import std.array : join;

        return [prefix, k].join(".");
    }

    auto getAll(in ParseTree p, in string k)
    {
        import std.algorithm : filter;
        import std.array : array;

        return p.children.filter!(a => a.name == tag(k)).array;
    }

    auto getFirst(in ParseTree p)
    {
        assert(p.children.length > 0);
        return p.children[0];
    }

    auto getAt(in ParseTree p, in string k, size_t at = 0U)
    {
        import std.conv : to;
        import std.array : array;

        assert(p.has(k), p.to!string);
        const all = p.getAll(k).array;
        assert(all.length > at, all.to!string);
        return all[at];
    }

    bool has(in ParseTree p, in string k)
    {
        import std.algorithm : any;

        return p.children.any!(a => a.name == tag(k));
    }

    string getData(in ParseTree p)
    {
        import std.array : join;

        return p.matches[].join("");
    }

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

        assert(impl(p), p.to!string);
        return ret;
    }

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

mixin template makeToString(args...)
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

mixin template makeToHash(args...)
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

mixin template makeHashEquals()
{
    override bool opEquals(const Object other) const
    {
        return hashOf(this) == hashOf(other);
    }
}
