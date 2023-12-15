YacaPlayerList = {}


RegisterNetEvent('yaca:server:initTeamspeak',function(clientID,teamspeakID,range)
   print('New Player was Added ' .. teamspeakID)
   player = YacaPlayer(clientID,source,false,teamspeakID,false,range,0,GetPlayerPed(source))
   table.insert(YacaPlayerList,player)
   print(dump(YacaPlayerList))
end)


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end



AddEventHandler('playerDropped', function (reason)
   if #YacaCallList > 0 then
      for index,element in ipairs(yacaPlayerList) do
         if element.serverID == source then
            table.remove(yacaPlayerList,index)
         end
      end
   end
end)