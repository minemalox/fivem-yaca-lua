local Statebags = {}

function Statebags.getLocalData()
    return LocalPlayer.state.yaca
end

function Statebags.setLocalData(key, value)
    local playerState = LocalPlayer.state.yaca

    if not playerState then
        return
    end

    playerState[key] = value

    LocalPlayer.state.yaca = playerState
end

function Statebags.getPlayerData(source)
    return Player(source).state.yaca
end

return Statebags