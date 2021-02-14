//
//  dataManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/13/21.
//

import Foundation
import AVFoundation
import UIKit

struct cameraDataPacket : Codable{
    var s : String;
}

class dataManager{
    static let obj = dataManager(); // singleton
    
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
            while true{
                
                //let data = try! MessagePackEncoder().encode(cameraDataPacket(s: "Test"));
                do{
                    let data = try JSONEncoder().encode(cameraDataPacket(s: "Test \(i)"));
                    if (!communication.send(data)){
                        log.addc("Failed to send data - \(data)");
                    }
                    else{
                        print("Sucess - \(i)");
                        i+=1;
                    }
                    
                }
                catch{
                    log.addc("Failed to encode cameraDataPacket to json");
                }
                //usleep(800); // 60 fps
                usleep(1600); // 30 fps
            }
        }
    }
    
}

/*DispatchQueue.global(qos: .background).async {
    var i = 0;
    while true{
        if (communication.send("test \(i)".data(using: .utf8)!)){
            print("sent \(i)")
            i += 1;
        }
        //usleep(800); 60 fps
        usleep(1600); // 30 fps
    }
}*/
