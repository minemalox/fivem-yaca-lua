lib.locale()
math = lib.math

NUI = require 'client.modules.nui'
YaCA = require 'client.modules.yaca'

NUI.initNUICallbacks()

RegisterNetEvent('client:yaca:init', YaCA.initConnection)
RegisterNetEvent('client:yaca:addPlayers', YaCA.addPlayers)
RegisterNetEvent('client:yaca:disconnect', YaCA.playerDisconnected)