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
    local playerObj = getYacaPlayer(source)
    for index,elment in ipairs(YacaRadioList) do
        if elment.freaguenz == freaguenz then
            if elment.job == nil then
                AddPlayerToRadioChannel(freaguenz,playerObj,nil)
                existFreaquenz = true
            else
                print("[YACA - Voice] wrong api Event Used. Cannot go into radio freaguenz, as this is tied to a profession.")
            end 
        end
    end

    if existFreaquenz == false then
        CreateRadioChannel(freaguenz,nil)
        AddPlayerToRadioChannel(freaguenz,playerObj,nil)
    end
end)

RegisterNetEvent('yaca:voice:server:setRadioFreaqunzWihtJob',function (source,freaguenz,job)
    local existFreaquenz = false
    local playerObj = getYacaPlayer(source)
    for index,elment in ipairs(YacaRadioList) do
        if elment.freaguenz == freaguenz then
            if elment.job == nil then
                print("[YACA - Voice] wrong api Event Used. Cannot go into radio freaguenz how is Jobbinded, with no Job set.")
            elseif elment.job == job then
                AddPlayerToRadioChannel(freaguenz,playerObj,job)
                existFreaquenz = true
            end 
        end
    end

    if existFreaquenz == false then
        CreateRadioChannel(freaguenz,nil)
        AddPlayerToRadioChannel(freaguenz,playerObj,nil)
    end
end)


RegisterNetEvent("yaca:voice:client:setDead",function (state)
    for index,player in ipairs(YacaPlayerList) do
        if player.serverID == source then
            player.isDead = state
            table.insert(YacaPlayerList,index,player)
        end
    end
end)