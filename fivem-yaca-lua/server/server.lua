string = lib.string

Utils = require 'server.modules.utils'
YaCaServer = require 'server.modules.yaca'

RegisterNetEvent('server:yaca:nuiReady', YaCaServer.connectToVoice)
RegisterNetEvent('server:yaca:addPlayer', YaCaServer.addNewPlayer)
RegisterNetEvent('server:yaca:wsReady', YaCaServer.wsReady)
RegisterNetEvent('server:yaca:changeVoiceRange', YaCaServer.changeVoiceRange)
RegisterNetEvent('server:yaca:useMegaphone', YaCaServer.useMegaphone)

AddEventHandler('playerDropped', YaCaServer.handlePlayerDisconnect)

exports('changePlayerAliveStatus', YaCaServer.changePlayerAliveStatus)
exports('SetPlayerAlive', YaCaServer.changePlayerAliveStatus)