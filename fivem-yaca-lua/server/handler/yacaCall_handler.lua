--#############################################################
--#     This Handle is for Smartphone Calls to handling it
--#############################################################

YacaCallList = {}

function GetRandomCallID()
    math.randomseed(os.clock()*100000000000)
    return math.random(10000, 65000)
end


RegisterNetEvent('yaca:voice:server:initCall',function(listOfCallMember)
    local callID = GetRandomCallID()
    local newCall = YacaCallPhone(callID,source)

    for _,memberID in ipairs(listOfCallMember) do
        for index,yacaPlayer in ipairs(YacaPlayerList) do
            if memberID == yacaPlayer.serverID then
                yacaPlayer.callID = callID
                table.insert(YacaPlayerList,index,yacaPlayer)
                newCall.addPlayerToCall(yacaPlayer)
            end
        end
    end

    table.insert(YacaCallList,newCall)
    print('[YACA - Voice ] Call is created with CallID ' .. callID)
end)


RegisterNetEvent('yaca:voice:server:RemovePlayer',function (callID,targetID)
    for _,call in ipairs(YacaCallList) do
        if call.callID == callID then
            call.removePlayerFromCall(targetID)
        end    
    end
end)

RegisterNetEvent('yaca:voice:server:AddPlayer',function (callID,targetID)
    for _,call in ipairs(YacaCallList) do
        if call.callID == callID then
            for _,yacaPlayer in ipairs(YacaPlayerList) do
                if yacaPlayer.serverID == targetID then
                    call.addPlayerToCall(yacaPlayer)
                end
            end
        end
    end
end)
