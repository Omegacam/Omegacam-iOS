//
//  udpsocket.swift
//
//  Created by Richard Wei on 3/7/21.
//

import Foundation
import Network

// https://developer.apple.com/news/?id=0oi77447

class udpsocket{
    private var connectionIP : NWEndpoint.Host = "";
    private var connectionPort : NWEndpoint.Port = 0;
    
    private var multicastGroup : NWMulticastGroup? = nil;
    private var connectionGroup : NWConnectionGroup? = nil;
    private var isConnected : Bool = false;
    
    public func connect(ip: String, port: UInt) -> Bool {
        
        if (isConnected){
            log.addc("Already connected, use newconnection function");
            return false;
        }
        
        connectionIP = NWEndpoint.Host(ip);
        connectionPort = NWEndpoint.Port(String(port))!;
        
        do{
            multicastGroup = try NWMulticastGroup(for: [.hostPort(host: connectionIP, port: connectionPort)]);
            connectionGroup = NWConnectionGroup(with: multicastGroup!, using: .udp);
            
           connectionGroup?.stateUpdateHandler = { (newState) in
                
                log.add("udp socket connection group entered state \(String(describing: newState))");
                if (newState == .ready){
                    self.isConnected = true;
                    log.add("udp socket connection is ready");
                }
                
            }
            
            connectionGroup?.setReceiveHandler(handler: { (_, _, _) in });
            
            connectionGroup?.start(queue: .global(qos: .background));
            
        }
        catch{
            log.addc("Error connecting to \(ip) with port \(port) and protocol udp - \(error)");
            resetSocket();
            return false;
        }
        
        //radio.isConnected = true;
        return true;
        
    }
    
    public func disconnect() -> Bool {
        
        if (!isConnected){
            return false;
        }
        
        connectionGroup?.cancel();
        isConnected = false;
        
        resetSocket();
        
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
        
        if (!isConnected){
            log.add("Radio is NOT connected with send func");
            return false;
        }
        
        
        connectionGroup?.send(content: s, completion: { (error) in
            if (error != nil){
                log.addc("FAILED TO SEND DATA. Error - \(String(describing: error?.localizedDescription))");
            }
            else{
                //log.add("Send callback is sucessfull");
            }
        });
        
        
        return true;
    }

    private func resetSocket(){
        connectionIP = "";
        connectionPort = 0;
        
        multicastGroup = nil;
        connectionGroup = nil;
        
        isConnected = false;
    }
}
