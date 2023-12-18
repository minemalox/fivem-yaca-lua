RegisterNetEvent('yaca:voice:server:setPlayerDead',function (source,state)
    for index,element in ipairs(YacaPlayerList) do
        if element.serverID == source then
            element.isDead = state
            TriggerClientEvent('yaca:Voice:upDateDeath',element.serverID,state)
            table.insert(YacaPlayerList,index,element)
        end
    end
end)


RegisterNetEvent('yaca:voice:server:setRadioFreaqunz',function (source,freaguenz)
    local existFreaquenz = false

    for index,elment in ipairs(YacaRadioList) do
        if elment.freaguenz == freaguenz then
            if elment.job ~= nil then
            
            else
            
            end 
        end
    end

end)

RegisterNetEvent('yaca:voice:server:setRadioFreaqunzWihtJob',function ()
    
end)