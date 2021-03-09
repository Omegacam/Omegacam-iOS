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
    }
    
    internal struct discoveryDataPacket : Codable{
        var deviceName : String = "";
        var cameraConnectionIP : String = "";
        var cameraConnectionPort : UInt32 = 0;
    }
    
    //
    
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
    
    internal func encodeStruct(_ s: discoveryDataPacket) -> Data{
        var data : Data = Data();
        do{
            data = try JSONEncoder().encode(s);
        }
        catch{
            log.addc("Failed to encode struct into JSON");
        }
        return data;
    }
    
    //
    
    internal func gatherCameraData() -> cameraDataPacket{
        var packet = cameraDataPacket();
        packet.deviceName = UIDevice.current.name;
        packet.localIp = LocalNetworkPermissionService.obj.getIPAddress();
        
        let resolution = getCameraResolution();
        packet.v_width = resolution.0;
        packet.v_height = resolution.1;
        
        let frameData = getCameraFrameData();
        packet.frameData = frameData;
        packet.frameDataSize = frameData.count;
        
        //print("frame data - \(frameData.count)")
        
        return packet;
    }
    
    
    internal func gatherDiscoveryData() -> discoveryDataPacket{
        var packet = discoveryDataPacket();
        
        packet.deviceName = UIDevice.current.name;
        packet.cameraConnectionIP = LocalNetworkPermissionService.obj.getIPAddress();
        packet.cameraConnectionPort = UInt32(cameraConnectionPort);
    
        return packet;
    }
    
    //
    
    // gatherCameraData Helper functions
    private func getCameraResolution() -> (Int, Int){ // (w, h)

        let rawString = camera.getSessionPreset()?.rawValue ?? "null";
        if (!rawString.last!.isNumber){
            return (-1, -1); // last char is not an int, so prob not the correct string
        }
        
        let numberMatches = cameraResolutionMatching(for: "[0-9]+", in: rawString);
        if (numberMatches.count != 2){
            return (-2, -2); // did not find 2 numbers in string
        }
        
        // (w, h)
        let w : Int = Int(numberMatches.first!) ?? -3; // cannot convert string to int
        let h : Int = Int(numberMatches.last!) ?? -3;
        return (w, h);
    }
    
    private func cameraResolutionMatching(for regex: String, in text: String) -> [String] { // https://stackoverflow.com/a/27880748/
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text));
            return results.map {
                String(text[Range($0.range, in: text)!]);
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)");
            return [];
        }
    }
    
    private func getCameraFrameData() -> Data{
        
        guard let image = imageBuffer else{
            return Data();
        }
        
        /*guard let ciImageData = ciContext.jpegRepresentation(of: imageBuffer!, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, options: [:]) else{
            log.addc("Failed to convert CIImage to jpeg representation");
            return Data();
        }*/
    
        let uiImage = convertCIImage(ciimage: image);
        
        guard let uiImageData = uiImage.jpegData(compressionQuality: 0.0) else{
            log.addc("Failed to convert UIImage to JPEG with compression");
            return Data();
        }
        
        imageBuffer = nil;
        
        return uiImageData;
        //return Data();
    }
    
    private func convertCIImage(ciimage: CIImage) -> UIImage{
        return UIImage(cgImage: ciContext.createCGImage(ciimage, from: ciimage.extent)!);
    }
    
}
