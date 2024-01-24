local activeRadioChannels = nil
local defaultRadioChannelSettings = {
    volume = 1.0,
    stereo = YacaStereoMode.STEREO,
    muted = false,
    frequency = 0,
}

local radioEnabled = true
local radioChannelSettings = {}
local playersInRadioChannel = {}
local playersWithShortRange = {}
local radioFrequenceSetted = false
local radioTalking = false

local YaCARadioModule = {}

function YaCARadioModule.initRadioSettings()
    for i = 1, Settings.MaxRadioChannels, 1 do
        if radioChannelSettings[i] == nil then
            radioChannelSettings[i] = table.clone(defaultRadioChannelSettings)
        end

        if playersInRadioChannel[i] == nil then
            playersInRadioChannel[i] = {}
        end

        local volume = radioChannelSettings[i].volume
        local stereo = radioChannelSettings[i].stereo

        YaCAMain.setCommDeviceStereomode(YacaFilterEnum.RADIO, stereo, i)
        YaCAMain.setCommDeviceVolume(YacaFilterEnum.RADIO, volume, i)
    end
end

function YaCARadioModule.radioTalkingStateToPlugin(state)
    YaCAMain.setPlayersCommType(
        YaCAMain.getPlayerByID(cache.serverId),
        YacaFilterEnum.RADIO,
        state,
        activeRadioChannels
    )
end

function YaCARadioModule.radioTalking(target, frequency, state, infos, me)
    me = me or false

    if me then
        YaCARadioModule.radioTalkingStateToPluginWithWhisper(state, target)
        return
    end
    
    local channel = YaCARadioModule.findRadioByFrequency(frequency)
    if not channel then
        return
    end

    local player = YaCAMain.getPlayerByID(target)
    if not player then
        return
    end

    local info = infos[cache.serverId]

    if not info?.shortRange or (info?.shortRange) then
        YaCAMain.setPlayersCommType(player, YacaFilterEnum.RADIO, state, channel, nil, CommDeviceMode.RECEIVER, CommDeviceMode.SENDER)
    end

    local playersInChannel = playersInRadioChannel[channel]
    if state then
        playersInChannel[target] = true
    else
        playersInChannel[target] = nil
    end

    if not info?.shortRange and not state then
        if state then
            playersWithShortRange[target] = true
        else
            playersWithShortRange[target] = nil
        end
    end
end

function YaCARadioModule.setRadioMuteState(channel, state)
    radioChannelSettings[channel].muted = state
    YaCARadio.disableRadioFromPlayerInChannel(channel)
end

function YaCARadioModule.leaveRadioChannel()
    
end

function YaCARadioModule.radioTalkingStateToPluginWithWhisper(state, targets, isPrimary)
    local comDeviceTargets = {}
    for _, target in pairs(targets) do
        local playerData = YaCAMain.getPlayerByID(target)
        if playerData then
            comDeviceTargets[#comDeviceTargets + 1] = playerData
        end
    end

    YaCAMain.setPlayersCommType(
        comDeviceTargets,
        YacaFilterEnum.RADIO,
        state,
        activeRadioChannels,
        nil,
        CommDeviceMode.SENDER,
        CommDeviceMode.RECEIVER
    )
end

function YaCARadioModule.findRadioByFrequency(frequency)
    for channel, data in pairs(radioChannelSettings) do
        if data.frequency == frequency then
            return tonumber(channel)
        end
    end

    return nil
end

function YaCARadioModule.setRadioFrequency(channel, frequency)
    radioFrequenceSetted = true

    if radioChannelSettings[channel].frequency ~= frequency then
        YaCARadioModule.disableRadioFromPlayerInChannel(channel)
    end

    radioChannelSettings[channel].frequency = frequency
end

function YaCARadioModule.disableRadioFromPlayerInChannel(channel)
    if not playersInRadioChannel[channel] then
        return
    end

    local players = playersInRadioChannel[channel]
    if not players then
        return
    end

    local targets = {}
    for index, playerId in pairs(players) do
        local playerData = YaCAMain.getPlayerByID(playerId)
        if playerData then
            targets[#targets + 1] = playerData
            players[index] = nil
        end
    end

    if #targets > 0 then
        YaCAMain.setPlayersCommType(
            targets,
            YacaFilterEnum.RADIO,
            false,
            channel,
            nil,
            CommDeviceMode.RECEIVER,
            CommDeviceMode.SENDER
        )
    end
end

function YaCARadioModule.radioTalkingStart(state, clearPedTasks)
    clearPedTasks = clearPedTasks or false

    if not state then
        if radioTalking then
            radioTalking = false

            if YaCAMain.useWhisper then
                YaCARadioModule.radioTalkingStateToPlugin(false)
            end

            TriggerServerEvent("server:yaca:radioTalking", false)

            if clearPedTasks then
                StopAnimTask(cache.ped, "random@arrests", "generic_radio_chatter", 4.0)
            end
        end

        return
    end

    if !radioEnabled or !radioFrequenceSetted or radioTalking then
        return
    end

    radioTalking = true
    if not YaCAMain.useWhisper then
        YaCARadioModule.radioTalkingStateToPlugin(true)
    end

    lib.requestAnimDict("random@arrests")
    TaskPlayAnim(cache.ped, "random@arrests", "generic_radio_chatter", 3.0, -4.0, -1, 49, 0.0, false, false, false)
    TriggerServerEvent("server:yaca:radioTalking", true)
end

return YaCARadioModule