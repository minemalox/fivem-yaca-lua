CreateThread(function ()
    while true do
        for _,playerID in ipairs(GetPlayers()) do
            if playerID ~= nil then
                local serverID = tonumber(playerID)
                local listOfPhoneCalls = {}
                if #YacaCallList > 0 then
                    for _,phoneCall in ipairs(YacaCallList) do
                        if phoneCall.callStarted ~= serverID then
                            for _,callmember in ipairs(phoneCall.callMemberList) do
                                if callmember.serverID == serverID then
                                    table.insert(listOfPhoneCalls,phoneCall)
                                end
                            end
                        elseif phoneCall.callStarted == serverID then
                            table.insert(listOfPhoneCalls,phoneCall)
                        end
                    end
                end
                TriggerClientEvent("yaca:voice:client:syncPhoneCall",serverID,listOfPhoneCalls)
            end
        end
        Wait(2000)
    end
end)