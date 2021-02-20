//
//  communication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import Network

// https://developer.apple.com/news/?id=0oi77447

struct udpsocket{
    var connectionIP : NWEndpoint.Host = "";
    var connectionPort : NWEndpoint.Port = 0;
    
    var multicastGroup : NWMulticastGroup? = nil;
    var connectionGroup : NWConnectionGroup? = nil;
    var isConnected : Bool = false;
}

class communicationClass{
    
    static let obj = communicationClass(); // singleton pattern
    
    private var radio : udpsocket = udpsocket(); // Naming scheme based off RADIO DISH protocol from ZeroMQ
    
    private init(){ // singleton pattern
        LocalNetworkPermissionService.obj.triggerDialog();
    }
    
    
    public func connect(ip: String, port: UInt) -> Bool {
        
        if (radio.isConnected){
            log.addc("Already connected, use newconnection function");
            return false;
        }
        
        radio.connectionIP = NWEndpoint.Host(ip);
        radio.connectionPort = NWEndpoint.Port(String(port))!;
            
        do{
            radio.multicastGroup = try NWMulticastGroup(for: [.hostPort(host: radio.connectionIP, port: radio.connectionPort)]);
            radio.connectionGroup = NWConnectionGroup(with: radio.multicastGroup!, using: .udp);
            
            radio.connectionGroup?.stateUpdateHandler = { (newState) in
                
                log.add("connection group entered state \(String(describing: newState))");
                if (newState == .ready){
                    self.radio.isConnected = true;
                    log.add("connection is ready");
                }
                
            }
            
            radio.connectionGroup?.setReceiveHandler(handler: { (_, _, _) in });

            radio.connectionGroup?.start(queue: .global(qos: .background));
            
        }
        catch{
            log.addc("Error connecting to \(ip) with port \(port) and protocol udp - \(error)");
            radio = udpsocket(); // reset socket
            return false;
        }
        
        //radio.isConnected = true;
        return true;
        
    }
    
    public func disconnect() -> Bool {
        
        if (!radio.isConnected){
            return false;
        }
        
        radio.connectionGroup?.cancel();
        radio.isConnected = false;
        
        radio = udpsocket(); // reset socket
        
        return true;
    }
    
    public func newconnection(ip: String, port: UInt) -> Bool {
        
        if (!disconnect()){
            log.add("Failed to disconnect but continuing");
        }
        
        if (!connect(ip: ip, port: port)){
            return false;
        }
        
        return true;
        
    }
    
    public func send(_ s: Data) -> Bool{
        
        if (!radio.isConnected){
            log.add("Radio is NOT connected with send func");
            return false;
        }
        
        radio.connectionGroup?.send(content: s, completion: { (error) in
            if (error != nil){
                log.addc("FAILED TO SEND DATA. Error - \(String(describing: error?.localizedDescription))");
            }
            else{
                log.add("Send callback is sucessfull");
            }
        });
        
        return true;
    }

    
}

// IOS 14 doesn't allow the app the recieve UDP multicast but there isn't an official API to initate the prompt for these permissions. The class below grants permssion to the app by sending phony packets locally which is stupid but there isn't any other option. Apple's support has said themself that you should send out packets as a temporary workaround.
//https://stackoverflow.com/questions/63940427/ios-14-how-to-trigger-local-network-dialog-and-check-user-answer/64242745#64242745
//https://github.com/ChoadPet/DTS-request
//https://stackoverflow.com/q/63940427/6057764
class LocalNetworkPermissionService {
    
    static var obj = LocalNetworkPermissionService();
    private let port: UInt16
    private var interfaces: [String] = []
    private var connections: [NWConnection] = []
    
    init() {
        self.port = 12345
        self.interfaces = ipv4AddressesOfEthernetLikeInterfaces()
    }
    
    deinit {
        connections.forEach { $0.cancel() }
    }
    
    // This method try to connect to iPhone self IP Address
    func triggerDialog() {
        for interface in interfaces {
            let host = NWEndpoint.Host(interface)
            let port = NWEndpoint.Port(integerLiteral: self.port)
            let connection = NWConnection(host: host, port: port, using: .udp)
            connection.stateUpdateHandler = { [weak self, weak connection] state in
                self?.stateUpdateHandler(state, connection: connection)
            }
            connection.start(queue: .main)
            connections.append(connection)
        }
    }
    
    // MARK: Private API
    
    private func stateUpdateHandler(_ state: NWConnection.State, connection: NWConnection?) {
        switch state {
        case .waiting:
            let content = "nice".data(using: .utf8)
            connection?.send(content: content, completion: .idempotent)
        default:
            break
        }
    }
    
    private func namesOfEthernetLikeInterfaces() -> [String] {
        var addrList: UnsafeMutablePointer<ifaddrs>? = nil
        let err = getifaddrs(&addrList)
        guard err == 0, let start = addrList else { return [] }
        defer { freeifaddrs(start) }
        return sequence(first: start, next: { $0.pointee.ifa_next })
            .compactMap { i -> String? in
                guard
                    let sa = i.pointee.ifa_addr,
                    sa.pointee.sa_family == AF_LINK,
                    let data = i.pointee.ifa_data?.assumingMemoryBound(to: if_data.self),
                    data.pointee.ifi_type == IFT_ETHER
                else {
                    return nil
                }
                return String(cString: i.pointee.ifa_name)
            }
    }
    
    private func ipv4AddressesOfEthernetLikeInterfaces() -> [String] {
        let interfaces = Set(namesOfEthernetLikeInterfaces())
        
        //print("Interfaces: \(interfaces)")
        var addrList: UnsafeMutablePointer<ifaddrs>? = nil
        let err = getifaddrs(&addrList)
        guard err == 0, let start = addrList else { return [] }
        defer { freeifaddrs(start) }
        return sequence(first: start, next: { $0.pointee.ifa_next })
            .compactMap { i -> String? in
                guard
                    let sa = i.pointee.ifa_addr,
                    sa.pointee.sa_family == AF_INET
                else {
                    return nil
                }
                let name = String(cString: i.pointee.ifa_name)
                guard interfaces.contains(name) else { return nil }
                var addr = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let err = getnameinfo(sa, socklen_t(sa.pointee.sa_len), &addr, socklen_t(addr.count), nil, 0, NI_NUMERICHOST | NI_NUMERICSERV)
                guard err == 0 else { return nil }
                let address = String(cString: addr)
                //print("Address: \(address)")
                return address
            }
    }
    
    public func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
    
}
