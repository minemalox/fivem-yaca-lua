let isConnected = false;
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
        console.error(event);
        sendNuiData("YACA_OnMessage", event.data);
    };

    webSocket.onerror = (event) => {
        console.error(event);
        sendNuiData("YACA_OnError", event);
    };

    webSocket.onopen = () => {
        isConnected = true;
        sendNuiData("YACA_OnConnected");
    };

    webSocket.onclose = (event) => {
        console.log(event)
        isConnected = false;

        sendNuiData("YACA_OnDisconnected", {
            code: event.code, 
            reason: event.reason
        });

        connect();
    }
}

function runCommand(command) {
    if (!isConnected || typeof command !== "string") {
        return;
    }

    webSocket.send(command);
}

function sendNuiData(event, data) {
    if (typeof data === "undefined") {
        $.post(`http://${GetParentResourceName()}/${event}`);
    }
    else {
        $.post(`http://${GetParentResourceName()}/${event}`, data);
    }
}

$(function () {
    window.addEventListener("DOMContentLoaded", function () {
        sendNuiData("YACA_OnNuiReady");
    });

    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case "connect":
                connect();
                break;
            case "command":
                runCommand(event.data.data);
                break;
        }
    }, false);
});