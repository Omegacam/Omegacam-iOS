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
        if (UIDevice.current.orientation != .unknown && UIDevice.current.orientation != .portraitUpsideDown && UIDevice.current.orientation != .faceDown && UIDevice.current.orientation != .faceUp){
            //print("rotation handler")
            // update mainView
            mainView.removeFromSuperview();
            if (UIDevice.current.orientation.isPortrait){
                mainView = UIView(frame: CGRect(x: 0, y: AppUtility.topSafeAreaInsetHeight, width: AppUtility.getCurrentScreenSize().width, height: AppUtility.getCurrentScreenSize().height - AppUtility.topSafeAreaInsetHeight));
            }
            else{
                mainView = UIView(frame: CGRect(x: AppUtility.topSafeAreaInsetHeight, y: 0, width: AppUtility.getCurrentScreenSize().width - AppUtility.topSafeAreaInsetHeight, height: AppUtility.getCurrentScreenSize().height));
            }
            self.view.addSubview(mainView);
            
            if (!isShowingLogs){
                
                // update preview layer
                cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!;
                cameraPreviewLayer?.frame = self.view.frame;
                
                showCameraUIElements();
            }
            else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
            }
        }
    }
    
    @objc func showErrorView(_ notification: NSNotification){
        
        isShowingLogs = true;
        //log.add("Create an issue at https://github.com/Omegacam/Omegacam-iOS for help or more information. Make sure to include the above logs.");
        
        for views in mainView.subviews{
            views.removeFromSuperview();
        }
        
        // lock orientation to show errors
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        //NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil);
        
        //self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() });
        
        mainView.backgroundColor = BackgroundColor;
        
        let titleLabelHeight = CGFloat(30);
        let titleLabelFrame = CGRect(x: 0, y: 15, width: mainView.frame.width, height: titleLabelHeight);
        let titleLabel = UILabel(frame: titleLabelFrame);
        titleLabel.text = "Logs";
        titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 25);
        titleLabel.textAlignment = .center;
        
        mainView.addSubview(titleLabel);
        
        let logScrollViewFrame = CGRect(x: 0, y: titleLabelFrame.maxY, width: mainView.frame.width, height: mainView.frame.height - titleLabelFrame.maxY);
        let logScrollView = UIScrollView(frame: logScrollViewFrame);
        
        var logBuffer = log.getBuffer();
        logBuffer.append("Create an issue at https://github.com/Omegacam/Omegacam-iOS for help or more information. Make sure to include the above logs.");
        let logEntryPadding = CGFloat(20);
        let logEntryVerticalPadding = CGFloat(10);
        var nextY = CGFloat(logEntryVerticalPadding);
        for logEntryString in logBuffer{
            
            let logEntryFont = UIFont(name: "SFProDisplay-Semibold", size: 15)!;
            let logEntryWidth = logScrollViewFrame.width - 2*logEntryPadding;
            let logEntryHeight = logEntryString.getHeight(withConstrainedWidth: logEntryWidth, font: logEntryFont);
            let logEntryFrame = CGRect(x: logEntryPadding, y: nextY, width: logEntryWidth, height: logEntryHeight);
            let logEntry = UILabel(frame: logEntryFrame);
            logEntry.font = logEntryFont;
            logEntry.text = logEntryString;
            logEntry.textAlignment = .center;
            logEntry.numberOfLines = 0;
            logEntry.textColor = InverseBackgroundColor;
            
            nextY += logEntryHeight + logEntryVerticalPadding;
            
            logScrollView.addSubview(logEntry);
        }
        logScrollView.contentSize = CGSize(width: logScrollViewFrame.width, height: nextY);
        
        mainView.addSubview(logScrollView);
        //mainView.backgroundColor = UIColor.white;
    }
    
    @objc func showCameraView(_ notification: NSNotification){
        
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() });
        
        if let dict = notification.userInfo as NSDictionary?{
            if let cameraLayer = dict["cameraLayer"] as? AVCaptureVideoPreviewLayer{
                
                //print("setting up camera")
                
                cameraLayer.frame = self.view.frame;
                cameraLayer.videoGravity = .resizeAspectFill;
                cameraLayer.connection?.videoOrientation = .portrait;
                self.view.layer.insertSublayer(cameraLayer, at: 0);
                
                self.cameraPreviewLayer = cameraLayer;
                
            }
            else{
                log.addc("Error in cameraLayer cast in showCameraView");
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
                return;
            }
            
            if let videoDataOutput = dict["videoDataOutput"] as? AVCaptureVideoDataOutput{
                
                cameraVideoDataOutput = videoDataOutput;
                
            }
            else{
                log.addc("Error in videoDataOutput cast in showCameraView");
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
                return;
            }
            
        }
        else{
            log.addc("Error in dictionary cast in showCameraView");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
            return;
        }
        
        AppUtility.lockOrientation(.all);
        
        showCameraUIElements();
        
    }
    
    func showCameraUIElements(){
        for views in mainView.subviews{
            views.removeFromSuperview();
        }
        //mainView.backgroundColor = UIColor.gray;
        let ipLabelText = LocalNetworkPermissionService.obj.getIPAddress();
        let ipLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 15)!;
        let ipLabelWidth = mainView.frame.width;
        let ipLabelHeight = ipLabelText.getHeight(withConstrainedWidth: ipLabelWidth, font: ipLabelFont);
        let ipLabelFrame = CGRect(x: 0, y: mainView.frame.height - ipLabelHeight, width: ipLabelWidth, height: ipLabelHeight);
        let ipLabel = UILabel(frame: ipLabelFrame);
        ipLabel.text = ipLabelText;
        ipLabel.font = ipLabelFont;
        ipLabel.textAlignment = .center;
        ipLabel.textColor = .black;
        
        mainView.addSubview(ipLabel);
        
    }
    
    
    
    
}
