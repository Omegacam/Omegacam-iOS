//
//  communication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import Network
//import MessagePacker

struct NWStruct{
    var connection: NWConnection?;
    var connectionaddress: NWEndpoint.Host = "";
    var connectionport: NWEndpoint.Port = 0;
    var isReady: Bool = false;
}

class communicationClass{

    static let obj = communicationClass(); // singleton pattern
    
    private var radio = NWStruct(); // based off ZeroMQ's RADIO/DISH naming scheme - used for sending data
    private var dish = NWStruct(); // based off ZeroMQ's RADIO/DISH naming scheme - used for receiving data
    
    private init(){ // singleton pattern
        LocalNetworkPermissionService.obj.triggerDialog();
    }
    
    public func connect(address: String, port: UInt32){
        radio.connectionaddress = NWEndpoint.Host(address);
        radio.connectionport = NWEndpoint.Port(String(port))!;
        
        radio.connection = NWConnection(host: radio.connectionaddress, port: radio.connectionport, using: .udp);
        
        radio.connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                print("State: Ready");
                self.radio.isReady = true;
            case .setup:
                print("State: Setup");
                self.radio.isReady = false;
            case .cancelled:
                print("State: Cancelled");
                self.radio.isReady = false;
            case .preparing:
                print("State: Preparing");
                self.radio.isReady = false;
            default:
                print("Unknown state in socket");
            }
        }
        
        radio.connection?.start(queue: .global());
    }
    
    public func send(_ content: Data, completion: @escaping (Bool, NWError?) -> Void){ // can only be called by radio
        if (radio.isReady){
            radio.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                completion(NWError == nil, NWError);
            })));
        }
        else{
            completion(false, nil);
        }
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
    

}
