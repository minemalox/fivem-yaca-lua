/**
    Yaca - Voice System for Fivem

    Disclaimer:
    Editing the code is at your own risk and only if you have advanced knowledge
**/

local VoiceState = nil
local teamspeakName = nil


function generateRandomString(length)
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    local random = math.random
 
    for i = 1, length do
        local randomIndex = random(1, #characters)
        randomString = randomString .. string.sub(characters, randomIndex, randomIndex)
    end
 
    return randomString
end


RegisterNetEvent('onClientResourceStart',function(resource)
    if(resource == GetCurrentResourceName()) then
        print('[Yaca-Voice] System succesfull started!')
        Wait(100)
        initTeamspeakPlugin()
    end
end)

function initTeamspeakPlugin()
    ingameName = Config.voice_InGame_Name_Prefix .. '' .. generateRandomString(20)
    SendNUIMessage({
        actionCMD = 'init',
        suid = Config.voice_UniqueServerID,
        ingameName = ingameName,
        chid = Config.voice_CHANNEL_ID,
        deChid = Config.voice_DEFAULT_CHANNEL_ID,
        channelPassword = Config.voice_CHANNEL_PASSWORD,
        channelToMoveWhenINGame = json.encode(Config.voice_InGame_Side_Channels),
        muffling_range = Config.InGame_Default_Range_by_Start,
        voice_Build_Type = Config.voice_Build_Type,
    })
end

RegisterNuiCallback('nuiTeamspeakInit',function (data)
    teamspeakName = data.teamspeakName
    clientID = data.clientID
    TriggerServerEvent('yaca:server:initTeamspeak',clientID,teamspeakName,Config.InGame_Default_Range_by_Start)
end)


RegisterNUICallback("nuiYacaVoiceisMuted", function(data)
    TriggerEvent("yaca:Voice:isMuted",data.status)
    if Config.ActivateServerEventTrigger then
        TriggerServerEvent("yaca:Voice:isMuted:server", data.status)
    end
end)

RegisterNUICallback("nuiYacaVoiceisTalking",function(data)
    TriggerEvent("yaca:Voice:isTalking",data.status)
    if Config.ActivateServerEventTrigger then
        TriggerServerEvent("yaca:Voice:isTalking:server", data.status)
    end
end)

RegisterNUICallback("nuiYacaVoiceState",function(data)
    VoiceState = data.status
    TriggerEvent("yaca:Voice:state",data.status)
    if Config.ActivateServerEventTrigger then
        TriggerServerEvent("yaca:Voice:state:server",data.status)
    end
end)

RegisterNetEvent("yaca:Voice:sendData:Ui",function(data)
    SendNUIMessage(data)
end)
