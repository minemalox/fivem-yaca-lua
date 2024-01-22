local NUI = {}

NUI.FirstConnect = true
NUI.WebsocketReady = false
NUI.WebsocketConnected = false

function NUI.connect(onReady, onDisconnected, onMessage, onError)
    RegisterNUICallback("YACA_OnConnected", function(data, cb)
        lib.print.verbose("[YACA-Websocket]: connected")
        NUI.WebsocketConnected = true
        onReady()
    end)

    RegisterNUICallback("YACA_OnDisconnected", function(data, cb)
        lib.print.verbose("[YACA-Websocket]: client disconnected", data.code, data.reason)
        NUI.WebsocketConnected = false
        onDisconnected(data.code, data.reason)
    end)

    RegisterNUICallback("YACA_OnMessage", function(data, cb)
        lib.print.verbose("[YACA-Websocket] Message: " .. json.encode(data))
        onMessage(data)
    end)

    RegisterNUICallback("YACA_OnError", function(data, cb)
        lib.print.verbose("[YACA-Websocket] Error: " .. json.encode(data))
        onError(data)
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
    end)
end

function NUI.SendWSMessage(msg)
    if not NUI.WebsocketReady then
        return lib.print.verbose("[Voice-Websocket]: No websocket created")
    end

    if not NUI.WebsocketConnected then
        return lib.print.verbose("[Voice-Websocket]: Websocket not connected")
    end

    local nuiMessage = {
        action = "runCommand",
        data = json.encode(msg)
    }

    SendNuiMessage(json.encode(nuiMessage))
end

return NUI