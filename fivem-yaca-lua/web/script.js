let isConnected = false;
let serverUniqueIdentifierFilter = null;

// Packet Stats
let packetsSent = 0;
let packetsReceived = 0;
let lastCommand = "";

let webSocket = null;

function connect() {
    console.log("connecting...");

    try {
        webSocket = new window.WebSocket(`ws://127.0.0.1:30125/`);
    }
    catch {
        // do nothing
    }

    webSocket.onmessage = (event) => {
        sendNuiData("YACA_OnMessage", event.data);

        packetsReceived++;
        updateHtml();
    };

    webSocket.onerror = (event) => {
        console.error(event);
        sendNuiData("YACA_OnError", event);
    };

    webSocket.onopen = () => {
        isConnected = true;
        console.log("[YACA] connected");

        sendNuiData("YACA_OnConnected");
    };

    webSocket.onclose = (event) => {
        isConnected = false;

        console.log(event)

        sendNuiData("YACA_OnDisconnected", {
            code: event.code, 
            reason: event.reason
        });

        connect();
    }
}

function setWebSocketAddress(address) {
    if (typeof address === "string")
        pluginAddress = address;
}

function setServerUniqueIdentifierFilter(serverUniqueIdentifier) {
    if (typeof serverUniqueIdentifier === "string")
        serverUniqueIdentifierFilter = serverUniqueIdentifier;
}

function runCommand(command) {
    if (!isConnected || typeof command !== "string") {
        lastCommand = "unexpected command";
        updateHtml();

        return;
    }

    webSocket.send(command);

    packetsSent++;
    lastCommand = command;
    updateHtml();
}

function sendNuiData(event, data) {
    if (typeof data === "undefined") {
        $.post(`http://${GetParentResourceName()}/${event}`);
    }
    else {
        $.post(`http://${GetParentResourceName()}/${event}`, data);
    }
}

function showBody(show) {
    if (show) {
        $("body").show();
    }
    else {
        $("body").hide();
    }
}

$(function () {
    window.addEventListener("DOMContentLoaded", function () {
        //connect();
        updateHtml();

        sendNuiData("YACA_OnNuiReady");
    });

    window.addEventListener('message', function (event) {
        if (typeof event.data.Function === "string") {
            if (typeof event.data.Params === "undefined") {
                window[event.data.Function]();
            }
            else if (Array.isArray(event.data.Params) && event.data.Params.length == 1) {
                window[event.data.Function](event.data.Params[0]);
            }
            else {
                window[event.data.Function](event.data.Params);
            }
        }
    }, false);
});