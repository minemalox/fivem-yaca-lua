local allPlayers = {}

local YaCA = {}

local useWhisper = false
local firstConnect = true

local yacaPluginLocal = {
    canChangeVoiceRange = true,

    lastMegaphoneState = false,
    canUseMegaphone = false,
}

YaCA.webSocketStarted = false

function YaCA.init(data)
    lib.print.info('[YaCA-Websocket]: Connected! FirstConnect: ' .. tostring(firstConnect))

    if firstConnect then
        firstConnect = false
        YaCA.initRequest(data)
    else
        TriggerServerEvent('server:yaca:wsReady')
    end
end

function YaCA.initRequest(data)
    if not data or not data.suid or not data.chid or not data.deChid or not data.ingameName or not data.channelPassword then
        return lib.print.error("YaCA: initRequest: missing data") --TODO: error handling
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
        excluded_channels = data.excludedChannels,
        muffling_range = Settings.mufflingRange,
        build_type = YacaBuildType.RELEASE,
        unmute_delay = Settings.unmuteDelay,
        operation_mode = data.useWhisper and 1 or 0,
    })

    useWhisper = data.useWhisper
end

function YaCA.initConnection(dataObj)
    -- TODO: range interval

    if not YaCA.webSocketStarted then
        YaCA.webSocketStarted = true

        NUI.connect(function ()
            YaCA.init(dataObj)
        end,
        function (errorCode, reason)
            lib.print.info('[YaCA-Websocket]: Disconnected! Code: ' ..  errorCode .. " Reason: " .. reason)
        end,
        function (data)
            YaCA.handleResponse(data)
        end,
        function (data)
            lib.print.error('[YaCA-Websocket]: Error: ', data)
        end)
    end
    -- TODO: monitor if player is in ingame voice channel

    if firstConnect then
        return
    end

    YaCA.initRequest(dataObj)
end

function YaCA.handleResponse(payload)
    if not payload then
        return
    end

    if payload.code ~= "HEARTBEAT" and payload.code ~= "WAIT_GAME_INIT" then
        lib.print.verbose('[YaCA-Websocket] Message: ', payload.code, payload.message)
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
        YaCA.handleTalkState(payload)
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

--[[ function YaCA.addPlayers(dataObjects)
    if not dataObjects[1] then
        dataObjects = { dataObjects }
    end

    for _, data in pairs(dataObjects) do
        if not data or not data.range or not data.clientId or not data.playerId then
            goto continue
        end

        local currentData = YaCA.getPlayerByID(data.playerId)

        allPlayers[data.playerId] = {
            remoteId = data.playerId,
            clientId = data.clientId,
            forceMuted = data.forceMuted,
            range = data.range,
            isTalking = false,
            phoneCallMemberIds = currentData?.phoneCallMemberIds or nil,
            mutedOnPhone = data.mutedOnPhone,
        }

        :: continue ::
    end
end ]]

function YaCA.playerDisconnected(playerId)
    if not playerId then
        return
    end

    allPlayers[playerId] = nil
end

function YaCA.calcPlayers()
    local players = {}
    local localPos = GetEntityCoords(cache.ped)
    local currentRoom = GetRoomKeyFromEntity(cache.ped)

    local localData = Statebags.getLocalData()
    if not localData then
        return
    end

    for _, playerId in pairs(GetActivePlayers()) do
        if playerId == cache.playerId then
            goto continue
        end

        local playerSource = GetPlayerServerId(playerId)
        
        local playerState = Statebags.getPlayerData(playerSource)
        if not playerState or not playerState.clientId then
            goto continue
        end
        
        local playerPed = GetPlayerPed(playerId)

        local muffleIntensity = 0
        if currentRoom ~= GetRoomKeyFromEntity(playerPed) and not HasEntityClearLosToEntity(cache.ped, playerPed, 17) then
            muffleIntensity = 10 -- 10 is the maximum intensity
        end

        players[#players + 1] = {
            client_id = playerState.clientId,
            position = GetEntityCoords(playerPed),
            direction = GetEntityForwardVector(playerPed),
            range = Settings.VoiceRanges[playerState.range] or 1,
            is_underwater = IsPedSwimmingUnderWater(playerPed),
            muffle_intensity = muffleIntensity,
            is_muted = playerState.forceMuted
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
            player_range = Settings.VoiceRanges[localData.range] or 1,
            player_is_underwater = IsPedSwimmingUnderWater(cache.ped),
            player_is_muted = localData.forceMuted,
            players_list = players,
        }
    })
end

local visualVoiceRangeTick = false
local rangeIndex = Settings.DefaultVoiceRange

function YaCA.changeVoiceRange(toggle)
    if not yacaPluginLocal.canChangeVoiceRange then
        return false
    end

    if visualVoiceRangeTick then
        visualVoiceRangeTick = false
    end

    rangeIndex += toggle

    if rangeIndex < 1 then
        rangeIndex = #Settings.VoiceRanges
    elseif rangeIndex > #Settings.VoiceRanges then
        rangeIndex = 1
    end

    local voiceRange = Settings.VoiceRanges[rangeIndex] or 1

    CreateThread(function()
        visualVoiceRangeTick = true
        while visualVoiceRangeTick do
            local pos = GetEntityCoords(cache.ped)
            DrawMarker(1, pos.x, pos.y, pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, (voiceRange * 2.0) - 1.0, (voiceRange * 2.0) - 1.0, 1.0, 136, 0, 255, 255, false, false, 0, false, nil, nil, false)
            Wait(0)
        end
    end)

    SetTimeout(5000, function ()
        visualVoiceRangeTick = false
    end)

    print("Voice Range: " .. voiceRange .. "m")
    -- TriggerServerEvent("server:yaca:changeVoiceRange", voiceRange)

    Statebags.setLocalData("range", rangeIndex)

    return true
end

return YaCA