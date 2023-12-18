RegisterNetEvent('yaca:voice:client:setPlayerDead',function (state)
    TriggerServerEvent('yaca:voice:server:setPlayerDead',state)
end)

RegisterNetEvent('yaca:voice:client:setRadioFreaqunz',function (frequenz)
    TriggerServerEvent('yaca:voice:server:setRadioFreaqunz',frequenz)
end)

RegisterNetEvent('yaca:voice:client:setRadioFreaqunzWithJob',function (frequenz,job)
    TriggerServerEvent('yaca:voice:server:setRadioFreaqunzWihtJob',frequenz,job)
end)