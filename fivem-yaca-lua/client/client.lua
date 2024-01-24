lib.locale()
math = lib.math

Statebags = require 'client.modules.statebags'
Utils = require 'client.modules.utils'
NUI = require 'client.modules.nui'
YaCA = require 'client.modules.yaca'

NUI.initNUICallbacks()

RegisterNetEvent('client:yaca:init', YaCA.initConnection)
RegisterNetEvent('client:yaca:addPlayers', YaCA.addPlayers)
RegisterNetEvent('client:yaca:disconnect', YaCA.playerDisconnected)
RegisterNetEvent('client:yaca:changeVoiceRange', YaCA.changeVoiceRange)

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
    defaultKey = Settings.DefaultKeybinds.changeVoiceRange,
    onReleased = function(self)
        YaCA.changeMyVoiceRange(1)
    end
})

local megaphoneKeybind = lib.addKeybind({
    name = 'yaca:useMegaphone',
    description = locale('use_megaphone_description'),
    defaultKey = Settings.DefaultKeybinds.useMegaphone,
    onPressed = function (self)
        YaCA.useMegaphone(true)
    end,
    onReleased = function(self)
        YaCA.useMegaphone(false)
    end
})

lib.onCache('vehicle', function (vehicle)
    if not vehicle then
        YaCA.useMegaphone(false)
    else
        local vehicleClass = GetVehicleClass(vehicle)

        if vehicleClass == 18 or vehicleClass == 19 then
            YaCA.canUseMegaphone = true
        else
            YaCA.canUseMegaphone = false
        end
    end

    print(YaCA.canUseMegaphone)
end)

AddStateBagChangeHandler('yaca_megaphone', nil, function (bagName, key, value, _, replicated)
    print('yaca_megaphone', bagName, key, value, replicated)
    if replicated then
        return
    end

    local player = GetPlayerFromStateBagName(bagName)

    print(player)

    if not player or player == 0 then
        return
    end

    local serverId = GetPlayerServerId(player)

    local isOwnPlayer = serverId == cache.serverId
    YaCA.setPlayersCommType(
        isOwnPlayer and {} or YaCA.getPlayerByID(serverId),
        YacaFilterEnum.MEGAPHONE,
        value ~= nil,
        nil,
        value,
        isOwnPlayer and CommDeviceMode.SENDER or CommDeviceMode.RECEIVER,
        isOwnPlayer and CommDeviceMode.RECEIVER or CommDeviceMode.SENDER
    )
    YaCA.setCommDeviceVolume(YacaFilterEnum.MEGAPHONE, 1.0)
end)