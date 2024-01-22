local PlayerVoiceSettings = {}
local PlayerVoicePlugin = {}
local PlayerRadioSettings = {}
local NameSet = {}

local function generateRandomString(length, possible)
    length = length or 50
    possible = possible or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    local text = "";
    for i = 1, length, 1 do
        local random = math.floor(math.random(1, length))
        text = text .. string.sub(possible, random, random)
    end

    return text
end

local function generateRandomName(source)
    local name

    for i = 1, 100, 1 do
        local generatedName = generateRandomString(15, "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789")

        if not NameSet[generatedName] then
            name = generatedName
            NameSet[generatedName] = true
            break
        end
    end

    if not name then
        -- TODO: handle this
        print("YACA: Couldn't generate a random name for player " .. GetPlayerName(source) .. " (" .. source .. ")" )
        return
    end

    return name
end

function connectToVoice(source)
    local name = generateRandomName(source)

    if not name then
        return
    end

    PlayerVoiceSettings[source] = {
        voiceRange = 3,
        voiceFirstConnect = false,
        maxVoiceRangeInMeter = 64,
        muted = false,
        ingameName = name,
    }

    PlayerRadioSettings[source] = {
        activated = false,
        currentChannel = 1,
        hasLong = false,
        frequencies = {}
    }

    connect(source)
end


function connect(source)
    if not PlayerVoiceSettings[source] then
        return
    end

    PlayerVoiceSettings[source].voiceFirstConnect = true

    TriggerClientEvent('client:yaca:init', source, {
        suid = Settings.UNIQUE_SERVER_ID,
        chid = Settings.CHANNEL_ID,
        deChid = Settings.DEFAULT_CHANNEL_ID,
        channelPassword = Settings.CHANNEL_PASSWORD,
        ingameName = PlayerVoiceSettings[source].ingameName,
    })
end

function playerUseMegaPhone(source, state)
    local playerState = Player(source).state

    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle and not true then
        return
    end

    local inSeatPed = GetPedInVehicleSeat(vehicle, -1)

    if vehicle and not (inSeatPed == ped) then
        return
    end

    if (not state and not playerState["yaca:megaphoneactive"]) or (state and playerState["yaca:megaphoneactive"]) then
        return
    end

    changeMegafonState(source, state)
end

function changeMegafonState(source, state, forced)
    forced = forced or false
    local playerState = Player(source).state

    if not state and playerState['yaca:megaphoneactive'] then
        playerState:set('yaca:megaphoneactive', nil, true)
        if forced then
            TriggerClientEvent('client:yaca:changeMegafonState', source, false)
        end
    elseif state and not playerState['yaca:megaphoneactive'] then
        playerState:set('yaca:megaphoneactive', 30, true)
    end
    
end

AddEventHandler('playerDropped', function()
    local src = source

    NameSet[PlayerVoiceSettings[src].ingameName] = nil
end)

RegisterNetEvent('server:yaca:changeVoiceRange', function(range)
    local src = source

    if PlayerVoiceSettings[src].maxVoiceRangeInMeter < range then
        return TriggerClientEvent("client:yaca:setMaxVoiceRange", src, PlayerVoiceSettings[src].maxVoiceRangeInMeter)
    end

    PlayerVoiceSettings[src].voiceRange = range
    TriggerClientEvent("client:yaca:changeVoiceRange", -1, src, range)

    if PlayerVoicePlugin[src] then
        PlayerVoicePlugin[src].range = range
    end
end)

RegisterNetEvent('server:yaca:lipsync', function(state, players)
    local src = source

    for _, targetId in pairs(players) do
        TriggerClientEvent('client:yaca:lipsync', targetId, src, state)
    end
end)

RegisterNetEvent('server:yaca:addPlayer', function(cid)
    local src = source

    PlayerVoicePlugin[src] = {
        cid = cid,
        muted = PlayerVoiceSettings[src].muted,
        range = PlayerVoiceSettings[src].voiceRange,
        playerId = src,
    }

    TriggerClientEvent("client:yaca:addPlayers", -1, PlayerVoicePlugin[src])

    local allPlayersData = {}
    for _, targetId in pairs(GetPlayers()) do
        if not PlayerVoicePlugin[targetId] or targetId == src then
            goto continue
        end

        allPlayersData[#allPlayersData + 1] = PlayerVoicePlugin[targetId]

        :: continue ::
    end

    TriggerClientEvent("client:yaca:addPlayers", src, allPlayersData)
end)

RegisterNetEvent('server:yaca:useMegaphone', function()

end)

RegisterNetEvent('server:yaca:noVoicePlugin', function()
    local src = source
    
    DropPlayer(src, "Dein Voiceplugin war nicht aktiviert!")
end)

RegisterNetEvent('server:yaca:wsReady', function(isFirstConnect)
    local src = source

    if not PlayerVoiceSettings[src] or not PlayerVoiceSettings[src].voiceFirstConnect then
        return
    end

    if not isFirstConnect then
        local name = generateRandomName(src)
        if not name then
            return
        end

        NameSet[PlayerVoiceSettings[src].ingameName] = nil
        PlayerVoiceSettings[src].ingameName = name
    end

    connect(src)
end)

RegisterNetEvent('server:yaca:enableRadio', function()

end)

RegisterNetEvent('server:yaca:changeRadioFrequency', function()

end)

RegisterNetEvent('server:yaca:muteRadioChannel', function()

end)

RegisterNetEvent('server:yaca:radioTalking', function()

end)

RegisterNetEvent('server:yaca:changeActiveRadioChannel', function()

end)

RegisterNetEvent('server:yaca:nuiReady', function()
    local src = source
    connectToVoice(src)
end)
