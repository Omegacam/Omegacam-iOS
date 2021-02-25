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
    
    public var shouldRun = true; // setting this to false stops the telemetry
    
    private init(){
        delegateThread();
    }
    
    private func delegateThread(){
        DispatchQueue.global(qos: .background).async {
            while true{
                while self.shouldRun{

                    
                    do{
                        
                        try autoreleasepool{ // warning shows that no throws could be called but the do catch is necessary due to the fact that we need autoreleasepool in order to not leak memory with JSONEncoder
                            
                            /*if (!communication.send(self.encodeStruct(self.gatherData()))){
                                log.addc("Failed to send data");
                            }
                            else{
                                print("Sucess - \(self.frameCount)");
                                self.frameCount += 1;
                            }*/
                            
                        }
                        
                    }
                    catch{} // catch statement is required for do
                    
                    //usleep(800); // 60 fps
                    //usleep(1600); // 30 fps
                    sleep(1);
                }
                sleep(3);
            }
        }
    }
    
}

