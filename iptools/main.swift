//
//  main.swift
//  iptools
//

import Foundation

let args = CommandLine.arguments
let argCount = CommandLine.arguments.count
var errorFlag = false
let utils = NetworkUtils()

// CONVERT ALL THIS PARAMETER STUFF TO LINUX-STYLE GETOPT_LONGARGC / ARGV AT SOME POINT OF TIME

if(argCount>1) {
    
    // Switch and run based on main argument value
    switch(args[1]) {

    case "-getactiveifaddress":
        if(argCount==2) {
            print(utils.getActiveIFAddress() ?? "No active ifaddress for \(args[2])")
        }
        else {
            print("Incorrect amount of arguments for -getactiveifaddress. Should be -getactiveifaddress" )
        }

    case "-getifaddress":
        if(argCount==3) {
            print(utils.getIFAddress(interfaceName: args[2]) ?? "No active ifaddress for \(args[2])")
        }
        else {
            print("Incorrect amount of arguments for -getifaddress. Should be -getifaddress <ifname>" )
        }

    case "-getactiveifname":
        if(argCount==2) {
            print(utils.getActiveNetworkInterfaceName() ?? "No active ipv4 or ipv6 network interface")
        }
        else {
            print("Incorrect amount of arguments for -getactiveifname. Should be -getactiveifname <ifname>" )
        }
        
    case "-getifaddresses":
        if(argCount==2) {
            print(utils.getIFAddresses())
        }
        else {
            print("Incorrect amount of arguments for -getifaddresses. Should be -getifaddresses" )
        }

    case "-getifnames":
        if(argCount==2) {
            print(utils.getIFNames())
        }
        else {
            print("Incorrect amount of arguments for -getifnames. Should be -getifnames" )
        }

    case "-getifaddresseswithnames":
        if(argCount==2) {
            print(utils.getIFAddressesWithIFNamesAndIPVFamilies())
        }
        else {
            print("Incorrect amount of arguments for -getifaddresseswithnames. Should be -getifaddresseswithnames" )
        }

    case "-putaddresstoarray":
        if(argCount==3) {
            print(utils.ipAddressSeparatedByCommaToArray(ipaddress: args[2]))
        }
        else {
            print("Incorrect amount of arguments for -putaddresstoarray. Should be -putaddresstoarray" )
        }
        
    default:
        errorFlag = true
    }
}
else {
    errorFlag = true
}

if(errorFlag) {
    print("iptools: Command line utility for getting network interface values\n");
    print("         Usage:");
    print("         iptools -getactiveifaddress                 Active Interface address (IPv4)");
    print("         iptools -getifaddress <name>                Interface address (IPv4) for supplied interface name");
    print("         iptools -getactiveifname                    Name of the active interface");
    print("         iptools -getifaddresses                     Interface addresses in array");
    print("         iptools -getifnames                         Interface names in array");
    print("         iptools -getifaddresseswithnames            Interface address / name / family dictionary");
    print("         iptools -putaddresstoarray <ifaddress>      Interface address in array separated by commas for supplied interface address");
    exit(EXIT_FAILURE)
}
