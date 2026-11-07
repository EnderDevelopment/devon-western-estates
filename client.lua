local ESX = exports['es_extended']:getSharedObject()
local owned = false
local propertyOwned = false
local inside = false
local statusLoaded = false
local currentVehicle = nil

local function notify(message)
    if Config.UseESXShowNotification then
        ESX.ShowNotification(message)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
    end
end

RegisterNetEvent('devon_mansion:notify', notify)
RegisterNetEvent('devon_mansion:status', function(hasProperty, isOwner)
    propertyOwned = hasProperty
    owned = isOwner
    statusLoaded = true
end)

local function refreshStatus()
    ESX.TriggerServerCallback('devon_mansion:getStatus', function(hasProperty, isOwner, unavailable)
        if unavailable then
            statusLoaded = false
            return
        end
        propertyOwned = hasProperty
        owned = isOwner
        statusLoaded = true
    end)
end

local function drawText3D(coords, text)
    local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(screenX, screenY)
end

local function formatPrice()
    local value = tostring(Config.Price)
    while true do
        local updated, count = value:gsub('^(%-?%d+)(%d%d%d)', '%1,%2')
        value = updated
        if count == 0 then break end
    end
    return value
end

local function enterMansion()
    if not owned then
        notify(Config.Text.notOwned)
        return
    end
    local interior = Config.Mansion.interior
    SetEntityCoords(PlayerPedId(), interior.x, interior.y, interior.z, false, false, false, false)
    inside = true
end

local function leaveMansion()
    local exterior = Config.Mansion.exterior
    SetEntityCoords(PlayerPedId(), exterior.x, exterior.y, exterior.z, false, false, false, false)
    inside = false
end

local function takeOutVehicle()
    ESX.TriggerServerCallback('devon_mansion:isOwner', function(isOwner)
        if not isOwner then
            owned = false
            notify(Config.Text.notOwned)
            return
        end

        local spawn = Config.Mansion.garageSpawn
        if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
            notify(Config.Text.vehicleSpawnBlocked)
            return
        end

        if currentVehicle and DoesEntityExist(currentVehicle) then
            DeleteVehicle(currentVehicle)
            currentVehicle = nil
        end

        ESX.Game.SpawnVehicle('schafter3', vector3(spawn.x, spawn.y, spawn.z), spawn.w, function(vehicle)
            currentVehicle = vehicle
            SetVehicleOnGroundProperly(vehicle)
            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            notify(Config.Text.vehicleOut)
        end)
    end)
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end
    refreshStatus()

    local blip = AddBlipForCoord(Config.Mansion.exterior.x, Config.Mansion.exterior.y, Config.Mansion.exterior.z)
    SetBlipSprite(blip, Config.Mansion.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Mansion.blip.scale)
    SetBlipColour(blip, Config.Mansion.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Mansion.name)
    EndTextCommandSetBlipName(blip)

    while true do
        local waitTime = 900
        local coords = GetEntityCoords(PlayerPedId())
        local point = inside and Config.Mansion.exit or Config.Mansion.exterior
        local distance = #(coords - point)

        if distance < Config.DrawDistance then
            waitTime = 0
            if inside then
                drawText3D(Config.Mansion.exit + vector3(0.0, 0.0, 0.35), Config.Text.exit)
                if distance < Config.InteractionDistance and IsControlJustReleased(0, 38) then
                    leaveMansion()
                end
            elseif not statusLoaded then
                refreshStatus()
            elseif not propertyOwned then
                local prompt = string.format(Config.Text.buy, Config.Currency, formatPrice())
                drawText3D(Config.Mansion.exterior + vector3(0.0, 0.0, 0.35), prompt)
                if distance < Config.InteractionDistance and IsControlJustReleased(0, 38) then
                    TriggerServerEvent('devon_mansion:buy')
                end
            else
                local prompt = owned and Config.Text.enter or Config.Text.alreadyOwned
                drawText3D(Config.Mansion.exterior + vector3(0.0, 0.0, 0.35), prompt)
                if owned and distance < Config.InteractionDistance and IsControlJustReleased(0, 38) then
                    enterMansion()
                end

                local garageDistance = #(coords - Config.Mansion.garage)
                if owned and garageDistance < Config.DrawDistance then
                    drawText3D(Config.Mansion.garage + vector3(0.0, 0.0, 0.35), Config.Text.garage)
                    if garageDistance < Config.InteractionDistance and IsControlJustReleased(0, 38) then
                        takeOutVehicle()
                    end
                end
            end
        end
        Wait(waitTime)
    end
end)
