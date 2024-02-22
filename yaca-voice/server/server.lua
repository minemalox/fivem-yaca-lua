lib.locale()
string = lib.string

Utils = require 'server.modules.utils'
YaCAServerMain = require 'server.modules.yaca.main'
YaCAServerRadio = require 'server.modules.yaca.radio'
YaCAServerPhone = require 'server.modules.yaca.phone'

RegisterNetEvent('server:yaca:nuiReady', YaCAServerMain.connectToVoice)
RegisterNetEvent('server:yaca:addPlayer', YaCAServerMain.addNewPlayer)
RegisterNetEvent('server:yaca:wsReady', YaCAServerMain.wsReady)
RegisterNetEvent('server:yaca:changeVoiceRange', YaCAServerMain.changeVoiceRange)
RegisterNetEvent('server:yaca:useMegaphone', YaCAServerMain.useMegaphone)

RegisterNetEvent('server:yaca:enableRadio', YaCAServerRadio.enableRadio)
RegisterNetEvent('server:yaca:changeRadioFrequency', YaCAServerRadio.changeRadioFrequency)
RegisterNetEvent('server:yaca:muteRadioChannel', YaCAServerRadio.radioChannelMute)
RegisterNetEvent('server:yaca:radioTalking', YaCAServerRadio.radioTalkingState)
RegisterNetEvent('server:yaca:changeActiveRadioChannel', YaCAServerRadio.radioActiveChannelChange)

AddEventHandler('playerDropped', YaCAServerMain.handlePlayerDisconnect)

exports('changePlayerAliveStatus', YaCAServerMain.changePlayerAliveStatus)
exports('SetPlayerAlive', YaCAServerMain.changePlayerAliveStatus)

exports('callPlayer', YaCAServerPhone.callPlayer)

if Settings.Debug then
    RegisterCommand('setAlive', function(source, args)
        YaCAServerMain.changePlayerAliveStatus(source, args[1] == 'true')
    end, false)

    RegisterCommand('callPlayer', function(source, args)
        YaCAServerPhone.callPlayer(source, tonumber(args[1]), args[2] == 'true')
    end, false)

    RegisterCommand('callPlayerOld', function(source, args)
        YaCAServerPhone.callPlayerOld(source, tonumber(args[1]), args[2] == 'true')
    end, false)

    RegisterCommand('muteOnPhone', function(source, args)
        YaCAServerPhone.muteOnPhone(source, args[1] == 'true', false)
    end, false)

    RegisterCommand('enablePhoneSpeaker', function(source, args)
        YaCAServerPhone.enablePhoneSpeaker(source, args[1] == 'true', { tonumber(args[2])})
    end, false)
end