//
//  communication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import Network
import SwiftyZeroMQ5
import MessagePacker

class communicationClass{
    
    static let obj = communicationClass(); // singleton pattern
    
    private var connectionString = "";
    private var topic = "";
    private var context : SwiftyZeroMQ.Context?;
    private var pub :  SwiftyZeroMQ.Socket?;
    
    private init(){ // singleton pattern
        LocalNetworkPermissionService.obj.triggerDialog();
        
        do{
            context = try SwiftyZeroMQ.Context();
        }
        catch{
            log.addc("Communication Error: Context Creation - \(error)");
        }
        
    }
    
    internal func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version;
        log.add("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)");
        log.add("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
    }
    
    public func connect(connectionstr: String) -> Bool {
        
        connectionString = connectionstr;
        
        do{
            pub = try context?.socket(.publish);
            
            try pub?.bind(connectionString);
            //try pub?.setRecvTimeout(Int32(recvReconnect)); // in ms
            //try pub?.setRecvBufferSize(Int32(recvBuffer));
        }
        catch{
            log.addc("CONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            return false;
        }
        return true;
        
    }
    
    public func disconnect() -> Bool {
        
        do{
            try pub?.close();
            pub = nil;
        }
        catch{
            log.add("DISCONNECT COMMUNICATION error - \(error)");
            pub = nil;
            return false;
        }
        
        return true;
    }
    
    public func newconnection(connectionstr: String, connectionTopic: String) -> Bool {
        
        if (!disconnect()){
            log.add("Failed to disconnect but not severe error");
        }
        
        if (!connect(connectionstr: connectionstr)){
            return false;
        }
        
        topic = connectionTopic;
        
        return true;
        
    }
    
    public func updateTopic(connectionTopic: String){
        topic = connectionTopic;
    }
    
    // MARK: SwiftyZeroMQ helper Functions
    public static func checkValidProtocol(communicationProtocol: String) -> Bool{
        switch communicationProtocol {
        case "ipc":
            return SwiftyZeroMQ.has(.ipc);
        case "pgm":
            return SwiftyZeroMQ.has(.pgm);
        case "tipc":
            return SwiftyZeroMQ.has(.tipc);
        case "norm":
            return SwiftyZeroMQ.has(.norm);
        case "curve":
            return SwiftyZeroMQ.has(.curve);
        case "gssapi":
            return SwiftyZeroMQ.has(.gssapi);
        default:
            print("not valid protocol for checking")
            return false;
        }
    }
    
    public static func convertErrno(errorn: Int32) -> String{
        switch errorn {
        case EAGAIN:
            return "EAGAIN - Non-blocking mode was requested and no messages are available at the moment.";
        case ENOTSUP:
            return "ENOTSUP - The zmq_recv() operation is not supported by this socket type.";
        case EFSM:
            return "EFSM - The zmq_recv() operation cannot be performed on this socket at the moment due to the socket not being in the appropriate state.";
        case ETERM:
            return "ETERM - The ØMQ context associated with the specified socket was terminated.";
        case ENOTSOCK:
            return "ENOTSOCK - The provided socket was invalid.";
        case EINTR:
            return "EINTR - The operation was interrupted by delivery of a signal before a message was available.";
        case EFAULT:
            return "EFAULT - The message passed to the function was invalid.";
        default:
            return "Not valid errno code";
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
