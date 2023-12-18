--################################################################
--  Yaca Radio Channels all Information for Radio Handling
--  all Player Id's and more helping Function
--################################################################

function YacaRadioChannels(frequenz,job,radioMember)
    return {
        frequenz = frequenz or 0,
        job = job or nil,
        radioMember = radioMember or {},
    }
end