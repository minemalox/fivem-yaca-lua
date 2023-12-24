CreateThread(function ()
    while true do
        local allPlayers = GetPlayers()
        if #allPlayers > 0 then
            for _,playerID in ipairs(allPlayers) do
                local hasFound = false
                for _,yacaPlayer in ipairs(YacaPlayerList) do
                    if tonumber(yacaPlayer.serverID) == tonumber(playerID) then
                        hasFound = true
                    end
                end
                if hasFound == false then
                    playerID = tonumber(playerID)
                    TriggerClientEvent("yaca:Voice:checkInitState",playerID)
                end
            end
        end
        Wait(30000)
    end
end)