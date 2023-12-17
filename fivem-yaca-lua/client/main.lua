/**
    Yaca - Voice System for Fivem

    Disclaimer:
    Editing the code is at your own risk and only if you have advanced knowledge
**/

--####################################################
--#         Parametes and Help Function              #
--####################################################
VoiceState = nil
TeamspeakName = nil
PlayerInNear = {}
OwnPlayerObj = nil


--##################################################################
--#  Function to generate an Random String for the Teamspeak-Name
--##################################################################
function GenerateRandomString(length)
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    local random = math.random
 
    for i = 1, length do
        local randomIndex = random(1, #characters)
        randomString = randomString .. string.sub(characters, randomIndex, randomIndex)
    end
 
    return randomString
end

function InitTeamspeakPlugin()
    ingameName = Config.voice_InGame_Name_Prefix .. '' .. GenerateRandomString(20)
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
        useWhisper = Config.voice_use_whisper,
    })
end

function UnInitTeamspeakPlugin()
    SendNUIMessage({
        actionCMD = 'UnInit',
    })
end

function GetCamDirection()
    local rotVector = GetGameplayCamRot(0)
    local num = rotVector.z * 0.0174532924
    local num2 = rotVector.x * 0.0174532924
    local num3 = math.abs(math.cos(num2))

    return vector3(-math.sin(num) * num3,math.cos(num) * num3,GetEntityForwardVector(GetPlayerPed(-1)).z)
end


--####################################################################
--#         Own created Events and Default / NUI Events              #
--####################################################################
RegisterNetEvent('onClientResourceStart',function(resource)
    if(resource == GetCurrentResourceName()) then
        print('[Yaca-Voice] System succesfull started!')
        Wait(100)
        InitTeamspeakPlugin()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    UnInitTeamspeakPlugin()
    Wait(100)
    print('[Yaca-Voice] System succesfull stopped!')
  end)

RegisterNuiCallback('nuiTeamspeakInit',function (data)
    TeamspeakName = data.teamspeakName
    clientID = data.clientID
    TriggerServerEvent('yaca:server:initTeamspeak',clientID,TeamspeakName,Config.InGame_Default_Range_by_Start)
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

RegisterNetEvent("yaca:Voice:upDatePlayerInNear",function(playerinnear)
    PlayerInNear = playerinnear
end)

RegisterNetEvent("yaca:Voice:setPlayerOBJ",function(playerObj)
    OwnPlayerObj = playerObj
end)

RegisterNetEvent("yaca:Voice:checkInitState",function ()
    if teamspeakName == nil then
        InitTeamspeakPlugin()
    end
end)


CreateThread(function ()
    while true do
        if #PlayerInNear > 0 then
            if OwnPlayerObj ~= nil then
                local pCoords = GetEntityCoords(GetPlayerPed(-1))
                local currentRoom = GetRoomKeyFromEntity(GetPlayerPed(-1))
                PlayerinRange = {}

                if pCoords ~= nil then
                    for _,target in ipairs(PlayerInNear) do
                        local tCoords  = GetEntityCoords(target.gtaPlayerObject)
                        if tCoords ~= nil then
                            if #(pCoords - tCoords) <= OwnPlayerObj.range then
                                local muffleIntensity = 0;
                                if (currentRoom ~= GetRoomKeyFromEntity(GetPlayerPed(target.gtaPlayerObject)) and not HasEntityClearLosToEntity(GetPlayerPed(-1),GetPlayerPed(target.gtaPlayerObject), 17)) then
                                    muffleIntensity = 10; -- 10 is the maximum intensity
                                end
                                table.insert(PlayerinRange,{
                                    client_id = target.clientID,
                                    position = tCoords,
                                    direction = GetPlayerCameraRotation(target.gtaPlayerObject),
                                    range = target.range,
                                    is_underwater = IsPedSwimmingUnderWater(GetPlayerPed(target.gtaPlayerObject)),
                                    muffle_intensity = muffleIntensity
                                    --is_muted = target.isMuted
                                })
                            end
                        end
                    end
                end
                
                if OwnPlayerObj.isDead == true then
                    SendNUIMessage({
                        actionCMD = "sendPlayer",
                        player_direction = GetCamDirection(),
                        player_position = pCoords,
                        --player_range = player.range,
                        player_is_underwater = player.isSwimming,
                        player_is_muted = player.isDead,
                        players_list = json.encode(PlayerinRange)
                    })
                else
                    SendNUIMessage({
                        actionCMD = "sendPlayer",
                        player_direction = GetCamDirection(),
                        player_position = pCoords,
                        --player_range = player.range,
                        player_is_underwater = player.isSwimming,
                        player_is_muted = player.IsMuted,
                        players_list = json.encode(PlayerinRange)
                    })
                end
            end
        end
        Wait(300)
    end
end)