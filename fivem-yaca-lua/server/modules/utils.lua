local generatedNames = {}

local Utils = {}

function Utils.generateRandomName(src)
    local name = nil

    for i = 1, 100, 1 do
        local randomName = string.random('...............', 15)
        if not generatedNames[randomName] then
            name = randomName
            generatedNames[name] = src
            break
        end
    end

    if not name then
        print("YACA: Couldn't generate a random name for player " .. GetPlayerName(src) .. " (" .. src .. ")" )
        return
    end

    return name
end

function Utils.removeGeneratedName(name)
    if not name then
        return
    end

    generatedNames[name] = nil
end

return Utils