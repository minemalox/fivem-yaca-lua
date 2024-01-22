local yacaPluginLocal = {
    canChangeVoiceRange = true,
    maxVoiceRange = 6,

    lastMegaphoneState = false,
    canUseMegaphone = false,
}

local playerYacaPlugin = {}

local lipsyncAnims = {
    [true] = {
        name = "mic_chatter",
        dict = "mp_facial"
    },
    [false] = {
        name = "mood_normal_1",
        dict = "facials@gen_male@variations@normal"
    }
}

-- Values are in meters
local voiceRangesEnum = {
    [1] = 1,
    [2] = 3,
    [3] = 8,
    [4] = 15,
    [5] = 32,
    [6] = 64
}

local translations = {
    plugin_not_activated = "Please activate your voiceplugin!",
    connect_error = "Error while connecting to voiceserver, please reconnect!",
    plugin_not_initializiaed = "Plugin not initialized!",

    -- Error message which comes from the plugin
    OUTDATED_VERSION = "You dont use the required plugin version!",
    WRONG_TS_SERVER = "You are on the wrong teamspeakserver!",
    NOT_CONNECTED = "You are on the wrong teamspeakserver!",
    MOVE_ERROR = "Error while moving into ingame teamspeak channel!",
    WAIT_GAME_INIT = "",
    HEARTBEAT = ""
}

local rangeInterval = nil
local monitorInterval = nil
local websocket = nil
local noPluginActivated = 0
local messageDisplayed = false
local visualVoiceRangeTimeout = nil
local visualVoiceRangeTick = false
local uirange = 2
local lastuiRange = 2
local isTalking = false
local firstConnect = true
local isPlayerMuted = false

local radioFrequenceSetted = false
local radioToggle = false
local radioEnabled = false
local radioTalking = false
local radioChannelSettings = {}
local radioInited = false
local activeRadioChannel = 1
local playersWithShortRange = {}
local playersInRadioChannel = {}

local readyState = 3
local storedDataObj = nil

function initRequest(dataObj)
    if not dataObj or not dataObj.suid or type(dataObj.chid) ~= "number" or not dataObj.deChid or not dataObj.ingameName or not dataObj.channelPassword then
        print("YACA: Invalid init request")
        return
    end

    sendWebsocket({
        base = {
            ["request_type"] = "INIT"
        },
        server_guid = dataObj.suid,
        ingame_name = dataObj.ingameName,
        ingame_channel = dataObj.chid,
        default_channel = dataObj.deChid,
        ingame_channel_password = dataObj.channelPassword,
        excluded_channels = Settings["EXCLUDED_CHANNELS"], -- Channel ID's where users can be in while being ingame
        --[[
         * default are 2 meters
         * if the value is set to -1, the player voice range is taken
         * if the value is >= 0, you can set the max muffling range before it gets completely cut off
        ]]
        muffling_range = 2,
        build_type = YacaBuildType.RELEASE, -- 0 = Release, 1 = Debug,
        unmute_delay = 400,
        operation_mode = dataObj.useWhisper and 1 or 0,
    })
end

function clamp(value, min, max)
    min = min or 0
    max = max or 1

    return math.max(min, math.min(value, max))
end

function isCommTypeValid(type)
    local valid = YacaFilterEnum[type]
    if not valid then
        print("[YaCA-Websocket]: Invalid commtype: " .. type)
    end

    return valid ~= nil
end

function setPlayersCommType(players, type, state, channel, range)
    if not players[0] then
        players = { [players] = true }
    end

    local cids = {}

    for player, _ in ipairs(players) do
        if not playerYacaPlugin[player] then
            goto continue
        end

        cids[#cids + 1] = playerYacaPlugin[player].cid

        ::continue::
    end

    if #cids == 0 then
        return
    end

    local protocol = {
        on = state == true,
        comm_type = type,
        client_ids = cids
    }

    if channel then
        protocol.channel = channel
    end

    if range then
        protocol.range = range
    end

    sendWebsocket({
        base = {
            ["request_type"] = "INGAME"
        },
        comm_device = protocol
    })
end

function setCommDeviceVolume(type, volume, channel)
    if not isCommTypeValid(type) then
        return
    end

    local protocol = {
        comm_type = type,
        volume = clamp(volume, 0, 1)
    }

    if channel then
        protocol.channel = channel
    end

    sendWebsocket({
        base = {
            ["request_type"] = "INGAME"
        },
        comm_device_settings = protocol
    })
end

function setCommDeviceStereomode(type, mode, channel)
    if not isCommTypeValid(type) then
        return
    end

    local protocol = {
        comm_type = type,
        output_mode = mode
    }

    if channel then
        protocol.channel = channel
    end

    sendWebsocket({
        base = {
            ["request_type"] = "INGAME"
        },
        comm_device_settings = protocol
    })
end

function initRadioSettings()
    for i = 1, Settings.maxRadioChannels, 1 do
        if radioChannelSettings[i] then
            radioChannelSettings[i] = {
                volume = 1,
                stereo = YacaStereoMode.STEREO,
                muted = false,
                frequency = 0,
            }
        end

        if not playersInRadioChannel[i] then
            playersInRadioChannel[i] = {}
        end

        local volume = radioChannelSettings[i].volume
        local stereo = radioChannelSettings[i].stereo

        setCommDeviceStereomode(YacaFilterEnum.RADIO, stereo, i);
        setCommDeviceVolume(YacaFilterEnum.RADIO, volume, i);
    end
end

function handleTalkState(payload)
    local localIsTalking = tonumber(payload.message) == 1

    if payload.code == "MUTE_STATE" then
        isPlayerMuted = tonumber(payload.message) == 1
        -- this.webview.emit('webview:hud:voiceDistance', this.isPlayerMuted ? 0 : voiceRangesEnum[this.uirange]);
    end

    if isTalking ~= localIsTalking then
        isTalking = localIsTalking

        if payload.code ~= "MUTE_STATE" then
            -- this.webview.emit('webview:hud:isTalking', isTalking);
        end

        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 40.0, false)

        local playerIdsNear = {}
        for _, value in pairs(nearbyPlayers) do
            playerIdsNear[#playerIdsNear + 1] = GetPlayerServerId(value.id)
        end

        syncLipsPlayer(cache.serverId, isTalking)

        if #playerIdsNear ~= 0 then
            TriggerServerEvent("server:yaca:lipsync", isTalking, playerIdsNear)
        end
    end
end

function handleResponse(payload)
    if not payload then
        return
    end

    if payload.code == "OK" then
        if payload.requestType == "JOIN" then
            TriggerServerEvent("server:yaca:addPlayer", tonumber(payload.message))

            if rangeInterval then
                rangeInterval = false
                Wait(300)
            end

            CreateThread(calcPlayers)

            if radioInited then
                initRadioSettings()
            end
        end

        return
    end

    if payload.code == "TALK_STATE" or payload.code == "MUTE_STATE" then
        handleTalkState(payload)
        return
    end

    print(json.encode(payload))
    local message = translations[payload.code] or ("Unknown error!" .. (payload?.code and " (" .. payload.code .. ")" or ""))

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName('Voice: ' .. message)
    ThefeedSetNextPostBackgroundColor(6)
    EndTextCommandThefeedPostTicker(false, false)
end

function disableRadioFromPlayerInChannel(channel)
    if not playersInRadioChannel[channel] then
        return
    end

    local players = playersInRadioChannel[channel]
    if players and not next(players) then
        return
    end

    local targets = {}
    for _, playerId in pairs(players) do
        targets[#targets + 1] = playerId
        players[playerId] = nil
    end

    if next(targets) then
        setPlayersCommType(targets, YacaFilterEnum.RADIO, false, channel)
    end
end

RegisterNetEvent("client:yaca:init", function(dataObj)
    print("[YaCA-Websocket]: Init")

    if rangeInterval then
        rangeInterval = false
        Wait(300)
    end

    SendNuiMessage(json.encode({
        Function = "connect",
        Params = "lh.v10.network:30125"
    }))

    storedDataObj = dataObj

    if firstConnect then
        return
    end

    initRequest(dataObj)
end)

RegisterNetEvent('client:yaca:addPlayers', function(dataObjects)
    if not dataObjects[0] then
        dataObjects = { dataObjects }
    end

    print("[YaCA-Websocket]: Add players", json.encode(dataObjects))
    for _, dataObj in pairs(dataObjects) do
        print("[YaCA-Websocket]: Add player", json.encode(dataObj))
        if not dataObj or not dataObj.range or not dataObj.cid or not dataObj.playerId then
            goto continue
        end

        playerYacaPlugin[dataObj.playerId] = {
            radioEnabled = playerYacaPlugin[dataObj.playerId]?.radioEnabled or false,
            cid = dataObj.cid,
            muted = dataObj.muted,
            range = dataObj.range,
            isTalking = false,
            phoneCallMemberIds = playerYacaPlugin[dataObj.playerId]?.phoneCallMemberIds or {},
        }

        :: continue ::
    end
end)

RegisterNetEvent("client:yaca:muteTarget", function(target, muted)
    if playerYacaPlugin[target] then
        playerYacaPlugin[target].muted = muted
    end
end)

RegisterNetEvent("client:yaca:changeVoiceRange", function(target, range)
    if target == cache.serverId and not isPlayerMuted then
        -- TODO: NUI Event
    end

    if playerYacaPlugin[target] then
        playerYacaPlugin[target].range = range
    end
end)

RegisterNetEvent("client:yaca:setMaxVoiceRange", function(maxRange)
    yacaPluginLocal.maxVoiceRange = maxRange

    if maxRange == 64 then
        uirange = 6
        lastuiRange = 6
    end
end)

function syncLipsPlayer(id, isTalking)
    local player = GetPlayerFromServerId(id)
    local ped = GetPlayerPed(player)

    if not ped then
        return
    end

    local animationData = lipsyncAnims[isTalking]

    SetPlayerTalkingOverride(player, isTalking)
    PlayFacialAnim(ped, animationData.name, animationData.dict)

    if playerYacaPlugin[id] then
        playerYacaPlugin[id].isTalking = isTalking
    end
end

RegisterNetEvent('client:yaca:lipsync', function(id, isTalking)
    syncLipsPlayer(id, isTalking)
end)

--[[ RegisterNetEvent('client:yaca:setRadioFreq', function(channel, frequency)
    radioFrequenceSetted = true

    if (radioChannelSettings[channel].frequency ~= frequency) then
        disableRadioFromPlayerInChannel(channel)
    end

    radioChannelSettings[channel].frequency = frequency
end) ]]



function calcPlayers()
    rangeInterval = true
    while rangeInterval do
        local players = {}
        local localPos = GetEntityCoords(cache.ped)

        for _, player in pairs(GetActivePlayers()) do
            local playerId = GetPlayerServerId(player)

            if cache.playerId == player then
                goto continue
            end

            local voiceSetting = playerYacaPlugin[playerId]

            if not voiceSetting?.cid or voiceSetting.muted then
                goto continue
            end

            local playerPed = GetPlayerPed(player)
            players[#players + 1] = {
                client_id = voiceSetting.cid,
                position = GetEntityCoords(playerPed),
                direction = GetEntityForwardVector(playerPed),
                range = voiceSetting.range,
                room = GetRoomKeyFromEntity(playerPed),
                is_underwater = IsPedSwimmingUnderWater(playerPed),
                intersect = HasEntityClearLosToEntity(cache.ped, playerPed, 17) == true
            }

            if voiceSetting.phoneCallMemberIds then
                local applyPhoneSpeaker = {}
                local phoneSpeakerRemove = {}

                for _, phoneCallMemberId in pairs(voiceSetting.phoneCallMemberIds) do
                    local playerState = Player(playerId).state

                    local playerPed = GetPlayerPed(phoneCallMemberId)
                    local targetCoords = GetEntityCoords(playerPed)

                    if playerState['yaca:isMutedOnPhone'] or #(localPos - targetCoords) > Settings.maxPhoneSpeakerRange then
                        if applyPhoneSpeaker[phoneCallMemberId] then
                            phoneSpeakerRemove[phoneCallMemberId] = phoneCallMemberId
                        end
                    end

                    local phoneCallMemberYacaPlugin = playerYacaPlugin[phoneCallMemberId]

                    players[#players + 1] = {
                        client_id = phoneCallMemberYacaPlugin.cid,
                        position = targetCoords,
                        direction = GetEntityForwardVector(playerPed),
                        range = Settings.maxPhoneSpeakerRange,
                        room = GetRoomKeyFromEntity(playerPed),
                        is_underwater = IsPedSwimmingUnderWater(playerPed),
                        intersect = HasEntityClearLosToEntity(cache.ped, playerPed, 17)
                    }

                    if phoneSpeakerRemove[phoneCallMemberId] then
                        phoneSpeakerRemove[phoneCallMemberId] = nil
                        applyPhoneSpeaker[phoneCallMemberId] = phoneCallMemberId
                    end
                end

                if next(applyPhoneSpeaker) then
                    setPlayersCommType(applyPhoneSpeaker, YacaFilterEnum.PHONE_SPEAKER, true)
                end

                if next(phoneSpeakerRemove) then
                    setPlayersCommType(phoneSpeakerRemove, YacaFilterEnum.PHONE_SPEAKER, false)
                end
            end

            :: continue ::
        end

        -- Send collected data to ts-plugin.
        sendWebsocket({
            base = {
                request_type = "INGAME",
            },
            player = {
                player_direction = getCamDirection(),
                player_position = localPos,
                player_room = GetRoomKeyFromEntity(cache.ped),
                player_is_underwater = IsPedSwimmingUnderWater(cache.ped),
                players_list = players
            }
        })
        Wait(250)
    end
end

function changeVoiceRange(toggle)
    if not yacaPluginLocal.canChangeVoiceRange then
        return false
    end

    if visualVoiceRangeTick then
        visualVoiceRangeTick = false
    end

    uirange += toggle

    if uirange < 1 then
        uirange = 6
    elseif uirange > yacaPluginLocal.maxVoiceRange then
        uirange = 1
    end

    if lastuiRange == uirange then
        return false
    end

    lastuiRange = uirange

    local voiceRange = voiceRangesEnum[uirange] or 1

    CreateThread(function()
        visualVoiceRangeTick = true
        while visualVoiceRangeTick do
            local pos = GetEntityCoords(cache.ped)
            DrawMarker(1, pos.x, pos.y, pos.z - 0.98, 0, 0, 0, 0, 0, 0, (voiceRange * 2) - 1, (voiceRange * 2) - 1, 1, 136, 0, 255, 255, false, false, 0, false, nil, nil, false)
            Wait(0)
        end
    end)

    SetTimeout(5000, function ()
        visualVoiceRangeTick = false
    end)

    print("Voice Range: " .. voiceRange .. "m")
    TriggerServerEvent("server:yaca:changeVoiceRange", voiceRange)

    return true
end

RegisterCommand('yaca:changeVoiceRange', function ()
    changeVoiceRange(1)
end, false)

RegisterKeyMapping('yaca:changeVoiceRange', 'Sprachreichweite hochschalten', 'keyboard', 'Z')

function useMegaphone(state)
    if (not cache.vehicle and not yacaPluginLocal.canUseMegaphone) or state == yacaPluginLocal.lastMegaphoneState then
        return
    end

    yacaPluginLocal.lastMegaphoneState = not yacaPluginLocal.lastMegaphoneState

    TriggerServerEvent("server:yaca:useMegaphone", state)
end

RegisterCommand('+yaca:megaphone', function ()
    useMegaphone(true)
end, false)

RegisterCommand('-yaca:megaphone', function ()
    useMegaphone(false)
end, false)

RegisterKeyMapping('+yaca:megaphone', 'Megaphone benutzen', 'keyboard', 'X')

RegisterNetEvent('client:yaca:changeMegafonState', function(state)
    yacaPluginLocal.lastMegaphoneState = state
end)

function setPlayerVariable(source, variable, value)
    if not playerYacaPlugin[source] then
        playerYacaPlugin[source] = {}
    end

    playerYacaPlugin[source][variable] = value
end

AddStateBagChangeHandler('yaca:megaphoneactive', '', function (bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)

    setPlayersCommType(entity, YacaFilterEnum.MEGAPHONE, value ~= nil, nil, value)
end)

AddStateBagChangeHandler('yaca:radioEnabled', '', function (bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)

    setPlayerVariable(entity, "radioEnabled", value)
end)

AddStateBagChangeHandler('yaca:phoneSpeaker', '', function (bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    
    -- TODO: check if player is in phone call
end)