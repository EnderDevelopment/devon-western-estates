local ESX = exports['es_extended']:getSharedObject()
local propertyId = 'devon_weston_mansion'
local initialized = false
local purchaseInProgress = false

local function ensureTable()
    local success = pcall(function()
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `devon_weston_mansion` (
            `property` varchar(64) NOT NULL,
            `owner` varchar(64) NOT NULL,
            `purchased_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`property`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    end)
    initialized = success
    return success
end

CreateThread(function()
    while not ensureTable() do
        Wait(5000)
    end
end)

local function isReady()
    if not initialized then
        initialized = ensureTable()
    end
    return initialized
end

ESX.RegisterServerCallback('devon_mansion:getStatus', function(source, callback)
    if not isReady() then
        callback(false, false, true)
        return
    end

    local player = ESX.GetPlayerFromId(source)
    if not player then
        callback(false, false, true)
        return
    end

    local ok, row = pcall(function()
        return MySQL.single.await('SELECT owner FROM `devon_weston_mansion` WHERE property = ?', { propertyId })
    end)
    if not ok then
        callback(false, false, true)
        return
    end
    callback(row ~= nil, row ~= nil and row.owner == player.identifier, false)
end)

RegisterNetEvent('devon_mansion:buy', function()
    local source = source
    local player = ESX.GetPlayerFromId(source)
    if not player then return end
    if not isReady() or purchaseInProgress then
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.databaseError)
        return
    end

    purchaseInProgress = true
    local ok, result = pcall(function()
        local existing = MySQL.single.await('SELECT owner FROM `devon_weston_mansion` WHERE property = ?', { propertyId })
        if existing then
            return { status = 'owned', owner = existing.owner }
        end
        if player.getMoney() < Config.Price then
            return { status = 'funds' }
        end

        player.removeMoney(Config.Price)
        local inserted = MySQL.insert.await('INSERT INTO `devon_weston_mansion` (property, owner) VALUES (?, ?)', {
            propertyId,
            player.identifier
        })
        if not inserted then
            player.addMoney(Config.Price)
            return { status = 'error' }
        end
        return { status = 'purchased' }
    end)
    purchaseInProgress = false

    if not ok or not result then
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.databaseError)
        return
    end
    if result.status == 'owned' then
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.alreadyOwned)
        TriggerClientEvent('devon_mansion:status', source, true, result.owner == player.identifier)
    elseif result.status == 'funds' then
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.notEnough)
    elseif result.status == 'purchased' then
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.purchased)
        TriggerClientEvent('devon_mansion:status', source, true, true)
    else
        TriggerClientEvent('devon_mansion:notify', source, Config.Text.databaseError)
    end
end)

ESX.RegisterServerCallback('devon_mansion:isOwner', function(source, callback)
    if not isReady() then
        callback(false)
        return
    end

    local player = ESX.GetPlayerFromId(source)
    if not player then
        callback(false)
        return
    end

    local ok, row = pcall(function()
        return MySQL.single.await('SELECT owner FROM `devon_weston_mansion` WHERE property = ?', { propertyId })
    end)
    callback(ok and row ~= nil and row.owner == player.identifier)
end)
