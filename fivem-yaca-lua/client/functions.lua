
function SetPlayersCommType(players,type,state,channel,range,bidirectional)

    if type(players) ~= 'table' then
        print("[Yaca Voice] players is not a table!!")
        return
    end 

    if not #players > 0 then
        print("[Yaca Voice] list hase no entitys")
        return
    end

    let protocol = {
        on: state,
        com_type: type,
        client_ids: players 
    }


    if Config.voice_use_whisper then
        protocol.bidirectional = bidirectional 
    end

    if range != nil then protocol.range = range end
    if channel != nil then protocol.channel = channel end

    SendNuiMessage({
        actionCMD = "sendCommType",
        protocol = protocol
    })
end