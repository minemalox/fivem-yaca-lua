lib.locale()
math = lib.math

Statebags = require 'client.modules.statebags'
Utils = require 'client.modules.utils'
NUI = require 'client.modules.nui'
YaCAMain = require 'client.modules.yaca.main'
YaCARadio = require 'client.modules.yaca.radio'

NUI.initNUICallbacks()

RegisterNetEvent('client:yaca:init', YaCAMain.initConnection)
RegisterNetEvent('client:yaca:addPlayers', YaCAMain.addPlayers)
RegisterNetEvent('client:yaca:disconnect', YaCAMain.playerDisconnected)
RegisterNetEvent('client:yaca:changeVoiceRange', YaCAMain.changeVoiceRange)
RegisterNetEvent('client:yaca:muteTarget', YaCAMain.muteTarget)

CreateThread(function()
    while true do
        Wait(250)
        if NUI.WebsocketConnected then
            YaCAMain.calcPlayers()
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
        YaCAMain.changeMyVoiceRange(1)
    end
})

local megaphoneKeybind = lib.addKeybind({
    name = 'yaca:useMegaphone',
    description = locale('use_megaphone_description'),
    defaultKey = Settings.DefaultKeybinds.useMegaphone,
    onPressed = function (self)
        YaCAMain.useMegaphone(true)
    end,
    onReleased = function(self)
        YaCAMain.useMegaphone(false)
    end
})

lib.onCache('vehicle', function (vehicle)
    if not vehicle then
        YaCAMain.useMegaphone(false)
    else
        local vehicleClass = GetVehicleClass(vehicle)

        if vehicleClass == 18 or vehicleClass == 19 then
            YaCAMain.canUseMegaphone = true
        else
            YaCAMain.canUseMegaphone = false
        end
    end
end)

AddStateBagChangeHandler('yaca_megaphone', nil, function (bagName, key, value, _, replicated)
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
    YaCAMain.setPlayersCommType(
        isOwnPlayer and {} or YaCAMain.getPlayerByID(serverId),
        YacaFilterEnum.MEGAPHONE,
        value ~= nil,
        nil,
        value,
        isOwnPlayer and CommDeviceMode.SENDER or CommDeviceMode.RECEIVER,
        isOwnPlayer and CommDeviceMode.RECEIVER or CommDeviceMode.SENDER
    )
    YaCAMain.setCommDeviceVolume(YacaFilterEnum.MEGAPHONE, 1.0)
end)