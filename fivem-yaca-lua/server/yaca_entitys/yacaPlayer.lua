--################################################################
--  Yaca Player is a self made Player Object for handling
--################################################################


function YacaPlayer(clientID,serverID,isSwimming,teamspeakID,isMuted,range,muffleIntensity,gtaPlayerObject)
    return {
        --#################################################
        --  Parameters
        --#################################################
        clientID = clientID or 0,
        serverID = serverID or 0,
        teamspeakID = teamspeakID or nil,
        isSwimming = isSwimming or false,
        isMuted = isMuted or false,
        range = range or 2,
        muffleIntensity =  muffleIntensity or 0,
        gtaPlayerObject = gtaPlayerObject or 0,
        callID = 0,
        isDead = false,
        upDateCallID = function(self,callID)
            self.callID = callID or 0
        end

        --##################################################
        --  Methode for Updating value of the Object
        --#################################################
    }
end
