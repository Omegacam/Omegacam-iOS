//
//  multipartPacketProtocol.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/23/21.
//
import Foundation

class multipartPacketManager{
    
    static let obj = multipartPacketManager(); // singleton
    
    private init(){}
    deinit {}
    
    //
    
    private let maxPacketSize : UInt = 4000; //
    
    private var packetGroupNumber : UInt = 0; // max is 1024
    private let maxPacketGroupNumber : UInt = 1024;
    
    public func encodeToMultipart(_ raw_data: Data) -> [Data]{
        var output : [Data] = [];
        
        if (raw_data.count <= maxPacketSize){
            output = [formatData(packet_group_id: packetGroupNumber, packet_group_size: 1, packet_group_num: 0, raw: raw_data)];
        }
        else{
            let raw_data_array : [UInt8] = convertDataToAUInt8(raw_data);
            var temp_buffer : [UInt8] = [];
            var temp_output : [Data] = []; // unformatted data array
            
            for byte in raw_data_array{
                
                temp_buffer.append(byte);
                
                let temp_buffer_data = convertAUInt8ToData(temp_buffer);
                if (temp_buffer_data.count >= maxPacketSize){
                    temp_output.append(temp_buffer_data);
                    temp_buffer.removeAll();
                }
                
            }
            
            let temp_buffer_data = convertAUInt8ToData(temp_buffer);
            if (temp_buffer_data.count > 0){
                temp_output.append(temp_buffer_data);
                temp_buffer.removeAll();
            }
            
            var i : UInt = 0;
            for p in temp_output{
                output.append(formatData(packet_group_id: packetGroupNumber, packet_group_size: UInt(temp_output.count), packet_group_num: i, raw: p));
                i += 1;
            }
            
        }
        
        packetGroupNumber = (packetGroupNumber + 1 ) % maxPacketGroupNumber;
        //print("output size - \(output.count)");
        return output;
    }

    //
    internal func convertDataToAUInt8(_ d: Data) -> [UInt8]{
        var t : [UInt8] = [];
        t.append(contentsOf: d);
        return t;
    }
    
    internal func convertAUInt8ToData(_ a: [UInt8]) -> Data{
        return Data(a);
    }
    //
    
    internal func formatData(packet_group_id: UInt, packet_group_size: UInt, packet_group_num: UInt, raw: Data) -> Data{
        if (raw.count > maxPacketSize){
            log.addc("Data passed to formatData is bigger than \(maxPacketSize)");
            return Data();
        }
        
        let encoded_string = "\(packet_group_id)~\(packet_group_size)~\(packet_group_num)~\(String(decoding: raw, as: UTF8.self))";
        
        return encoded_string.data(using: .utf8)!;
    }
}
