--################################################################
--  Yaca Call Phone an Object that represent an Activ Call with Player ID 's  and other helping Methodes
--################################################################


function YacaCallPhone(callID,callStarted)
    return {
        callID = callID or 0,
        callStarted = callStarted or 0,
        callMemberList = {},
        isBreaked = false,
        addPlayerToCall = function (self,playerObject)
            table.insert(self.callMemberList,playerObject)
        end,
        removePlayerFromCall = function(self,playerID)
           for index,target in ipairs(self.callMemberList) do
                if target.serverID == playerID then
                    table.remove(self.callMemberList,index)
                end
           end 
        end
    }
end