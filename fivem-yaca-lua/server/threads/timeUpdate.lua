CreateThread(function ()
    while true do
        if #YacaPlayerList > 0 then
            for _,element in ipairs(YacaPlayerList) do
                TriggerClientEvent("yaca:Voice:UpdateInfos",element.serverID)
            end
        end
    Wait(300)
    end
end)