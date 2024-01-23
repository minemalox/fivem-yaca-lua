lib.locale()
math = lib.math

Statebags = require 'client.modules.statebags'
Utils = require 'client.modules.utils'
NUI = require 'client.modules.nui'
YaCA = require 'client.modules.yaca'

NUI.initNUICallbacks()

RegisterNetEvent('client:yaca:init', YaCA.initConnection)
-- RegisterNetEvent('client:yaca:addPlayers', YaCA.addPlayers)
RegisterNetEvent('client:yaca:disconnect', YaCA.playerDisconnected)

CreateThread(function()
    while true do
        Wait(250)
        if NUI.WebsocketConnected then
            YaCA.calcPlayers()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
        NUI.closeConnection()
   end
end)

local changeVoiceRangeKeybind = lib.addKeybind({
    name = 'yaca:changeVoiceRange',
    description = locale('change_voice_range_description'),
    defaultKey = 'Y',
    onReleased = function(self)
        YaCA.changeVoiceRange(1)
    end
})