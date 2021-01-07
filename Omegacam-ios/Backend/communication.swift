//
//  communication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import SwiftyZeroMQ5
import Network
import MessagePacker

class communicationClass{
    var connectionString = "";
    var group = "";
    var context : SwiftyZeroMQ.Context?;
    var radio : SwiftyZeroMQ.Socket?;
    
    static let obj = communicationClass(); // singleton pattern
    private init(){ // singleton pattern
        printVersion();
        let permissionObj = LocalNetworkPermissionService();
        permissionObj.triggerDialog();
        do{
            context = try SwiftyZeroMQ.Context();
        }
        catch{
            print("COMMUNICATION ERROR : CONTEXT CREATION - \(error)");
        }
    }
    
    internal func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version;
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)");
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
    }
    
    public func send(data: String) -> Bool{
        do{
            try radio?.sendRadioMessage(group: group, data: MessagePackEncoder().encode(data));
           // try radio?.send(data: data.data(using: .utf8)!);
           // try pub?.send(string: data);
        }
        catch{
            print("SEND COMMUNICATION error - \(error)");
            return false;
        }
        return true;
    }
    
    public func connect(connectionstr: String, connectionGroup: String, sendTimeout: Int, sendBuffer: Int)->Bool{
        
        connectionString = connectionstr;
        group = connectionGroup;
        
        do{
            radio = try context?.socket(.radio);
            
            try radio?.connect(connectionString);
            
            //print(zmq_bind(pub?.handle, connectionstr));
            
            //try pub?.setSubscribe(topic);
            //try radio?.joinGroup(topic);
            /*try pub?.setRecvTimeout(Int32(sendTimeout)); // in ms
            try pub?.setRecvBufferSize(Int32(sendBuffer));*/
            
            /*try radio?.bind(connectionString);
            //try dish?.setSubscribe("telemetry");
            try dish?.joinGroup(group);
            try dish?.setRecvTimeout(Int32(recvReconnect)); // in ms
            try dish?.setRecvBufferSize(Int32(recvBuffer));*/
        }
        catch{
            print("CONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            return false;
        }
        return true;
    }
    
    public func disconnect()->Bool{
        do{
            try radio?.leaveGroup(group);
            //try radio?.disconnect(connectionString);
            try radio?.close();
            radio = nil;
            //dish = nil;
            //try context?.close();
        }
        catch{
            print("DISCONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            return false;
        }
        return true;
    }
    
    public func newconnection(connectionstr: String, connectionGroup: String, sendTimeout: Int, sendBuffer: Int)->Bool{ // when changing ports or address
        
        if (!disconnect()){
            print("Failed disconnect but not severe error");
        }
        
        if (!connect(connectionstr: connectionstr, connectionGroup: connectionGroup, sendTimeout: sendTimeout, sendBuffer: sendBuffer)){
            return false;
        }
        
        return true;
    }
}

// IOS 14 doesn't allow the app the recieve UDP multicast but there isn't an official API to initate the prompt for these permissions. The class below grants permssion to the app by sending phony packets locally which is stupid but there isn't any other option. Apple's support has said themself that you should send out packets as a temporary workaround.
//https://stackoverflow.com/questions/63940427/ios-14-how-to-trigger-local-network-dialog-and-check-user-answer/64242745#64242745
//https://github.com/ChoadPet/DTS-request
//https://stackoverflow.com/q/63940427/6057764
class LocalNetworkPermissionService {
    
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
            let content = "Hello Cruel World!".data(using: .utf8)
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
