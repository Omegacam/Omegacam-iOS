//
//  packetManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/14/21.
//

import Foundation
import UIKit

extension dataManager{
    internal struct cameraDataPacket : Codable{
        var deviceName : String = "";
        var localIp : String = "";
        
        var v_width : Int = -1;
        var v_height : Int = -1;
        
        var frameData : Data = Data();
        var frameDataSize : Int = -1;
        
        var frameNumber : UInt64 = 0;
    }
    
    internal func encodeStruct(_ s: cameraDataPacket) -> Data{
        var data : Data = Data();
        do{
            data = try JSONEncoder().encode(s);
        }
        catch{
            log.addc("Failed to encode struct into JSON");
        }
        return data;
    }
    
    internal func gatherData() -> cameraDataPacket{
        var packet = cameraDataPacket();
        /*packet.deviceName = UIDevice.current.name;
        packet.localIp = LocalNetworkPermissionService.obj.getIPAddress();
        
        let resolution = getCameraResolution();
        packet.v_width = resolution.0;
        packet.v_height = resolution.1;
        
        let frameData = getCameraFrameData();
        packet.frameData = frameData;
        packet.frameDataSize = frameData.count;
        
        packet.frameNumber = self.frameCount;
        //print("frame data - \(frameData)")*/
        
        return packet;
    }
    
}
