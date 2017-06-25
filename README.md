# iptools

macOS command line tool to demonstrate network interface functions using Swift.

        Usage:
         iptools -getactiveifaddress                 Active Interface address (IPv4)
         iptools -getifaddress <name>                Interface address (IPv4) for supplied interface name
         iptools -getactiveifname                    Name of the active interface
         iptools -getifaddresses                     Interface addresses in array
         iptools -getifnames                         Interface names in array
         iptools -getifaddresseswithnames            Interface address / name / family dictionary
         iptools -putaddresstoarray <ifaddress>      Interface address in array separated by commas for supplied interface address
