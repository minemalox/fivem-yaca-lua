local NUI = {}

NUI.FirstConnect = true
NUI.WebsocketReady = false
NUI.WebsocketConnected = false

function NUI.connect(onReady, onDisconnected, onMessage, onError)
    Wait(5000)

    if not NUI.WebsocketReady then
        return lib.print.verbose("[Voice-Websocket]: No websocket created")
    end

    RegisterNUICallback("YACA_OnConnected", function(data, cb)
        NUI.WebsocketConnected = true
        onReady()

        cb("ok")
    end)

    RegisterNUICallback("YACA_OnDisconnected", function(data, cb)
        NUI.WebsocketConnected = false
        onDisconnected(data.code, data.reason)
        cb("ok")
    end)

    RegisterNUICallback("YACA_OnMessage", function(data, cb)
        onMessage(data)
        cb("ok")
    end)

    RegisterNUICallback("YACA_OnError", function(data, cb)
        onError(data)
        cb("ok")
    end)

    SendNuiMessage(json.encode({
        action = "connect"
    }))
end

function NUI.initNUICallbacks()
    RegisterNUICallback("YACA_OnNuiReady", function(data, cb)
        NUI.WebsocketReady = true
        lib.print.verbose("[YACA-Websocket]: NUI ready")

        TriggerServerEvent('server:yaca:nuiReady')
        cb("ok")
    end)
end

function NUI.SendWSMessage(msg)
    if not NUI.WebsocketReady then
        return lib.print.verbose("[Voice-Websocket]: No websocket created")
    end

    if not NUI.WebsocketConnected then
        return lib.print.verbose("[Voice-Websocket]: Websocket not connected")
    end

    SendNuiMessage(json.encode({
        action = "command",
        data = msg
    }))
end

function NUI.closeConnection()
    SendNuiMessage(json.encode({
        action = "close"
    }))
end

return NUI