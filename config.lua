Config = {}

Config.Locale = 'en'
Config.Currency = '$'
Config.Price = 12000000
Config.InteractionDistance = 2.0
Config.DrawDistance = 25.0
Config.UseESXShowNotification = true

Config.Mansion = {
    name = 'Devon Weston Mansion',
    exterior = vector3(-1034.62, 4910.47, 205.08),
    entrance = vector3(-1034.62, 4910.47, 205.08),
    interior = vector3(-1045.33, 4912.69, 205.08),
    exit = vector3(-1045.33, 4912.69, 205.08),
    garage = vector3(-1040.49, 4898.46, 205.06),
    garageSpawn = vector4(-1035.94, 4895.92, 205.05, 183.0),
    blip = {
        sprite = 40,
        color = 2,
        scale = 0.85
    }
}

Config.Text = {
    buy = 'Press ~INPUT_CONTEXT~ to buy the Devon Weston Mansion for %s%s',
    enter = 'Press ~INPUT_CONTEXT~ to enter the Devon Weston Mansion',
    exit = 'Press ~INPUT_CONTEXT~ to leave the mansion',
    garage = 'Press ~INPUT_CONTEXT~ to take out your mansion vehicle',
    notEnough = 'You do not have enough money to buy this mansion.',
    purchased = 'You purchased the Devon Weston Mansion.',
    alreadyOwned = 'This mansion is already owned.',
    notOwned = 'You do not own this mansion.',
    vehicleSpawnBlocked = 'The mansion vehicle spawn point is blocked.',
    vehicleOut = 'Your mansion vehicle is ready.',
    databaseError = 'The property service is temporarily unavailable.',
    invalidRequest = 'That property request is not valid.'
}
