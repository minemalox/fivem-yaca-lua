local YaCAPhone = {}

function YaCAPhone.callPlayer(player, target, state)
    if not player or not target then
        return
    end

    TriggerClientEvent('client:yaca:phone', player, target, state)
    TriggerClientEvent('client:yaca:phone', target, player, state)

    if not state then
        YaCAPhone.muteOnPhone(player, false, true)
        YaCAPhone.muteOnPhone(target, false, true)
    elseif Player(player).state['yaca_phoneSpeaker'] then
        YaCAPhone.enablePhoneSpeaker(target, true, { player, target})
    end
end

function YaCAPhone.callPlayerOld(player, target, state)
    if not player or not target then
        return
    end

    TriggerClientEvent('client:yaca:phoneOld', player, target, state)
    TriggerClientEvent('client:yaca:phoneOld', target, player, state)

    if not state then
        YaCAPhone.muteOnPhone(player, false, true)
        YaCAPhone.muteOnPhone(target, false, true)
    elseif Player(player).state['yaca_phoneSpeaker'] then
        YaCAPhone.enablePhoneSpeaker(target, true, { player, target})
    end
end

function YaCAPhone.muteOnPhone(player, state, onCallStop)
    if not player then
        return
    end

    YaCAServerMain.getPlayerSettings(player).phoneMuted = state
    TriggerClientEvent('client:yaca:phoneMute', player, state, onCallStop)
end

function YaCAPhone.enablePhoneSpeaker(player, state, phoneCallMemberIds)
    if not player or not phoneCallMemberIds then
        return
    end

    if state then
        Player(player).state:set('yaca_phoneSpeaker', phoneCallMemberIds, true)
    else
        Player(player).state:set('yaca_phoneSpeaker', nil, true)
    end
end

return YaCAPhone