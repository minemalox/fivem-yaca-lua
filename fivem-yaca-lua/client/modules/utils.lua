local Utils = {}

function Utils.radarNotification(message)
    --[[
        ~g~ --> green
        ~w~ --> white
        ~r~ --> white
    ]]

    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

function Utils.getCamDirection()
    local rotVector = GetGameplayCamRot(0)
    local num = rotVector.z * 0.0174532924
    local num2 = rotVector.x * 0.0174532924
    local num3 = math.abs(math.cos(num2))

    return vector3(-math.sin(num) * num3, math.cos(num) * num3, GetEntityForwardVector(cache.ped).z)
end

return Utils