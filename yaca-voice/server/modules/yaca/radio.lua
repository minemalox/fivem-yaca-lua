
local playerRadioSetting = {}

local YaCARadio = {}

YaCARadio.radioFrequenceMap = {}

function YaCARadio.initRadioSettings(source)
    playerRadioSetting[source] = {
        activated = false,
        currentChannel = 1,
        hasLong = false,
        frequencies = {}
    }
end

function YaCARadio.isLongRadioPermitted(source)
    playerRadioSetting[source].hasLong = true
end

function YaCARadio.enableRadio(state)
    local src = source

    playerRadioSetting[src].activated = state
    YaCARadio.isLongRadioPermitted(src)
end

function YaCARadio.changeRadioFrequency(channel, frequency)
    local src = source

    if not playerRadioSetting[src].activated then
        return TriggerClientEvent("ox_lib:notify", src, {
            title = locale('notify_title'),
            description = locale('radio_not_activated'),
            type = 'error',
        })
    end

    channel = tonumber(channel)

    if not channel or channel < 1 or channel > Settings.MaxRadioChannels then
        return TriggerClientEvent("ox_lib:notify", src, {
            title = locale('notify_title'),
            description = locale('radio_channel_not_found'),
            type = 'error',
        })
    end

    if frequency == "0" then
        YaCAServerRadio.leaveRadioFrequency(src, channel, frequency)
    end

    if playerRadioSetting[src].frequencies[channel] == frequency then
        YaCAServerRadio.leaveRadioFrequency(src, channel, playerRadioSetting[src].frequencies[channel])
    end

    if not YaCARadio.radioFrequenceMap[frequency] then
        YaCARadio.radioFrequenceMap[frequency] = {}
    end

    YaCARadio.radioFrequenceMap[frequency][src] = { muted = false }

    playerRadioSetting[src].frequencies[channel] = frequency

    TriggerClientEvent("client:yaca:setRadioFreq", src, channel, frequency)
    -- TODO: Add radio effect to player in new frequency
end

function YaCARadio.leaveRadioFrequency(source, channel, frequency)
    frequency = frequency == "0" and playerRadioSetting[source].frequencies[channel] or frequency

    if YaCARadio.radioFrequenceMap[frequency] then
        return
    end

    local allPlayersInChannel = YaCARadio.radioFrequenceMap[frequency]

    playerRadioSetting[source].frequencies[channel] = "0"

    if ServerSettings.useWhisper then
        local allTargets = {}

        for _, playerId in pairs(allPlayersInChannel) do
            if playerId ~= source then
                allTargets[#allTargets + 1] = playerId
            end
        end

        TriggerClientEvent("client:yaca:radioTalking", source, allTargets, frequency, false, nil, true)
    else
        for _, target in pairs(allPlayersInChannel) do
            TriggerClientEvent("client:yaca:leaveRadioChannel", target, YaCAServerMain.getPlayerPlugin(source), frequency)
        end
    end

    allPlayersInChannel[source] = nil

    if #YaCARadio.radioFrequenceMap[frequency] == 0 then
        YaCARadio.radioFrequenceMap[frequency] = nil
    end
end

function YaCARadio.radioChannelMute(channel)
    local src = source

    local radioFrequency = playerRadioSetting[src].frequencies[channel]
    local foundPlayer = YaCARadio.radioFrequenceMap[radioFrequency][src]
    if not foundPlayer then
        return
    end

    foundPlayer.muted = not foundPlayer.muted

    TriggerClientEvent("client:yaca:setRadioMuteState", src, channel, foundPlayer.muted)
end

function YaCARadio.radioActiveChannelChange(channel)
    local src = source

    if not tonumber(channel) or channel < 1 or channel > Settings.MaxRadioChannels then
        return
    end

    playerRadioSetting[src].currentChannel = channel
end

function YaCARadio.radioTalkingState(state)
    local src = source

    local radioSettings = playerRadioSetting[src]

    if not radioSettings?.activated then
        return
    end

    local radioFrequency = radioSettings?.frequencies[radioSettings?.currentChannel]
    if not radioFrequency then
        return
    end
    
    local getPlayers = YaCARadio.radioFrequenceMap[radioFrequency]

    local targets = {}
    local targetsToSender = {}
    local radioInfos = {}

    for key, values in pairs(getPlayers) do
        if values.muted then
            if key == src then
                targets = {}
                break
            end

            goto continue
        end

        if key == src then
            goto continue
        end

        local targetRadioSettings = playerRadioSetting[key]
        if not targetRadioSettings?.activated then
            goto continue
        end

        local shortRange = not radioSettings?.hasLong and not targetRadioSettings?.hasLong

        if (radioSettings?.hasLong and targetRadioSettings?.hasLong) or shortRange then
            targets[#targets + 1] = key

            radioInfos[key] = {
                shortRange = shortRange
            }

            targetsToSender[#targetsToSender + 1] = key
        end

        :: continue ::
    end

    if #targets > 0 then
        for _, target in pairs(targets) do
            TriggerClientEvent("client:yaca:radioTalking", target, src, radioFrequency, state, radioInfos)
        end
    end

    if ServerSettings.useWhisper then
        TriggerClientEvent("client:yaca:radioTalking", src, targetsToSender, radioFrequency, state, radioInfos, true)
    end
end

return YaCARadio