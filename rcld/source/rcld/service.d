module rcld.service;

import rcl;
import rcld.node;
import std.string;
import std.exception;

interface BaseService
{
    void terminate(Node node);
    void takeAndCall();
    rcl_service_t* handle() nothrow;
}

class Service(ServiceType) : BaseService
{
    alias CallbackT = void delegate(in ServiceType.Request, out ServiceType.Response);

    this(Node node, in string name)
    {
        serviceHandle = rcl_get_zero_initialized_service();
        auto option = rcl_service_get_default_options();
        auto typesupport = ServiceType.getTypesupport();
        enforce(rcl_service_init(&serviceHandle, &node.nodeHandle, typesupport, name.toStringz, &option) == RCL_RET_OK);
        node.services ~= this;
    }

    override void terminate(Node node)
    {
        if (serviceHandle.impl)
        {
            enforce(rcl_service_fini(&serviceHandle, &node.nodeHandle) == RCL_RET_OK);
        }
    }

    bool take(out ServiceType.Request request, out rmw_request_id_t requestId)
    {
        auto cMsg = ServiceType.Request.createC();
        assert(cMsg);
        scope (exit)
            ServiceType.Request.destroyC(cMsg);
        const ret = rcl_take_request(&serviceHandle, &requestId, cast(void*) cMsg);
        if (ret == RCL_RET_OK)
        {
            ServiceType.Request.convert(*cMsg, request);
        }
        return ret == RCL_RET_OK;
    }

    void setCallback(CallbackT callback)
    {
        this.callback = callback;
    }

    override void takeAndCall()
    {
        auto request = ServiceType.Request();
        auto response = ServiceType.Response();
        rmw_request_id_t requestId;
        enforce(take(request, requestId));
        if (callback)
        {

            callback(request, response);
            sendResponse(response, requestId);
        }
    }

    override rcl_service_t* handle() nothrow
    {
        return &serviceHandle;
    }

private:
    rcl_service_t serviceHandle;
    CallbackT callback;

    void sendResponse(in ServiceType.Response response, ref rmw_request_id_t requestId)
    {
        auto cMsg = ServiceType.Response.createC();
        assert(cMsg);
        scope (exit)
            ServiceType.Response.destroyC(cMsg);

        ServiceType.Response.convert(response, *cMsg);
        enforce(rcl_send_response(&serviceHandle, &requestId, cast(void*) cMsg) == RCL_RET_OK);
    }
}
