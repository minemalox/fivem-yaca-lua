local allPlayers = {}

local YaCAClientModule = {}

local isTalking = false
local firstConnect = true

local YaCAClientModulePluginLocal = {
    canChangeVoiceRange = true,

    lastMegaphoneState = false,
    canUseMegaphone = false,
}
local isPlayerMuted = false

YaCAClientModule.webSocketStarted = false
YaCAClientModule.canUseMegaphone = false
YaCAClientModule.useWhisper = false

LocalPlayer.state:set('yaca_megaphone', false, true)

function YaCAClientModule.init(data)
    lib.print.info('[YaCAClientModule-Websocket]: Connected! FirstConnect: ' .. tostring(firstConnect))

    if firstConnect then
        firstConnect = false
        YaCAClientModule.initRequest(data)
    else
        TriggerServerEvent('server:yaca:wsReady')
    end
end

function YaCAClientModule.initRequest(data)
    if not data or not data.suid or not data.chid or not data.deChid or not data.ingameName or not data.channelPassword then
        return lib.print.error("YaCAClientModule: initRequest: missing data") --TODO: error handling
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

    YaCAClientModule.useWhisper = data.useWhisper
end

function YaCAClientModule.initConnection(dataObj)
    -- TODO: range interval

    if not YaCAClientModule.webSocketStarted then
        YaCAClientModule.webSocketStarted = true

        NUI.connect(function ()
            YaCAClientModule.init(dataObj)
        end,
        function (errorCode, reason)
            lib.print.info('[YaCAClientModule-Websocket]: Disconnected! Code: ' ..  errorCode .. " Reason: " .. reason)
        end,
        function (data)
            YaCAClientModule.handleResponse(data)
        end,
        function (data)
            lib.print.error('[YaCAClientModule-Websocket]: Error: ', data)
        end)
    end
    -- TODO: monitor if player is in ingame voice channel

    if firstConnect then
        return
    end

    YaCAClientModule.initRequest(dataObj)
end

function YaCAClientModule.isPluginInitialized()
    local inited = YaCAClientModule.getPlayerByID(cache.serverId) ~= nil

    if not inited then
        Utils.radarNotification(locale('plugin_not_initialized'))
    end

    return inited
end

function YaCAClientModule.handleResponse(payload)
    if not payload then
        return
    end

    if payload.code ~= "HEARTBEAT" and payload.code ~= "WAIT_GAME_INIT" then
        lib.print.verbose('[YaCAClientModule-Websocket] Message: ', payload.code, payload.message)
    end

    if payload.code == "OK" then
        if payload.requestType == "JOIN" then
            TriggerServerEvent("server:yaca:addPlayer", tonumber(payload.message))

            -- TODO: Range interval neustarten

            if YaCARadio.radioInited then
                YaCARadio.initRadioSettings()
            end
            return
        end

        return
    end

    if payload.code == "TALK_STATE" or payload.code == "MUTE_STATE" then
        YaCAClientModule.handleTalkState(payload)
        return
    end

    local message = locale(payload.code) or "Unknown error!"
    if not locale(payload.code) then
        lib.print.error('[YaCAClientModule-Websocket]: Unknown error code: ', payload.code)
    end
    if #message < 1 then
        return
    end

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("YaCAClientModule: " .. message)
    ThefeedSetNextPostBackgroundColor(6)
    EndTextCommandThefeedPostTicker(false, false)
end

function YaCAClientModule.handleTalkState(payload)
    local localIsTalking = not isPlayerMuted and not not tonumber(payload.message)

    if isTalking ~= localIsTalking then
        isTalking = localIsTalking

        SetPlayerTalkingOverride(cache.playerId, isTalking)

        if isTalking then
            PlayFacialAnim(cache.ped, "mic_chatter", "mp_facial");
        else
            PlayFacialAnim(cache.ped, "mood_normal_1", "facials@gen_male@variations@normal");
        end
    end
end

function YaCAClientModule.getPlayerByID(playerId)
    return allPlayers[tonumber(playerId)]
end

function YaCAClientModule.addPlayers(dataObjects)
    print("addPlayers", json.encode(dataObjects))
    if not dataObjects[1] then
        dataObjects = { dataObjects }
    end

    for _, data in pairs(dataObjects) do
        if not data or not data.range or not data.clientId or not data.playerId then
            goto continue
        end

        local currentData = YaCAClientModule.getPlayerByID(data.playerId)

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
end

function YaCAClientModule.playerDisconnected(playerId)
    if not playerId then
        return
    end

    allPlayers[playerId] = nil
end

function YaCAClientModule.calcPlayers()
    local players = {}
    local localPos = GetEntityCoords(cache.ped)
    local currentRoom = GetRoomKeyFromEntity(cache.ped)

    --[[ local localData = Statebags.getLocalData()
    if not localData then
        return
    end ]]

    local localData = YaCAClientModule.getPlayerByID(cache.serverId)
    if not localData then
        return
    end

    for _, playerId in pairs(GetActivePlayers()) do
        if playerId == cache.playerId then
            goto continue
        end

        local playerSource = GetPlayerServerId(playerId)

        --[[ local playerState = Statebags.getPlayerData(playerSource)
        if not playerState or not playerState.clientId then
            goto continue
        end ]]

        local playerState = YaCAClientModule.getPlayerByID(playerSource)
        if not playerState or not playerState.clientId then
            goto continue
        end

        local playerPed = GetPlayerPed(playerId)

        local muffleIntensity = 0
        if currentRoom ~= GetRoomKeyFromEntity(playerPed) and not HasEntityClearLosToEntity(cache.ped, playerPed, 17) then
            muffleIntensity = 10 -- 10 is the maximum intensity
        end

        local playerCoords = GetEntityCoords(playerPed)
        local forwardVector = GetEntityForwardVector(playerPed)
        local isSwimming = IsPedSwimmingUnderWater(playerPed)

        players[#players + 1] = {
            client_id = playerState.clientId,
            position = playerCoords,
            direction = forwardVector,
            range = playerState.range,
            is_underwater = isSwimming,
            muffle_intensity = muffleIntensity,
            is_muted = playerState.forceMuted
        }

        local phoneCallMemberIds = Player(playerSource).state:get('yaca_phoneSpeaker')
        if not phoneCallMemberIds then
            goto continue
        end

        local applyPhoneSpeaker = {}
        local removePhoneSpeaker = {}

        for _, phoneCallMemberId in pairs(phoneCallMemberIds) do
            local phoneCallMember = YaCAClientModule.getPlayerByID(phoneCallMemberId)
            if not phoneCallMember then
                goto speakerContinue
            end

            if phoneCallMember.mutedOnPhone or phoneCallMember.forceMuted or #(localPos - playerCoords) > Settings.MaxPhoneSpeekerRange then
                if not applyPhoneSpeaker[phoneCallMemberId] then
                    removePhoneSpeaker[phoneCallMemberId] = true
                end
                goto speakerContinue
            end

            players[#players + 1] = {
                client_id = phoneCallMember.clientId,
                position = playerCoords,
                direction = forwardVector,
                range = Settings.MaxPhoneSpeekerRange,
                is_underwater = isSwimming,
            }

            if not removePhoneSpeaker[phoneCallMemberId] then
                removePhoneSpeaker[phoneCallMemberId] = nil
            end
            applyPhoneSpeaker[phoneCallMemberId] = true


            :: speakerContinue ::
        end

        local applyPhoneSpeakerArray = {}
        for index, _ in pairs(applyPhoneSpeaker) do
            applyPhoneSpeakerArray[#applyPhoneSpeakerArray + 1] = index
        end 

        local removePhoneSpeakerArray = {}
        for index, _ in pairs(removePhoneSpeaker) do
            removePhoneSpeakerArray[#removePhoneSpeakerArray + 1] = index
        end

        if #applyPhoneSpeakerArray > 0 then
            YaCAClientModule.setPlayersCommType(applyPhoneSpeakerArray, YacaFilterEnum.PHONE_SPEAKER, true)
        end

        if #removePhoneSpeakerArray > 0 then
            YaCAClientModule.setPlayersCommType(removePhoneSpeakerArray, YacaFilterEnum.PHONE_SPEAKER, false)
        end

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

local visualVoiceRangeTick = false
local rangeIndex = Settings.DefaultVoiceRange

function YaCAClientModule.changeMyVoiceRange(toggle)
    if not YaCAClientModulePluginLocal.canChangeVoiceRange then
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
    TriggerServerEvent("server:yaca:changeVoiceRange", rangeIndex)

    -- Statebags.setLocalData("range", rangeIndex)

    return true
end

function YaCAClientModule.changeVoiceRange(target, range)
    local playerData = YaCAClientModule.getPlayerByID(target)
    if not playerData then
        return
    end

    playerData.range = range
end

function YaCAClientModule.setPlayersCommType(players, commType, state, channel, range, ownMode, otherPlayersMode)
    if type(players) ~= "table" then
        players = { players }
    end

    local cids = {}
    if ownMode then
        cids[#cids + 1] = {
            client_id = YaCAClientModule.getPlayerByID(cache.serverId).clientId,
            mode = ownMode,
        }
    end

    for _, player in pairs(players) do
        local playerData = YaCAClientModule.getPlayerByID(player)
        if not playerData then
            goto continue
        end

        cids[#cids + 1] = {
            client_id = playerData.clientId,
            mode = otherPlayersMode,
        }

        :: continue ::
    end

    local protocal = {
        on = state and true or false,
        comm_type = commType,
        members = cids,
    }

    if channel then
        protocal.channel = channel
    end

    if range then
        protocal.range = range
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INGAME",
        },
        comm_device = protocal,
    })
end

function YaCAClientModule.isCommTypeValid(commType)
    local valid = YacaFilterEnum[commType]
    if not valid then
        lib.print.error("[YaCAClientModule-Websocket]: Invalid commtype: " .. commType)
        return false
    end

    return true
end

function YaCAClientModule.setCommDeviceVolume(commType, volume, channel)
    if not YaCAClientModule.isCommTypeValid(commType) then
        return
    end

    local protocal = {
        comm_type = commType,
        volume = math.clamp(volume, 0, 1),
    }

    if channel then
        protocal.channel = channel
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INGAME",
        },
        comm_device_settings = protocal,
    })
end

function YaCAClientModule.setCommDeviceStereomode(commType, mode, channel)
    if not YaCAClientModule.isCommTypeValid(commType) then
        return
    end

    local protocal = {
        comm_type = commType,
        output_mode = mode,
    }

    if channel then
        protocal.channel = channel
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INGAME",
        },
        comm_device_settings = protocal,
    })
end

function YaCAClientModule.useMegaphone(state)
    state = state or false

    if not cache.vehicle or cache.vehicle == 0 or (cache.seat ~= -1 and cache.seat ~= 0) then
        return
    end

    if not YaCAClientModule.canUseMegaphone or YaCAClientModulePluginLocal.lastMegaphoneState == state then
        return
    end

    YaCAClientModulePluginLocal.lastMegaphoneState = state
    TriggerServerEvent("server:yaca:useMegaphone", state)
end

function YaCAClientModule.muteTarget(target, isMuted)
    local playerData = YaCAClientModule.getPlayerByID(target)

    if not playerData then
        return
    end

    playerData.forceMuted = isMuted
end

function YaCAClientModule.addRemovePlayerIntercomFilter(targetIds, state)
    if type(targetIds) ~= "table" then
        targetIds = { targetIds }
    end

    local players = {}

    for _, targetId in pairs(targetIds) do
        local playerData = YaCAClientModule.getPlayerByID(targetId)

        if playerData then
            players[#players + 1] = targetId
        end
    end

    YaCAClientModule.setPlayersCommType(players, YacaFilterEnum.PHONE_HISTORICAL, state, nil, nil, CommDeviceMode.TRANSCEIVER, CommDeviceMode.TRANSCEIVER)
end

return YaCAClientModule