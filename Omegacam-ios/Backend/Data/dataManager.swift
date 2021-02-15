//
//  dataManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/13/21.
//

import Foundation
import AVFoundation
import UIKit


class dataManager{
    static let obj = dataManager(); // singleton
    
    public var shouldRun = true; // if error view gets presented, stop telemetry
    
    private var imageBuffer : CIImage? = nil;
    
    private init(){
        delegateThread();
        NotificationCenter.default.addObserver(self, selector: #selector(self.addImageBuffer), name: NSNotification.Name(rawValue: dataManager_imageBuffer), object: nil);
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: dataManager_imageBuffer), object: nil);
    }
    
    @objc private func addImageBuffer(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary?{
            if let image = dict["image"] as? CIImage{
                imageBuffer = image;
                //print("got image")
            }
            else{
                log.add("Error in image cast in addImageBuffer");
            }
        }
        else{
            log.addc("Error in userInfo dict cast in addImageBuffer");
        }
    }
    
    private func delegateThread(){
        DispatchQueue.global(qos: .background).async {
            var i = 0;
            while self.shouldRun{
                
                //let data = try! MessagePackEncoder().encode(cameraDataPacket(s: "Test"));
                
                if (!communication.send(self.encodeStruct(self.gatherData()))){
                    log.addc("Failed to send data");
                }
                else{
                    print("Sucess - \(i)");
                    i+=1;
                }
                
                //usleep(800); // 60 fps
                usleep(1600); // 30 fps
            }
        }
    }
    
}

