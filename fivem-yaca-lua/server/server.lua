string = lib.string

Utils = require 'server.modules.utils'
YaCaServer = require 'server.modules.yaca'

RegisterNetEvent('server:yaca:addPlayer', YaCaServer.addNewPlayer)


AddEventHandler('playerDropped', YaCaServer.handlePlayerDisconnect)