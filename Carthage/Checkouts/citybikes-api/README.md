# iOS citybikes-api
Swift wrapper for http://citybik.es API

The wrapper allows you to easy access data from [citybik.es API](http://api.citybik.es/v2/) which is a display layer for [PyBikes](https://github.com/eskerda/pybikes). Contains over 260 bike networks (12 Jun 2015) over the world.

# Getting Started

Create sync manager - It'll notify when data has been fetched by `NSNotificationCenter`. When data is downloaded you get array of `CBNetwork` objects wit `CBStation` objects when this was request for networks and stations of just `CBNetwork` objects without stations if this was request refreshing networks.

    syncManager = CBSyncManager()
    syncManager.delegate = self

Notifications to observe:

    enum CBSyncManagerNotification: String {
        case DidUpdateNetworks = "DidUpdateNetworks"
        case DidUpdateStations = "DidUpdateStations"
    }
