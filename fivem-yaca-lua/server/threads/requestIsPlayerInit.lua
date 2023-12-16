CreateThread(function ()
    while true do
        local allPlayers = GetPlayers()
        if #allPlayers > 0 then
            for _,playerID in ipairs(allPlayers) do
                for _,yacaPlayer in ipairs(YacaPlayerList) do
                    if yacaPlayer.serverID ~= playerID then
                        TriggerClientEvent("yaca:Voice:checkInitState",playerID)
                    end
                end
            end
        end
        Wait(5000)
    end
end)