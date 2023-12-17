RegisterNetEvent('yaca:voice:client:setPlayerDead',function (state)
    TriggerServerEvent('yaca:voice:server:setPlayerDead',state)
end)