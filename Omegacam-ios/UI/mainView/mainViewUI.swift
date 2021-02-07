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
    
    @objc func deviceRotationHandler(){
        if (UIDevice.current.orientation != .portraitUpsideDown && UIDevice.current.orientation != .faceDown && UIDevice.current.orientation != .faceUp && UIDevice.current.orientation != .unknown){
            cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!;
        }
        cameraPreviewLayer?.frame = self.view.frame;
    }
    
    @objc func showErrorView(_ notification: NSNotification){
        print("error");
    }
    
    @objc func showCameraView(_ notification: NSNotification){
        
        for views in self.view.subviews{
            views.removeFromSuperview();
        }
        
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() });
        
        if let dict = notification.userInfo as NSDictionary?{
            if let cameraLayer = dict["cameraLayer"] as? AVCaptureVideoPreviewLayer{
                
                //print("setting up camera")
                
                cameraLayer.frame = self.view.frame;
                cameraLayer.videoGravity = .resizeAspectFill;
                cameraLayer.connection?.videoOrientation = .portrait;
                self.view.layer.addSublayer(cameraLayer);
                
                self.cameraPreviewLayer = cameraLayer;
                
            }
            else{
                log.addc("Error in cameraLayer cast in showCameraView");
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
            }
            
        }
        else{
            log.addc("Error in dictionary cast in showCameraView");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
        }
        
        AppUtility.lockOrientation(.all);
        
    }
    
    
    
    
}
