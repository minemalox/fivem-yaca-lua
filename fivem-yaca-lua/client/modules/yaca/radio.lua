local activeRadioChannels = {
    primary = nil,
    secondary = nil
}

local defaultRadioChannelSettings = {
    volume = 1.0,
    stereo = YacaStereoMode.STEREO,
    muted = false,
    frequency = 0,
}

local radioChannelSettings = {
    
}

local YaCARadioModule = {}

function YaCARadioModule.initRadioSettings()
    for i = 1, Settings.MaxRadioChannels, 1 do
        if 
    end
end

function YaCARadioModule.radioTalkingStateToPlugin(state, isPrimary)
    YaCAMain.setPlayersCommType(
        YaCAMain.getPlayerByID(cache.serverId),
        YacaFilterEnum.RADIO,
        state,
        isPrimary and activeRadioChannels.primary or activeRadioChannels.secondary
    )
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
        isPrimary and activeRadioChannels.primary or activeRadioChannels.secondary,
        nil,
        CommDeviceMode.SENDER,
        CommDeviceMode.RECEIVER
    )
end

return YaCARadioModule