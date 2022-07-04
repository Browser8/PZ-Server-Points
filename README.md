# PZ-Server-Points [![Steam Downloads](https://img.shields.io/steam/downloads/2823055977?label=Downloads&logo=steam&style=flat-square)](https://steamcommunity.com/sharedfiles/filedetails/?id=2823055977)

A mod to provide server owners with a way to reward players for playing on their server.

## Configuration
The configuration file is located in `%USER%/Zomboid/Lua` and is called ServerPointsListings.ini.

Valid syntax is the following:
```lua
return {
    TabName = {
        {
            type = "ITEM",
            target = "Base.Rake",
            quantity = 1,
            price = 100
        },
        {
            type = "ITEM",
            target = "Base.Book",
            quantity = 2,
            price = 400
        }
    },
    AnotherTab = {
        {
            type = "VEHICLE",
            target = "Base.SpiffoVan",
            price = 1000
        },
        [...]
    },
    [...]
}
```
`[...]` is used in place of more entries in the config for demonstration purposes, in the real config you would have actual entries.

The supported types are:
* ITEM
* XP
* VEHICLE
