
# War API v1

### Overview

The War API allows developers to query information about the state of the current Foxhole World Conquest.

1. [Schema](#schema)
2. [Root Endpoint](#root-endpoint)
3. [API Endpoints](#api-endpoints)
    1. [Map Data](#map-data)
4. [Rate Limiting and Caching](#rate-limiting-and-caching)

## Schema

All data returned by the API is JSON. The API is accessed only via HTTPS at `https://war-service-live.foxholeservices.com`.

## Root Endpoint

The base of all API requests is `https://war-service-live.foxholeservices.com/api`. In this documentation all API
endpoints will be specified relative to this root.

## API Endpoints

### Map Data

#### List map names

`GET /worldconquest/maps`

Returns a list of the active World Conquest map names.

Note: The maps `HomeRegionC` and `HomeRegionW` are returned here, but do not have map data available in this version.

#### Get static map data

`GET /worldconquest/maps/:mapName/static`

Static map data includes things that never change over the lifecycle of a map. This includes
map text labels, resource nodes, and world structures.

You only need to request this once per map between World Conquests.

#### Get dynamic map data

`GET /worldconquest/maps/:mapName/dynamic/public`

Dynamic map data includes map icons that could change over the lifecycle of a map. This includes
static bases and static base build sites.

Team-specific data for and forward bases are excluded.

This data is updated every 5 minutes.

#### Map data schema

All endpoints that return map data have the same response format:

`GET /worldconquest/maps/:mapName/static`
```
{
  "regionId" : 1,
  "scorchedVictoryTowns": 0,
  "mapItems" : [ {
    "teamId" : "NONE",
    "iconType" : 22,
    "x" : 0.21965122,
    "y" : 0.6231655,
    "flags" : 0
  },

  ...

 ],
  "mapTextItems" : [ {
    "text" : "Abandoned Ward",
    "x" : 0.410076,
    "y" : 0.4957782
  },

  ...
 ],
  "worldExtentsMinX" : -61645.926,
  "worldExtentsMinY" : -84705.41,
  "worldExtentsMaxX" : 78413.08,
  "worldExtentsMaxY" : 82011.05,
  "warReport": {
        "totalEnlistments": 126,
        "colonialCasualties": 21,
        "wardenCasualties": 16
  },
  "lastUpdated" : 1524672871955,
  "version" : 2
}
```

Field descriptions:

- `regionId`: internal region ID for this map
- `worldExtents*`: minimum and maximum in-game world units. Used for mapping normalized coordinates to in-game coordinates.
- `lastUpdated`: timestamp in milliseconds from epoch of when this map was last updated
- `version`: version index, increments whenever this map data changes. Used for caching.

Map item fields:

- `teamId`: one of `NONE`, `WARDENS`, or `COLONIALS`.
- `iconType`: the type of the map icon, see the [Map Icons](#map-icons) section
- `x`, `y`: normalized map coordinate
- `flags`: bitmask of flags that apply to this icon, see the [Map Flags](#map-flags) section

Map text item fields:

- `text`: text string as it would appear on the map ingame
- `x`, `y`: normalized map coordinate

##### Map Icons

```
    PortBase(4)

    StaticBase1(5)
    StaticBase2(6)
    StaticBase3(7)

    ForwardBase1(8)
    ForwardBase2(9)
    ForwardBase3(10)

    Hospital          (11)
    VehicleFactory    (12)
    Armory            (13)
    SupplyStation     (14)
    Workshop          (15)
    ManufacturingPlant(16)
    Refinery          (17)
    Shipyard          (18)
    TechCenter        (19)

    SalvageField    (20)
    ComponentField  (21)
    FuelField       (22)
    SulfurField     (23)
    WorldMapTent    (24)
    TravelTent      (25)
    TrainingArea    (26)
    SpecialBase     (27) v0.14
    ObservationTower(28) v0.14
    Fort            (29) v0.14
    TroopShip       (30) v0.14
    ScrapMine       (31) v0.16
    SulfurMine      (32) v0.16
    StorageFacility (33) v0.17
    Factory         (34) v0.17
    Garrison Station(35) v0.20
    Ammo Factory	(36) v0.20
    Rocket Site 	(37) v0.20
```

##### Map Flags

```
    IsVictoryBase (0x01)
    IsHomeBase    (0x02)
    IsBuildSite   (0x04)
```

## Rate Limiting and Caching

We ask that you respect the caching headers as returned by the API. They reflect the lifetime of the data
returned in the body of the request and requests sooner than the cache expiry will return the same data.

The API fully supports [ETags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag).
API responses include the `ETag` header. When you make an API request, include the `If-None-Match`
header with the value of the `ETag` you last received from that endpoint. If the server returns `304 Not Modified`,
then your cached data is still the latest version.

It is good practice to use the ETag, as even though the cache may have expired the underlying data may not have changed.
For example in the case of dynamic map data, if no bases have changed teams within 5 minutes, the cache will have
expired but requests using the ETag will return `304 Not Modified`, preventing wasting bandwidth on duplicate data.
