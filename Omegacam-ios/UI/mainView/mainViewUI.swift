//
//  mainViewUI.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/4/21.
//

import Foundation
import UIKit
import AVFoundation

extension mainClass{
    @objc func showErrorView(_ notification: NSNotification){
        print("error");
    }
    
    @objc func showCameraView(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary?{
            if let cameraLayer = dict["cameraLayer"] as? AVCaptureVideoPreviewLayer{
                
                //print("setting up camera")
                
                cameraLayer.frame = self.view.frame;
                cameraLayer.videoGravity = .resizeAspectFill;
                self.view.layer.addSublayer(cameraLayer);
                
            }
            else{
                log.addc("Error in cameraLayer cast in showCameraView");
                showErrorView(NSNotification());
            }
        }
        else{
            log.addc("Error in dictionary cast in showCameraView");
            showErrorView(NSNotification());
        }
    }
}
