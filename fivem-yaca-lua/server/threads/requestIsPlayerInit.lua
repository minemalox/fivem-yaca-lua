CreateThread(function ()
    while true do
        local allPlayers = GetPlayers()
        if #allPlayers > 0 then
            for _,playerID in ipairs(allPlayers) do
                local hasFound = false
                for _,yacaPlayer in ipairs(YacaPlayerList) do
                    if yacaPlayer.serverID == playerID then
                        hasFound = true
                    end
                end
                if hasFound == false then
                    TriggerClientEvent("yaca:Voice:checkInitState",playerID)
                end
            end
        end
        Wait(5000)
    end
end)