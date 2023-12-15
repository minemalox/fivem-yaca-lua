let socket;
let firstConnection = true;
let teamspeakName = null;


class YacaVoice {
    plugin = {
        radioEnabled: false,
        clientID: "",
        forceMute: false,
        range: 2,
        phoneCallMemberIds: [],
        isTalking: false,
    }

    localPlugin = {
        canChangeVoiceRange: false,
        maxVoiceRange: false,
        lastMegaphoneState: false,
        canUseMegaphone: false
    }

    filter = {
        radio: "RADIO",
        megaphone: "MEGAPHONE",
        phone: "PHONE",
        phone_speaker: "PHONE_SPEAKER",
        intercom: "INTERCOM",
        phone_historical: "PHONE_HISTORICAL",
    }

    steroMode = {
        mono_left: "MONO_LEFT",
        mono_right: "MONO_RIGHT",
        stero: "STEREO",
    }
}






function handleRequst(event){
    console.log(event.data);
    let YacaObjekt = JSON.parse(event.data);
    let YacaVoiceCode = YacaObjekt.code;

    switch(YacaVoiceCode){
        case "WAIT_GAME_INIT":
            $.post("https://fivem-yaca-lua/nuiYacaVoiceState",JSON.stringify({
                status: 0,
                message:"",
            }));
        break;
        
        case 'OK':
                if(YacaObjekt.requestType == "JOIN"){
                    if(teamspeakName != null){
                        $.post("https://fivem-yaca-lua/nuiTeamspeakInit",JSON.stringify({
                            status: 1,
                            teamspeakName: teamspeakName,
                            clientID: parseInt(YacaObjekt.message),
                        }));
                    }
                }
            break;

        case "WRONG_TS_SERVER":
            $.post("https://fivem-yaca-lua/nuiYacaVoiceState",JSON.stringify({
                status: 0,
                message:"WRONG_TS_SERVER",
            }));
        break;
        case "OUTDATED_VERSION":
            $.post("https://fivem-yaca-lua/nuiYacaVoiceState",JSON.stringify({
                status: 0,
                message:"OUTDATED_VERSION",
            }));
        break;
        case "MUTE_STATE":
            if(YacaObjekt.message == "1"){
                $.post("https://fivem-yaca-lua/nuiYacaVoiceisMuted",JSON.stringify({
                    status: true,
                }));
            }else if(YacaObjekt.message == "0"){
                $.post("https://fivem-yaca-lua/nuiYacaVoiceisMuted",JSON.stringify({
                    status: false,
                }));
            }
        break;
        case "TALK_STATE":
            if(YacaObjekt.message == 1){
                $.post("https://fivem-yaca-lua/nuiYacaVoiceisTalking",JSON.stringify({
                    status: true
                }));
            }else if(YacaObjekt.message == 0){
                $.post("https://fivem-yaca-lua/nuiYacaVoiceisTalking",JSON.stringify({
                    status: false
                }));
            }
        break;
    }
}


function init(dataObj){
    this.socket = new WebSocket("ws://127.0.0.1:30125");
    this.socket.addEventListener("message",(event)=>{
        this.handleRequst(event);
    });

    this.socket.onerror = function(event){
        console.log("[Yaca-WebSocket] Error: ",event);
    }

    this.socket.onclose = function(event){
        console.log("[Yaca-WebSocket] Close: ",event);
    }


    this.socket.addEventListener("open",(event)=>{
        buildType = 0

        if(dataObj.voice_Build_Type == "Release"){
            buildType = 0;
        }else if(dataObj.voice_Build_Type == "Debug"){
            buildType = 1;
        }

        teamspeakName = dataObj.ingameName;

        sendWebSocket({
            base: {"request_type": "INIT"},
            server_guid: dataObj.suid,
            ingame_name: dataObj.ingameName,
            ingame_channel: dataObj.chid,
            default_channel: dataObj.deChid,
            ingame_channel_password: dataObj.channelPassword,
            excluded_channels: JSON.parse(dataObj.channelToMoveWhenINGame), // Channel ID's where users can be in while being ingame
            /**
             * default are 2 meters
             * if the value is set to -1, the player voice range is taken
             * if the value is >= 0, you can set the max muffling range before it gets completely cut off
             */
            muffling_range: dataObj.muffling_range
            //build_type: dataObj.voice_Build_Type,
            //unmute_delay: 400
        })
    });
}



function sendWebSocket(msg){
    if(this.socket != null){
        this.socket.send(JSON.stringify(msg))
    }
}



window.addEventListener("message",(event)=>{
    if(event.data.actionCMD == 'init'){
        console.log("INIT - Web Socket")
        init(event.data);
    }else if(event.data.actionCMD == 'sendPlayer'){
        sendWebSocket({
            base: {request_type: "INGAME"},
            player: {
                player_direction: event.data.player_direction,
                player_position: event.data.player_position,
                player_range: event.data.player_range,
                player_is_underwater: event.data.player_is_underwater,
                //player_is_muted: event.data.player_is_muted,
                players_list: event.data.players_list
            }
        })
    }
})

