local activeRadioChannel = 1
local defaultRadioChannelSettings = {
    volume = 1.0,
    stereo = YacaStereoMode.STEREO,
    muted = false,
    frequency = 0,
}

local radioEnabled = false
local radioChannelSettings = {}
local playersInRadioChannel = {}
local playersWithShortRange = {}
local radioFrequenceSetted = false
local radioTalking = false

local YaCARadioModule = {}

YaCARadioModule.radioInited = false

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

function YaCARadioModule.enableRadio(state)
    if not YaCAMain.isPluginInitialized() then
        return
    end

    if radioEnabled ~= state then
        radioEnabled = state
        TriggerServerEvent("server:yaca:enableRadio", state)

        if not state then
            for i = 1, Settings.MaxRadioChannels, 1 do
                YaCARadioModule.disableRadioFromPlayerInChannel(i)
            end
        end
    end

    if state and not YaCARadioModule.radioInited then
        YaCARadioModule.radioInited = true
        YaCARadioModule.initRadioSettings()
    end
end

function YaCARadioModule.changeRadioFrequency(frequency)
    if not YaCAMain.isPluginInitialized() then
        return
    end

    TriggerServerEvent("server:yaca:changeRadioFrequency", activeRadioChannel, frequency)
end

function YaCARadioModule.muteRadioChannel()
    if not YaCAMain.isPluginInitialized() then
        return
    end

    local channel = activeRadioChannel
    if radioChannelSettings[channel].frequency == 0 then
        return
    end

    TriggerServerEvent("server:yaca:muteRadioChannel", channel)
end

function YaCARadioModule.radioTalkingStateToPlugin(state)
    YaCAMain.setPlayersCommType(
        YaCAMain.getPlayerByID(cache.serverId),
        YacaFilterEnum.RADIO,
        state,
        activeRadioChannel
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
    YaCARadioModule.disableRadioFromPlayerInChannel(channel)
end

function YaCARadioModule.leaveRadioChannel(client_ids, frequency)
    if type(client_ids) ~= "table" then
        client_ids = { client_ids }
    end

    local channel = YaCARadioModule.findRadioChannelByFrequency(frequency)

    if lib.table.contains(YaCAMain.getPlayerByID(cache.serverId)?.clientId, client_ids) then
        YaCARadio.setRadioFrequency(channel, 0)
    end

    NUI.SendWSMessage({
        base = {
            request_type = "INGAME"
        },
        comm_device_left = {
            comm_type = YacaFilterEnum.RADIO,
            client_ids = client_ids,
            channel = channel
        }
    })
end

function YaCARadioModule.changeActiveRadioChannel(channel)
    if not YaCAMain.isPluginInitialized() or not radioEnabled then
        return
    end

    TriggerServerEvent("server:yaca:changeActiveRadioChannel", channel)
    activeRadioChannel = channel
end

function YaCARadioModule.changeRadioChannelVolume(higher)
    if not YaCAMain.isPluginInitialized() or not radioEnabled or radioChannelSettings[activeRadioChannel].frequency == 0 then
        return
    end

    local channel = activeRadioChannel
    local oldVolume = radioChannelSettings[channel].volume
    radioChannelSettings[channel].volume = math.clamp(oldVolume + (higher and 0.17 or -0.17), 0.0, 1.0)

    if oldVolume == radioChannelSettings[channel].volume then
        return
    end

    if radioChannelSettings[channel].volume == 0 or (oldVolume == 0 and radioChannelSettings[channel].volume > 0) then
        TriggerServerEvent("server:yaca:muteRadioChannel", channel)
    end

    YaCAMain.setCommDeviceVolume(YacaFilterEnum.RADIO, radioChannelSettings[channel].volume, channel)
end

function YaCARadioModule.changeRadioChannelStereo()
    if not YaCAMain.isPluginInitialized() or not radioEnabled or radioChannelSettings[activeRadioChannel].frequency == 0 then
        return
    end

    local channel = activeRadioChannel

    if radioChannelSettings[channel].stereo == YacaStereoMode.STEREO then
        radioChannelSettings[channel].stereo = YacaStereoMode.MONO_LEFT
        Utils.radarNotification(locale('radio_channel_mono_left'))
    elseif radioChannelSettings[channel].stereo == YacaStereoMode.MONO_LEFT then
        radioChannelSettings[channel].stereo = YacaStereoMode.MONO_RIGHT
        Utils.radarNotification(locale('radio_channel_mono_right'))
    else
        radioChannelSettings[channel].stereo = YacaStereoMode.STEREO
        Utils.radarNotification(locale('radio_channel_stereo'))
    end

    YaCAMain.setCommDeviceStereomode(YacaFilterEnum.RADIO, radioChannelSettings[channel].stereo, channel)
end

function YaCARadioModule.radioTalkingStateToPluginWithWhisper(state, targets)
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
        activeRadioChannel,
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

            if not YaCAMain.useWhisper then
                YaCARadioModule.radioTalkingStateToPlugin(false)
            end

            TriggerServerEvent("server:yaca:radioTalking", false)

            if clearPedTasks then
                StopAnimTask(cache.ped, "random@arrests", "generic_radio_chatter", 4.0)
            end
        end

        return
    end

    if not radioEnabled or not radioFrequenceSetted or radioTalking then
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