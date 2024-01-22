local allPlayers = {}

local YaCA = {}

local useWhisper = false
local firstConnect = true


function YaCA.init(data)
    if firstConnect then
        YaCA.initRequest(data)
        firstConnect = false
    else
        TriggerServerEvent('server:yaca:wsReady')
    end
    
    lib.print.info('[YaCA-Websocket]: connected')
end

function YaCA.initRequest(data)
    if not data or not data.suid or not data.chid or not data.deChid or not data.ingameName or not data.channelPassword then
        return print("YaCA: initRequest: missing data") --TODO: error handling
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INIT",
        },
        server_guid = data.suid,
        ingame_name = data.ingameName,
        ingame_channel = data.chid,
        default_channel = data.deChid,
        ingame_channel_password = data.channelPassword,
        exclude_channels = data.excludedChannels,
        muffling_range = Settings.mufflingRange,
        build_type = YacaBuildType.RELEASE,
        unmute_delay = Settings.unmuteDelay,
        operation_mode = data.useWhisper and 1 or 0,
    })

    useWhisper = data.useWhisper
end

function YaCA.initConnection(data)
    -- TODO: range interval

    NUI.connect(function ()
        YaCA.initNui(data)
    end,
    function (errorCode, reason)
        lib.print.info('[YaCA-Websocket]: disconnected', errorCode, reason)
    end,
    function (data)
        YaCA.handleResponse(data)
    end,
    function (data)
        lib.print.error('[YaCA-Websocket]: Error: ', data)
    end)

    -- TODO: monitor if player is in ingame voice channel

    if firstConnect then
        return
    end

    YaCA.initRequest(data)
end

function YaCA.handleResponse(payload)
    if not payload then
        return
    end

    local success, data = pcall(json.decode, payload)

    if not success then
        lib.print.error('[YaCA-Websocket]: Error while parsing message: ', data)
        return
    end

    if payload.code == "OK" then
        if payload.requestType == "JOIN" then
            TriggerServerEvent("server:yaca:addPlayer", tonumber(payload.message))

            -- TODO: Range interval neustarten

            -- TODO: Set radio sett
            return
        end

        return
    end

    if payload.code == "TALK_STATE" or payload.code == "MUTE_STATE" then
        YaCA.handleTalkState(data)
        return
    end

    local message = locale(payload.code) or "Unknown error!"
    if not locale(payload.code) then
        lib.print.error('[YaCA-Websocket]: Unknown error code: ', payload.code)
    end
    if #message < 1 then
        return
    end

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("YaCA:" .. message)
    ThefeedSetNextPostBackgroundColor(6)
    EndTextCommandThefeedPostTicker(false, false)
end

function YaCA.handleTalkState(payload)
    -- TODO: handle talk states
end

function YaCA.getPlayerByID(playerId)
    return allPlayers[playerId]
end

function YaCA.addPlayers(dataObjects)
    if type(dataObjects) ~= "table" then
        dataObjects = { dataObjects }
    end

    for _, data in pairs(dataObjects) do
        if not data or not data.range or not data.clientId or not data.playerId then
            goto continue
        end

        local currentData = YaCA.getPlayerByID(data.playerId)

        allPlayers[data.playerId] = {
            remoteID = data.playerId,
            clientID = data.clientId,
            forceMuted = data.forceMuted,
            range = data.range,
            isTalking = false,
            phoneCallMemberIds = currentData?.phoneCallMemberIds or nil,
            mutedOnPhone = data.mutedOnPhone,
        }

        :: continue ::
    end
end

function YaCA.playerDisconnected(playerId)
    if not playerId then
        return
    end

    allPlayers[playerId] = nil
end

function YaCA.calcPlayers()
    local players = {}
    local allPlayers = GetActivePlayers()
    local localPos = GetEntityCoords(cache.ped)
    local currentRoom = GetRoomKeyFromEntity(cache.ped)

    local localData = YaCA.getPlayerByID(cache.serverId)
    if not localData then
        return
    end

    for _, playerId in pairs(allPlayers) do
        if playerId == cache.serverId then
            goto continue
        end

        local playerPed = GetPlayerPed(playerId)
        local playerSource = GetPlayerServerId(playerId)

        local voiceSetting = YaCA.getPlayerByID(playerSource)
        if not voiceSetting or not voiceSetting.clientId then
            goto continue
        end

        local muffleIntensity = 0
        if currentRoom ~= GetRoomKeyFromEntity(playerPed) and not HasEntityClearLosToEntity(cache.ped, playerPed, 17) then
            muffleIntensity = 10 -- 10 is the maximum intensity
        end

        players[#players + 1] = {
            client_id = voiceSetting.clientId,
            position = GetEntityCoords(playerPed),
            direction = GetEntityForwardVector(playerPed),
            range = voiceSetting.range,
            is_underwater = IsPedSwimmingUnderWater(playerPed),
            muffle_intensity = muffleIntensity,
            is_muted = voiceSetting.forceMuted
        }

        :: continue ::
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INGAME",
        },
        player = {
            player_direction = Utils.getCamDirection(),
            player_position = localPos,
            player_range = localData.range,
            player_is_underwater = IsPedSwimmingUnderWater(cache.ped),
            player_is_muted = localData.forceMuted,
            players_list = players,
        }
    })
end

return YaCA