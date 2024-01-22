local NUI = {}

NUI.FirstConnect = true
NUI.WebsocketReady = false
NUI.WebsocketConnected = false
NUI.StoredDataObj = nil

function NUI.connect()
    SendNuiMessage(json.encode({
        Function = "connect"
    }))
end

function NUI.SetStoredData(dataObj)
    NUI.StoredDataObj = dataObj
end

function NUI.initNUICallbacks()
    RegisterNUICallback("YACA_OnMessage", function(data, cb)
        handleResponse(data)

        print("[YACA-Websocket] Message: " .. json.encode(data))
    end)

    RegisterNUICallback("YACA_OnError", function(data, cb)
        if data then
            print("[YACA-Websocket] Error: " .. data)
        else
            print("[YACA-Websocket] Error: unknown")
        end
    end)

    RegisterNUICallback("YACA_OnConnected", function(data, cb)
        NUI.WebsocketConnected = true

        if NUI.FirstConnect then
            initRequest(NUI.StoredDataObj)
            NUI.FirstConnect = false
        else
            TriggerServerEvent("server:yaca:wsReady", NUI.FirstConnect)
        end

        print("[YACA-Websocket]: connected")
    end)

    RegisterNUICallback("YACA_OnDisconnected", function(data, cb)
        NUI.WebsocketConnected = false

        print("[YACA-Websocket]: client disconnected", data.code, data.reason)
    end)

    RegisterNUICallback("YACA_OnNuiReady", function(data, cb)
        NUI.WebsocketReady = true
        print("[YACA-Websocket]: NUI ready")

        TriggerServerEvent('server:yaca:nuiReady')
    end)
end

function NUI.SendWSMessage(msg)
    if not NUI.WebsocketReady then
        return print("[Voice-Websocket]: No websocket created")
    end

    if not NUI.WebsocketConnected then
        return print("[Voice-Websocket]: Websocket not connected")
    end

    local nuiMessage = {
        Function = "runCommand",
        Params = json.encode(msg)
    }

    SendNuiMessage(json.encode(nuiMessage))
end

return NUI