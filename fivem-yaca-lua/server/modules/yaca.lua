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
        voiceRange = 3,
        voiceFirstConnect = true,
        maxVoiceRangeInMeter = 64,
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
        print("YaCA: addNewPlayer: missing clientId")
        return
    end

    Player(src).state.yaca = {
        clientId = clientId,
        forceMuted = playerVoiceSettings[src].forceMuted,
        range = playerVoiceSettings[src].voiceRange,
        isTalking = false,
        phoneCallMemberIds = playerVoiceSettings[src].phoneCallMemberIds,
        mutedOnPhone = playerVoiceSettings[src].mutedOnPhone,
    }

    --[[  playerVoicePlugin[src] = {
        clientId = clientId,
        forceMuted = playerVoiceSettings[src].forceMuted,
        range = playerVoiceSettings[src].voiceRange,
        playerId = src,
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

    TriggerClientEvent("client:yaca:addPlayers", src, allPlayersData) ]]
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

    if not playerVoiceSettings[src] then
        return
    end

    if not playerVoiceSettings[src].voiceFirstConnect then
        return
    end

    YaCAServer.connect(src)
end

return YaCAServer