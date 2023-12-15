local callBackEvents = {}

RegisterOwnClientCallback = function (eventname,cb)
    callBackEvents[eventname] = cb
end

RegisterNetEvent('yaca:triggerClientEvent',function(event,...)
    TriggerServerEvent('yaca:callClientCallBack',event,callBackEvents[event](...))
end)

