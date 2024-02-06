local YaCAPhone = {}

local onPhoneWith = {}

function YaCAPhone.removePhoneSpeakerFromEntity(entity)
    if not entity then
        return
    end

    local entityData = YaCAMain.getPlayerByID(entity)
    if not entityData.phoneCallMemberIds then
        return
    end

    local playersToSet = {}
    for _, phoneCallMemberId in pairs(entityData.phoneCallMemberIds) do
        local phoneCallMember = YaCAMain.getPlayerByID(phoneCallMemberId)
        if phoneCallMember then
            playersToSet[#playersToSet + 1] = phoneCallMember
        end
    end

    YaCAMain.setPlayersCommType(playersToSet, YacaFilterEnum.PHONE_SPEAKER, false, nil, nil, CommDeviceMode.RECEIVER, CommDeviceMode.SENDER)
    entityData.phoneCallMemberIds = nil
end

function YaCAPhone.phone(targetId, state)
    local target = YaCAMain.getPlayerByID(targetId)
    if not target then return end

    YaCAMain.setPlayersCommType(target, YacaFilterEnum.PHONE, state, nil, nil, CommDeviceMode.TRANSCEIVER, CommDeviceMode.TRANSCEIVER);

    if state then
        onPhoneWith[targetId] = targetId
    else
        onPhoneWith[targetId] = nil
    end
end

function YaCAPhone.phoneOld(targetId, state)
    local target = YaCAMain.getPlayerByID(targetId)
    if not target then return end

    YaCAMain.setPlayersCommType(target, YacaFilterEnum.PHONE, state, nil, nil, CommDeviceMode.TRANSCEIVER, CommDeviceMode.TRANSCEIVER);

    if state then
        onPhoneWith[targetId] = targetId
    else
        onPhoneWith[targetId] = nil
    end
end

function YaCAPhone.phoneMute(targetId, state, onCallStop)
    if onCallStop == nil then
        onCallStop = false
    end

    local target = YaCAMain.getPlayerByID(targetId)
    if not target then
        return
    end

    target.mutedOnPhone = state

    if onCallStop or onPhoneWith[targetId] == nil then
        return
    end

    if YaCAMain.useWhisper and targetId ~= cache.serverId then
        YaCAMain.setPlayersCommType({}, YacaFilterEnum.PHONE, not state, nil, nil, CommDeviceMode.SENDER)
    elseif not YaCAMain.useWhisper then
        if state then
            YaCAMain.setPlayersCommType(target, YacaFilterEnum.PHONE, false, nil, nil, CommDeviceMode.TRANSCEIVER, CommDeviceMode.TRANSCEIVER)
        else
            YaCAMain.setPlayersCommType(target, YacaFilterEnum.PHONE, true, nil, nil, CommDeviceMode.TRANSCEIVER, CommDeviceMode.TRANSCEIVER)
        end
    end
end

return YaCAPhone