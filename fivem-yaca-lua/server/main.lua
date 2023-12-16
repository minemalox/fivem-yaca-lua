
--<============================= Help Funktions ===============================>--
function GetCamDirection (src)
    local rotVector = GetPlayerCameraRotation(src)
    local num = rotVector.z * 0.0174532924
    local num2 = rotVector.x * 0.0174532924
    local num3 = math.abs(math.cos(num2))

    return vector3(
        -math.sin(num) * num3,
        math.cos(num) * num3,
        GetEntityCoords(src).z
    )
end



--<============================= Sync / Player in Range for Plugin Sync ===============================>--
CreateThread(function ()
    while true do
        if #YacaPlayerList > 0 then
            for _,player in ipairs(YacaPlayerList) do
                if player.gtaPlayerObject ~= nil and player.serverID ~= 0 then
                    PlayerinRange = {}
                    local pCoords = GetEntityCoords(player.gtaPlayerObject)

                    for _, target in ipairs(YacaPlayerList) do
                        if target.gtaPlayerObject ~= nil and target.serverID ~= 0 then
                            if player.serverID ~= target.serverID then
                                local tCoords = GetEntityCoords(target.gtaPlayerObject)
                                if #(pCoords - tCoords) <= player.range then
                                    table.insert(PlayerinRange,{
                                        client_id = target.clientID,
                                        position = tCoords,
                                        direction = GetPlayerCameraRotation(target.gtaPlayerObject),
                                        range = target.range,
                                        is_underwater = target.isSwimming,
                                        muffle_intensity = player.muffleIntensity
                                        --is_muted = target.isMuted
                                    })
                                end
                            end
                        end
                    end

                    if #PlayerinRange > 0 then
                        print(dump(PlayerinRange))
                        TriggerClientEvent('yaca:Voice:sendData:Ui',player.serverID,{
                            actionCMD = "sendPlayer",
                            player_direction = GetCamDirection(player.gtaPlayerObject),
                            player_position = pCoords,
                            --player_range = player.range,
                            player_is_underwater = player.isSwimming,
                            player_is_muted = player.IsMuted,
                            players_list = json.encode(PlayerinRange)
                        })
                    end
                end
            end
        end
        Wait(1000)
    end
end)

--[[CreateThread(function ()
    while true do
        if #yacaPlayerList > 0 then
            for _,element in ipairs(yacaPlayerList) do
               
            end
            Wait(100)
        else
            Wait(100)
        end
    end
end)]]

/*CreateThread(function()
    while(true) do
        for _,playerId  in ipairs(GetPlayers()) do
            --local xPlayer = GetPlayer(playerId)
            
            if xPlayer ~= nil then
                playersInRange = {}
                local pCoords = GetEntityCoords(xPlayer)
                print(pCoords)
                currentRoom = GetRoomKeyFromEntity(xPlayer);
    
                if pCoords ~= nil then
                    for _,yacaVoicePlayer in ipairs(yacaVoiceList) do
                        if(playerID ~= yacaVoicePlayer.serverID)then
                            if yacaVoicePlayer.forceMuted == false then
                                local target = GetPlayer(yacaVoicePlayer.serverID)
                                local tCoords = GetEntityCoords(targetID)
                                if Vdist(pCoords.x,pCoords.y,pCoords.z,tCoords.x,tCoords.y,tCoords.z) <= yacaVoicePlayer.range then
            
                                    muffleIntensity = 0;
                                    if currentRoom ~= GetRoomKeyFromEntity(target) and HasEntityClearLosToEntity(xPlayer, target, 17) == true then
                                        muffleIntensity = 10  --10 is the maximum intensity
                                    end
            
                                    table.insert(playersInRange,{
                                        client_id = yacaVoicePlayer.clientID,
                                        position= tCoords,
                                        direction= GetEntityRotation(xPlayer),
                                        range= yacaVoicePlayer.range,
                                        is_underwater= IsPedSwimmingUnderWater(GetPlayerPed(yacaVoicePlayer.serverID)),
                                        muffle_intensity= muffleIntensity,
                                    })
                                end
                            end
                        end
                    end
                else
                    print("[Yaca-Voice] Player Coords can not found!")
                end
                
                TriggerClientEvent('yaca:Voice:sendData:Ui',playerID,{
                    base = {request_type= "INGAME"},
                    player= {
                        player_direction= getCamDirection(),
                        player_position = pCoords,
                        player_is_underwater = IsPedSwimmingUnderWater(GetPlayerPed(playerID)),
                        players_list =  playersInRange
                    }
                })
            else
                print("[Yaca-Voice] Player " .. playerID .. ' can not found!')
            end
        end
        Wait(10)
    end    
end)*/