Settings = {}

if IsDuplicityVersion() then
    Settings = {
        -- Max Radio Channels
        ["maxRadioChannels"] = 9, -- needs to be sync with serverside setting
    
        -- Unique Teamspeakserver ID
        ["UNIQUE_SERVER_ID"] = "IJxpovZOnwvH7IOLBhXyZa69Ofk=",
    
        -- Ingame Voice Channel ID
        ["CHANNEL_ID"] = 3,
    
        -- Ingame Voice Channel Password
        ["CHANNEL_PASSWORD"] = "a**jC.UAcYPWuuK!vCYccaLJp!zz9X",
    
        -- Default Teamspeak Channel, if player can't be moved back to his old channel
        ["DEFAULT_CHANNEL_ID"] = 1,

        ["EXCLUDED_CHANNELS"] = { 1337 }
    }
else
    Settings = {
        -- Max Radio Channels
        ["maxRadioChannels"] = 9, -- needs to be sync with serverside setting
    
        -- Max phone speaker range
        ["maxPhoneSpeakerRange"] = 5,
    }
end