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
    
    public var shouldRun = false; // if camera view gets presented and is sucessfull, start telemetry
    
    internal var imageBuffer : CIImage? = nil;
    internal let ciContext = CIContext();
    
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
            while true{
                var i = 0;
                while self.shouldRun{
                    
                    //let data = try! MessagePackEncoder().encode(cameraDataPacket(s: "Test"));
                    
                    do{
                        try autoreleasepool{ // warning shows that no throws could be called but the do catch is necessary due to the fact that we need autoreleasepool in order to not leak memory with JSONEncoder
                            if (!communication.send(self.encodeStruct(self.gatherData()))){
                                log.addc("Failed to send data");
                            }
                            else{
                                print("Sucess - \(i)");
                                i+=1;
                            }
                        }
                    }
                    catch{} // catch statement is required for do
                    
                    //usleep(800); // 60 fps
                    usleep(1600); // 30 fps
                }
                sleep(3);
            }
        }
    }
    
}

