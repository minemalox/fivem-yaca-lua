local callClientCallBackEvents = {}


function TriggerClientCallback(event,source,func,...)
    callClientCallBackEvents[event] = func

    TriggerClientEvent('yaca:triggerClientEvent',source,event,...)
end



RegisterNetEvent('yaca:callClientCallBack',function (event,returnValue)
    print(" yy " .. event .. " / " .. returnValue)
end)
