
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
                                if #(pCoords - tCoords) <= 80 then
                                    table.insert(PlayerinRange,target)
                                end
                            end
                        end
                    end
                    TriggerClientEvent('yaca:Voice:upDatePlayerInNear',player.serverID,PlayerinRange)
                end
            end
        end
        Wait(1500)
    end
end)


--[[CreateThread(function ()
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
        Wait(300)
    end
end)]]