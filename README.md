# FiveM Resource: Devon Weston Mansion

Devon Western Estates is a free ESX Legacy FiveM resource that adds a purchasable Devon Weston Mansion property to your GTA V roleplay server, including persistent housing ownership, server-side cash payment validation, mansion entry and exit interactions, a property blip, and an owner-only garage vehicle.

## Install

1. Copy the resource folder into your FiveM server's resources directory.
2. Add the following line to `server.cfg` after `oxmysql` and `es_extended`:
   `ensure devon_weston_mansion`
3. Restart the server.
4. The resource automatically creates its ownership table through oxmysql.
5. Edit `config.lua` if you want to change the price, coordinates, vehicle settings, interaction distances, notifications, or blip.

## Use

1. Travel to the Devon Weston Mansion location shown by the property blip.
2. Approach the entrance and press `E`.
3. If the mansion is unowned, use the purchase prompt to buy it with ESX cash.
4. The purchase is stored in the database and the mansion can only have one owner.
5. The owner can return to the entrance and press `E` to enter.
6. Inside, use the exit interaction to leave the mansion.
7. The owner can use the garage interaction to spawn the configured Schafter vehicle.
8. Change `Config.Price` and the coordinates in `config.lua` to match your server or custom mansion MLO.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/d2a6b9d9-ce8c-428f-86c9-6fafcdba54fc?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=d2a6b9d9-ce8c-428f-86c9-6fafcdba54fc
