RegisterNetEvent('yaca:voice:server:setPlayerDead',function (source,state)
    for index,element in ipairs(YacaPlayerList) do
        if element.serverID == source then
            element.isDead = state
            table.insert(YacaPlayerList,index,element)
        end
    end
end)