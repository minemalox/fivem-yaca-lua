YacaRadioList = {}

function createRadioChannel(frequenz,job)
    local existRadioChannel = false

    for _,element in ipairs(YacaRadioList) do
        if element.frequenz == frequenz then
            existRadioChannel = true
        end
    end

    if not existRadioChannel then
        for index,element in ipairs(Config.radioWhiteList)do
            if index = frequenz then
                if element.job == "" and job == nil then
                    table.insert(YacaRadioList,new YacaRadioChannels(frequenz,job,{}))
                    return true
                elseif element.job == job then
                    table.insert(YacaRadioList,new YacaRadioChannels(frequenz,job,{}))
                    return true
                else
                    return false
                    print('[Yaca - Voice] Dont Create Radio Channel')
                end
            end
        end
    else
        return false
        print('[Yaca - Voice] Radio Channel Exist')
    end
end

function addPlayerToRadioChannel(freaguenz,playerObj,job)
    local existRadioChannel = false

    for index,element in ipairs(YacaRadioList)do 
        if element.frequenz == freaguenz then
            if job ~= nil and element.job ~= nil then
                if job == element.job then
                    table.insert(element.radioMember,index,playerObj)
                end
            else 
                table.insert(element.radioMember,index,playerObj)
            end
            existRadioChannel = true
        end
    end
end