## Yaca System for FiveM :snail

This is a example implementation for FiveM. Feel free to report bugs via issues or contribute via pull requests.

Join our Discord to get help or make suggestions and start using yaca.systems today!


For Use the Server-Events too, Enable it in the Configuration File

## Events Client / Server Triggerd From Skript

Is Player Muted: <br />
Client-Event: "yaca:Voice:isMuted" <br />
Server-Event: "yaca:Voice:isMuted:server" <br />

Is Player Talking: <br />
Client-Event: "yaca:Voice:isTalking" <br />
Server-Event: "yaca:Voice:isTalking:server" <br />

Player Voice State: <br />
Client-Event: "yaca:Voice:state" <br />
Server-Event: "yaca:Voice:state:server" <br />


## Events Clients / Server to Trigger

Set Death of an Player: <br />
[Client] :arrow_right yaca:voice:client:setPlayerDead <br />
[Server] :arrow_right yaca:voice:server:setPlayerDead <br />


Set Player an Freaquenz: <br />
[Client] :arrow_right yaca:voice:client:setRadioFreaqunz parameters[number: frequenz] <br />
[Server] :arrow_right yaca:voice:server:setRadioFreaqunz parameters[number: source ; number: frequenz]<br />
[Client] :arrow_right yaca:voice:client:setRadioFreaqunzWithJob parameters[number: frequenz, string: job]  <br />
[Server] :arrow_right yaca:voice:server:setRadioFreaqunzWihtJob parameters[number: source ; number: frequenz, string: job]<br />
