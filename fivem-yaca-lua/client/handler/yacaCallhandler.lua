RegisterNetEvent("yaca:voice:startCall",function (callMemberList)
    TriggerServerEvent("yaca:voice:server:initCall",callMemberList)
end)

RegisterNetEvent("yaca:voice:addPlayerToCall",function (callID,playerID)
    TriggerServerEvent("yaca:voice:server:AddPlayer",callID,playerID)
end)

RegisterNetEvent("yaca:voice:removePlayerFromCall",function (callID,playerID)
    TriggerServerEvent("yaca:voice:server:RemovePlayer",callID,playerID)
end)

