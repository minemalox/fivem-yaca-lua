local playerVoiceSettings = {}
local playerVoicePlugin = {}
local playerRadioSetting = {}

local YaCaServer = {}

function YaCaServer.connectToVoice()
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

    YaCaServer.connect(src)
end

function YaCaServer.connect(source)
    if not playerVoiceSettings[source] then
        return
    end

    playerVoiceSettings[source].voiceFirstConnect = true

    TriggerClientEvent("client:yaca:init", source, {
        suid = Settings.uniqueServerId,
        chid = Settings.ingameChannelId,
        deChid = Settings.defaultChannelId,
        channelPassword = Settings.ingameChannelPassword,
        ingameName = playerVoiceSettings[source].ingameName,
        useWhisper = Settings.useWhisper,
        excludedChannels = Settings.excludedChannels,
    })
end

function YaCaServer.addNewPlayer(clientId)
    local src = source

    if not clientId then
        return
    end

    playerVoicePlugin[src] = {
        clientId = clientId,
        forceMuted = playerVoiceSettings[src].forceMuted,
        range = playerVoiceSettings[src].voiceRange,
        playerId = src,
        mutedOnPhone = playerVoiceSettings[src].mutedOnPhone,
    }

    TriggerClientEvent("client:yaca:addPlayers", -1, playerVoicePlugin[src])

    local allPlayersData = {}
    for _, playerSource in pairs(GetPlayers()) do
        if not playerVoicePlugin[src] or playerSource == src then
            goto continue
        end

        allPlayersData[#allPlayersData + 1] = playerVoicePlugin[playerSource]

        ::continue::
    end

    TriggerClientEvent("client:yaca:addPlayers", src, allPlayersData)
end

function YaCaServer.handlePlayerDisconnect()
    local src = source

    if not playerVoicePlugin[src] then
        return
    end

    Utils.removeGeneratedName(playerVoiceSettings[src].ingameName)

    -- TODO: remove player from all radio channels

    TriggerClientEvent("client:yaca:disconnect", -1, playerVoicePlugin[src].playerId)
end

return YaCaServer