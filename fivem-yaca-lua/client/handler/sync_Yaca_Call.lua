YacaPhoneCalls = {}

RegisterNetEvent("yaca:voice:client:syncPhoneCall",function (listOfPhoneCalls)
    if listOfPhoneCalls ~= nil then 
        YacaCallList = listOfPhoneCalls
    end
end)