module rcld.client;

import rcld.node;
import rcl;
import std.string;
import std.exception;
import std.stdio;

interface BaseClient
{
    void terminate(Node node);
    void takeAndCall();
    rcl_client_t* handle() nothrow;
}

class Client(ServiceType) : BaseClient
{
    alias CallbackT = void delegate(in ServiceType.Response);
    this(Node node, in string name)
    {
        clientHandle = rcl_get_zero_initialized_client();
        auto option = rcl_client_get_default_options();
        auto typesupport = ServiceType.getTypesupport();
        enforce(rcl_client_init(&clientHandle, &node.nodeHandle, typesupport, cast(const(ubyte)*)name.toStringz, &option) == 0);
        node.clients ~= this;
    }

    override void terminate(Node node)
    {
        if (clientHandle.impl)
        {
            enforce(rcl_client_fini(&clientHandle, &node.nodeHandle) == RCL_RET_OK);
        }
    }

    void sendRequest(in ServiceType.Request request)
    {
        auto cMsg = ServiceType.Request.createC();
        assert(cMsg);
        ServiceType.Request.convert(request, *cMsg);
        long seq;
        enforce(rcl_send_request(&clientHandle, cast(const(void)*) cMsg, &seq) == 0);
        ServiceType.Request.destroyC(cMsg);
    }

    bool take(out ServiceType.Response response)
    {
        auto cMsg = ServiceType.Response.createC();
        rmw_request_id_t requestId;
        assert(cMsg);
        scope (exit)
            ServiceType.Response.destroyC(cMsg);
        const ret = rcl_take_response(&clientHandle, &requestId, cast(void*) cMsg);
        if (ret == 0)
        {
            ServiceType.Response.convert(*cMsg, response);
        }
        return ret == 0;
    }

    void setCallback(CallbackT callback)
    {
        this.callback = callback;
    }

    override void takeAndCall()
    {
        auto response = ServiceType.Response();
        enforce(take(response));
        if (callback)
        {
            callback(response);
        }
    }

    override rcl_client_t* handle() nothrow
    {
        return &clientHandle;
    }

package:
    rcl_client_t clientHandle;
    CallbackT callback;
}
