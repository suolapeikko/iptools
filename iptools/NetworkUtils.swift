//
//  NetworkUtils.swift
//  iptools
//

import Foundation
import SystemConfiguration

struct NetworkUtils {

    /// This function returns the active network interface (IPv4) ip address
    ///
    /// - returns: Optional active ip address
    func getActiveIFAddress() -> String? {
        
        var ip: String?
        
        if let interface = getActiveNetworkInterfaceName() {
            ip = getIFAddress(interfaceName: interface)
        }
        
        return ip
    }
    
    /// This function returns the name of the active network interface (IPv4), eg. en0, en1
    ///
    /// - returns: Optional active network interface name, eg. en0, en1
    func getActiveNetworkInterfaceName() -> String? {
        
        var interfaceName: String?
        let dynRef = SCDynamicStoreCreate(kCFAllocatorSystemDefault, "iked" as CFString, nil, nil)
        let ipv4key = SCDynamicStoreCopyValue(dynRef, "State:/Network/Global/IPv4" as CFString)
        //let ipv6key = SCDynamicStoreCopyValue(dynRef, "State:/Network/Global/IPv6" as CFString)
        if let dict1 = ipv4key as? [String: AnyObject] {
            interfaceName = (dict1["PrimaryInterface"] as! String)
        }
        //if let dict2 = ipv6key as? [String: AnyObject] {
        //    interfaceName = (dict2["PrimaryInterface"] as! String)
        //}
        
        return interfaceName
    }

    /// This function returns the ip address (ipv4) based on the supplied network interface name, eg. en0, en1
    ///
    /// - parameters:
    ///   - String: Optional active network interface name, eg. en0, en1
    /// - returns: IP address as String
    func getIFAddress(interfaceName:String) -> String? {

        var address: String?
        
        // Get list of all interfaces
        var ifaddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddress) == 0 else { return address }
        guard let firstAddress = ifaddress else { return address }
        
        // Iterate all interfaces
        for ptr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            let interface = String(cString:ptr.pointee.ifa_name)

            // Check for running IPv4 or IPv6 interfaces, skipping the loopback interface
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) {
                    
                    // Find only the one with the supplied interface name
                    if interface.caseInsensitiveCompare(interfaceName) == ComparisonResult.orderedSame {
                        // Convert interface address to a string
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
        }
        
        freeifaddrs(ifaddress)
        
        return address
    }
    
    /// This function returns all active network interface in an array
    ///
    /// - returns: A String array of active ipv4 and ipv6 network interface addresses
    func getIFAddresses() -> [String] {
        
        var addresses = [String]()
        
        // Get list of all interfaces
        var ifaddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddress) == 0 else { return [] }
        guard let firstAddr = ifaddress else { return [] }
        
        // Iterate all interfaces
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4 or IPv6 interfaces, skipping the loopback interface
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a string
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddress)
        
        return addresses
    }

    /// This function returns all active network interface in an array
    ///
    /// - returns: A [String:String] dictionary of active ipv4 and ipv6 network interface addresses with interface names and families
    func getIFAddressesWithIFNamesAndIPVFamilies() -> [String:String] {
        
        var addresses = [String:String]()
        
        // Get list of all interfaces
        var ifaddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddress) == 0 else { return [:] }
        guard let firstAddr = ifaddress else { return [:] }
        
        // Iterate all interfaces
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            let interface = String(cString:ptr.pointee.ifa_name)

            // Check for running IPv4 or IPv6 interfaces, skipping the loopback interface
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) {
                    
                    // Convert interface address to a string
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses[interface + "/inet"] = address
                    }
                }
                if addr.sa_family == UInt8(AF_INET6) {

                    // Convert interface address to a string
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses[interface + "/inet6"] = address
                    }
                }
            }
        }
        
        freeifaddrs(ifaddress)
        
        return addresses
    }
    
    /// This function returns all active network interface names in an array
    ///
    /// Examples:
    ///
    /// 1) "awdl0" is AWDL (Apple Wireless Direct Link) and is reserved for AirDrop, GameKit (which also uses Bluetooth) and AirPlay
    /// 2) "en0", "en1" etc. Typically Wi-Fi or wired ethernet interfaces
    /// 3) "utun0" is reserved for "Back to My Mac"
    ///
    /// - returns: A String array of active ipv4 and ipv6 network interface names
    func getIFNames() -> [String] {
        
        var addressNames = [String]()
        
        // Get list of all interfaces
        var ifaddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddress) == 0 else { return [] }
        guard let firstAddr = ifaddress else { return [] }
        
        // Iterate all interfaces
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            let interface = String(cString:ptr.pointee.ifa_name)

            // Check for running IPv4 or IPv6 interfaces, skipping the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    addressNames.append(interface)
                }
            }
        }
        
        freeifaddrs(ifaddress)
        
        return addressNames
    }

    /// This function splits an if address to int array using comma as value separator
    ///
    /// - parameters:
    ///   - String: ip address
    /// - returns: Comma separated int values in an array
    func ipAddressSeparatedByCommaToArray(ipaddress: String?) -> [Int] {
        
        var intArray = [Int]()
        if let stringArray = ipaddress?.components(separatedBy: ".") {
            if(stringArray.count>0 && stringArray[0] != "") {
                intArray = stringArray.map { Int($0)!}
            }
        }

        return intArray
    }
}
