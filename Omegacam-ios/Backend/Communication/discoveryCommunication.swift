//
//  discoveryCommunication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 3/6/21.
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

class discoveryCommunicationClass{
    static let obj = discoveryCommunicationClass(); // singleton pattern
    
    private var radio : udpsocket = udpsocket(); // Naming scheme based off RADIO DISH protocol from ZeroMQ
    
    private init(){}
    
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
    
    public func send(_ s: [Data]) -> Bool{
        
        if (!radio.isConnected){
            log.add("Radio is NOT connected with send func");
            return false;
        }
        
        for packet in s{
            radio.connectionGroup?.send(content: packet, completion: { (error) in
                if (error != nil){
                    log.addc("FAILED TO SEND DATA. Error - \(String(describing: error?.localizedDescription))");
                }
                else{
                    //log.add("Send callback is sucessfull");
                }
            });
        }
        
        return true;
    }
    
}
