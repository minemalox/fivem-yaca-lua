string = lib.string

Utils = require 'server.modules.utils'
YaCaServer = require 'server.modules.yaca'

RegisterNetEvent('server:yaca:nuiReady', YaCaServer.connectToVoice)
RegisterNetEvent('server:yaca:addPlayer', YaCaServer.addNewPlayer)
RegisterNetEvent('server:yaca:wsReady', YaCaServer.wsReady)

AddEventHandler('playerDropped', YaCaServer.handlePlayerDisconnect)