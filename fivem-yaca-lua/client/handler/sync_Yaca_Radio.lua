YacaRadioList = {}

RegisterNetEvent("yaca:voice:client:syncRadioChannel",function (listOfRadioChannels)
    if  listOfRadioChannels ~= nil then
        YacaRadioList = listOfRadioChannels
    end
end)