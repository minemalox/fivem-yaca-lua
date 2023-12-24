CreateThread(function ()
    while true do
        for _,playerID in ipairs(GetPlayers()) do
            if playerID ~= nil then
                local serverID = tonumber(playerID)
                local listOfRadioChannels = {}

                if #YacaRadioList > 0 then
                    for _,radioChannel in ipairs(YacaRadioList) do
                        if #radioChannel.radioMember > 0 then
                            for _,radioMember in ipairs(radioChannel.radioMember) do
                                if radioMember.serverID == serverID then
                                    table.insert(listOfRadioChannels,radioChannel)
                                end
                            end
                        end
                    end                
                end
                TriggerClientEvent("yaca:voice:client:syncRadioChannel",serverID,listOfRadioChannels)
            end
        end
        Wait(2000)
    end
end)