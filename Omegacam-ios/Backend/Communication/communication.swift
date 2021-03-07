//
//  communication.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import Network
import SwiftyZeroMQ5

class communicationClass{
    
    static let obj = communicationClass(); // singleton pattern
    
    private var connectionString = "";
    private var context : SwiftyZeroMQ.Context?;
    public var pub :  SwiftyZeroMQ.Socket?;
    
    private init(){ // singleton pattern
        
        do{
            context = try SwiftyZeroMQ.Context();
        }
        catch{
            log.addc("Communication Error: Context Creation - \(error)");
        }
        printVersion();
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
    
    public func newconnection(connectionstr: String) -> Bool {
        
        if (!disconnect()){
            log.add("Failed to disconnect but not severe error");
        }
        
        if (!connect(connectionstr: connectionstr)){
            return false;
        }
        
        return true;
        
    }
    
    public func send(_ s: Data) -> Bool{
        do{
            try pub?.send(data: s);
        }
        catch{
            log.add("Failed to send data");
            return false;
        }
        return true;
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
