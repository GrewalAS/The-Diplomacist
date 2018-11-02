//
//  Reachability.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2016-07-21.
//  Copyright © 2016 The Diplomacist. All rights reserved.
//

// Code not written by Amrinder Greawl
// Written by Leo Dabus at http://stackoverflow.com/questions/30743408/check-for-internet-connection-in-swift-2-ios-9

import SystemConfiguration

//  MARK: Class itself, Used to see if the device is connected to the internet

open class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
