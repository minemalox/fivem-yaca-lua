**yaca.systems for FiveM**

This is a example implementation for FiveM. Feel free to report bugs via issues or contribute via pull requests.

Join our Discord to get help or make suggestions and start using yaca.systems today!


For Use the Server-Events too, Enable it in the Configuration File

## Events Client / Server Triggerd From Skript

Is Player Muted:
Client-Event: "yaca:Voice:isMuted"
Server-Event: "yaca:Voice:isMuted:server"

Is Player Talking:
Client-Event: "yaca:Voice:isTalking"
Server-Event: "yaca:Voice:isTalking:server"

Player Voice State:
Client-Event: "yaca:Voice:state"
Server-Event: "yaca:Voice:state:server"


## Events Clients / Server to Trigger

Set Death of an Player:
[Client] :arrow_right yaca:voice:client:setPlayerDead 
[Server] :arrow_right yaca:voice:server:setPlayerDead

