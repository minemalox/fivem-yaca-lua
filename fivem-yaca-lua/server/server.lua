string = lib.string

Utils = require 'server.modules.utils'
YaCAServerMain = require 'server.modules.yaca.main'
YaCAServerRadio = require 'server.modules.yaca.radio'

RegisterNetEvent('server:yaca:nuiReady', YaCAServerMain.connectToVoice)
RegisterNetEvent('server:yaca:addPlayer', YaCAServerMain.addNewPlayer)
RegisterNetEvent('server:yaca:wsReady', YaCAServerMain.wsReady)
RegisterNetEvent('server:yaca:changeVoiceRange', YaCAServerMain.changeVoiceRange)
RegisterNetEvent('server:yaca:useMegaphone', YaCAServerMain.useMegaphone)

RegisterNetEvent('server:yaca:enableRadio', YaCAServerRadio.enableRadio)
RegisterNetEvent('server:yaca:changeRadioFrequency', YaCAServerRadio.changeRadioFrequency)
RegisterNetEvent('server:yaca:muteRadioChannel', YaCAServerRadio.muteRadioChannel)
RegisterNetEvent('server:yaca:radioTalking', YaCAServerRadio.radioTalking)
RegisterNetEvent('server:yaca:changeActiveRadioChannel', YaCAServerRadio.changeActiveRadioChannel)

AddEventHandler('playerDropped', YaCAServerMain.handlePlayerDisconnect)

exports('changePlayerAliveStatus', YaCAServerMain.changePlayerAliveStatus)
exports('SetPlayerAlive', YaCAServerMain.changePlayerAliveStatus)

if Settings.Debug then
    RegisterCommand('setAlive', function(source, args)
        YaCAServerMain.changePlayerAliveStatus(source, args[1] == 'true')
    end, false)
end