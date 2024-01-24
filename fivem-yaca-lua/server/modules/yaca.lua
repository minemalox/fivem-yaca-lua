local playerVoiceSettings = {}
local playerVoicePlugin = {}
local playerRadioSetting = {}

local YaCAServer = {}

function YaCAServer.connectToVoice()
    local src = source

    local name = Utils.generateRandomName(src)
    if not name then
        return
    end

    playerVoiceSettings[src] = {
        voiceRange = Settings.DefaultVoiceRange,
        voiceFirstConnect = true,
        forceMuted = false,
        ingameName = name,
        mutedOnPhone = false,
    }

    playerRadioSetting[src] = {
        activated = false,
        currentChannel = 1,
        hasLong = false,
        frequencies = {}
    }

    YaCAServer.connect(src)
end

function YaCAServer.connect(source)
    if not playerVoiceSettings[source] then
        lib.print.error("YaCA: connect: missing playerVoiceSettings", source)
        return
    end

    playerVoiceSettings[source].voiceFirstConnect = true

    TriggerClientEvent("client:yaca:init", source, {
        suid = ServerSettings.uniqueServerId,
        chid = ServerSettings.ingameChannelId,
        deChid = ServerSettings.defaultChannelId,
        channelPassword = ServerSettings.ingameChannelPassword,
        ingameName = playerVoiceSettings[source].ingameName,
        useWhisper = ServerSettings.useWhisper,
        excludedChannels = ServerSettings.excludedChannels,
    })
end

function YaCAServer.addNewPlayer(clientId)
    local src = source

    if not clientId then
        lib.print.error("YaCA: addNewPlayer: missing clientId")
        return
    end

    --[[
        Player(src).state.yaca = {
            clientId = clientId,
            forceMuted = playerVoiceSettings[src].forceMuted,
            range = playerVoiceSettings[src].voiceRange,
            isTalking = false,
            phoneCallMemberIds = playerVoiceSettings[src].phoneCallMemberIds,
            mutedOnPhone = playerVoiceSettings[src].mutedOnPhone
        }
    ]]

    playerVoicePlugin[src] = {
        playerId = src,
        clientId = clientId,
        forceMuted = playerVoiceSettings[src].forceMuted,
        range = playerVoiceSettings[src].voiceRange,
        phoneCallMemberIds = playerVoiceSettings[src].phoneCallMemberIds,
        mutedOnPhone = playerVoiceSettings[src].mutedOnPhone,
    }

    TriggerClientEvent("client:yaca:addPlayers", -1, playerVoicePlugin[src])

    local allPlayersData = {}
    for _, playerSource in pairs(GetPlayers()) do
        if not playerVoicePlugin[playerSource] or playerSource == src then
            goto continue
        end

        allPlayersData[#allPlayersData + 1] = playerVoicePlugin[playerSource]

        ::continue::
    end

    TriggerClientEvent("client:yaca:addPlayers", src, allPlayersData)
end

function YaCAServer.handlePlayerDisconnect()
    local src = source

    if not playerVoiceSettings[src] then
        return
    end

    Utils.removeGeneratedName(playerVoiceSettings[src].ingameName)

    -- TODO: remove player from all radio channels

    playerVoiceSettings[src] = nil
    TriggerClientEvent("client:yaca:disconnect", -1, src)
end

function YaCAServer.wsReady()
    local src = source

    if not playerVoiceSettings[src] or not playerVoiceSettings[src].voiceFirstConnect then
        return
    end

    YaCAServer.connect(src)
end

function YaCAServer.changeVoiceRange(rangeIndex)
    local src = source

    if not playerVoiceSettings[src] then
        return
    end

    local range = Settings.VoiceRanges[rangeIndex] or 1

    playerVoiceSettings[src].voiceRange = range
    TriggerClientEvent("client:yaca:changeVoiceRange", -1, range)

    if not playerVoicePlugin[src] then
        return
    end

    playerVoicePlugin[src].range = range
end

function YaCAServer.useMegaphone(state)
    local src = source

    local megaphoneState = Player(src).state['yaca_megaphone']
    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle then
        return
    end

    local isFrontSeat = GetPedInVehicleSeat(vehicle, -1) == ped or GetPedInVehicleSeat(vehicle, 0) == ped

    if not isFrontSeat then
        return
    end

    if (not state and not megaphoneState) or (state and megaphoneState) then
        return
    end

    Player(src).state:set('yaca_megaphone', state and Settings.MegaphoneRange or nil, true)
end

function YaCAServer.changePlayerAliveStatus(isAlive)
    local src = source

    if not playerVoiceSettings[src] then
        return
    end

    playerVoiceSettings[src].forceMuted = not isAlive
    TriggerClientEvent("client:yaca:forceMuteClient", -1, src, playerVoiceSettings[src].forceMuted)
end

return YaCAServer