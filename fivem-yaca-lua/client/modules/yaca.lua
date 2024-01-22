local playerYacaPlugin = {}

local YaCA = {}

function YaCA.init(dataObj)
    lib.print.verbose("[YACA-Websocket]: Init")

    NUI.connect()
    NUI.SetStoredData(dataObj)

    if NUI.FirstConnect then
        return
    end

    YaCA.initRequest(dataObj)
end

function YaCA.initRequest(dataObj)
    if not dataObj or not dataObj.suid or type(dataObj.chid) ~= "number" or not dataObj.deChid or not dataObj.ingameName or not dataObj.channelPassword then
        lib.print.error("[YACA]: Invalid init request")
        return
    end

    NUI.SendWSMessage({
        base = {
            ["request_type"] = "INIT"
        },
        server_guid = dataObj.suid,
        ingame_name = dataObj.ingameName,
        ingame_channel = dataObj.chid,
        default_channel = dataObj.deChid,
        ingame_channel_password = dataObj.channelPassword,
        excluded_channels = Settings["EXCLUDED_CHANNELS"], -- Channel ID's where users can be in while being ingame
        --[[
         * default are 2 meters
         * if the value is set to -1, the player voice range is taken
         * if the value is >= 0, you can set the max muffling range before it gets completely cut off
        ]]
        muffling_range = 2,
        build_type = YacaBuildType.RELEASE, -- 0 = Release, 1 = Debug,
        unmute_delay = 400,
        operation_mode = dataObj.useWhisper and 1 or 0,
    })
end

function YaCA.handleResponse(payload)
    if not payload then
        return
    end

    if payload.code == "OK" then
        if payload.requestType == "JOIN" then
            TriggerServerEvent("server:yaca:addPlayer", tonumber(payload.message))

            if rangeInterval then
                rangeInterval = false
                Wait(300)
            end

            CreateThread(calcPlayers)

            if radioInited then
                initRadioSettings()
            end
        end

        return
    end

    if payload.code == "TALK_STATE" or payload.code == "MUTE_STATE" then
        handleTalkState(payload)
        return
    end

    print(json.encode(payload))
    local message = locale(payload.code) or ("Unknown error!" .. (payload?.code and " (" .. payload.code .. ")" or ""))

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName('Voice: ' .. message)
    ThefeedSetNextPostBackgroundColor(6)
    EndTextCommandThefeedPostTicker(false, false)
end

function YaCA.addPlayers(dataObjects)
    if not dataObjects[0] then
        dataObjects = { dataObjects }
    end

    print("[YaCA-Websocket]: Add players", json.encode(dataObjects))
    for _, dataObj in pairs(dataObjects) do
        print("[YaCA-Websocket]: Add player", json.encode(dataObj))
        if not dataObj or not dataObj.range or not dataObj.cid or not dataObj.playerId then
            goto continue
        end

        playerYacaPlugin[dataObj.playerId] = {
            radioEnabled = playerYacaPlugin[dataObj.playerId]?.radioEnabled or false,
            cid = dataObj.cid,
            muted = dataObj.muted,
            range = dataObj.range,
            isTalking = false,
            phoneCallMemberIds = playerYacaPlugin[dataObj.playerId]?.phoneCallMemberIds or {},
        }

        :: continue ::
    end
end



return YaCA