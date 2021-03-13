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
        // update preview layer
        if (UIDevice.current.orientation.isValidInterfaceOrientation && UIDevice.current.orientation != .portraitUpsideDown){
            cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!;
            cameraPreviewLayer?.frame = self.view.frame;
        }
    }
    
    @objc func setupCameraPreviewLayer(_ notification: NSNotification){
        
        if let dict = notification.userInfo as NSDictionary?{
            if let cameraLayer = dict["cameraLayer"] as? AVCaptureVideoPreviewLayer{
                
                cameraLayer.frame = self.view.frame;
                cameraLayer.videoGravity = .resizeAspectFill;
                
                if (UIDevice.current.orientation.isValidInterfaceOrientation && UIDevice.current.orientation != .portraitUpsideDown){
                    cameraLayer.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!;
                }
                
                self.view.layer.insertSublayer(cameraLayer, at: 0);
                
                self.cameraPreviewLayer = cameraLayer;
                
            }
            else{
                log.addc("Error in cameraLayer cast in showCameraView");
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
                return;
            }

        }
        else{
            log.addc("Error in dictionary cast in showCameraView");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
            return;
        }

        datamgr.shouldRun = true;
    }
    
    @objc func showErrorView(_ notification: NSNotification){
        log.addc("error view shown");
    }
    
    internal func renderUI(){
        
        let boxFrame = CGRect(x: (AppUtility.getCurrentScreenSize().width / 2) - 50, y: (AppUtility.getCurrentScreenSize().height / 2) - 50, width: 100, height: 100);
        let box = UIView(frame: boxFrame);
        box.backgroundColor = .white;
        
        self.view.addSubview(box);
        
    }
    
}
