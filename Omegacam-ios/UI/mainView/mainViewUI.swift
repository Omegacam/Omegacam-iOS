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
        if (UIDevice.current.orientation.isValidInterfaceOrientation && UIDevice.current.orientation != .portraitUpsideDown){
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
            
            /*if let videoDataOutput = dict["videoDataOutput"] as? AVCaptureVideoDataOutput{
                
                cameraVideoDataOutput = videoDataOutput;
                
            }
            else{
                log.addc("Error in videoDataOutput cast in showCameraView");
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
                return;
            }*/
            
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
        /*//mainView.backgroundColor = UIColor.gray;
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
        
        mainView.addSubview(ipLabel);*/
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan));
        mainView.addGestureRecognizer(panGesture);
        mainView.isUserInteractionEnabled = true;
        
        renderSideMenu();
        
    }
    
    func renderSideMenu(){
        let sideMenuWidth = mainView.frame.width / (UIDevice.current.orientation.isLandscape ? 3 : 1.5);
        let sideMenuFrame = CGRect(x: mainView.frame.width, y: 0, width: sideMenuWidth, height: mainView.frame.height);
        sideMenuView = UIView(frame: sideMenuFrame);
        sideMenuView.backgroundColor = BackgroundColor;
        
        sideMenuView.setRoundedEdge(corners: [.topLeft], radius: 10);
        
        let sideMenuScrollViewFrame = CGRect(x: 0, y: 0, width: sideMenuFrame.width, height: sideMenuFrame.height);
        let sideMenuScrollView = UIScrollView(frame: sideMenuScrollViewFrame);
        
        // content inside scrollview
        
        let verticalPadding = CGFloat(20);
        var nextY = CGFloat(verticalPadding);
        
        let titleLabelText = "Omegacam iOS";
        let titleLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 20)!;
        let titleLabelWidth = sideMenuScrollViewFrame.width;
        let titleLabelHeight = titleLabelText.getHeight(withConstrainedWidth: titleLabelWidth, font: titleLabelFont)
        let titleLabelFrame = CGRect(x: 0, y: nextY, width: titleLabelWidth, height: titleLabelHeight);
        let titleLabel = UILabel(frame: titleLabelFrame);
        titleLabel.text = titleLabelText;
        titleLabel.font = titleLabelFont;
        titleLabel.textAlignment = .center;
        titleLabel.textColor = InverseBackgroundColor;
        
        sideMenuScrollView.addSubview(titleLabel);
        nextY += titleLabelFrame.height + verticalPadding;
        
        let ipLabelText = LocalNetworkPermissionService.obj.getIPAddress();
        let ipLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 15)!;
        let ipLabelWidth = sideMenuScrollViewFrame.width;
        let ipLabelHeight = ipLabelText.getHeight(withConstrainedWidth: ipLabelWidth, font: ipLabelFont);
        let ipLabelFrame = CGRect(x: 0, y: nextY, width: ipLabelWidth, height: ipLabelHeight);
        let ipLabel = UILabel(frame: ipLabelFrame);
        ipLabel.text = ipLabelText;
        ipLabel.font = ipLabelFont;
        ipLabel.textAlignment = .center;
        ipLabel.textColor = InverseBackgroundColor;
        
        sideMenuScrollView.addSubview(ipLabel);
        nextY += ipLabelFrame.height + verticalPadding;
        
        //
        
        sideMenuScrollView.contentSize = CGSize(width: sideMenuFrame.width, height: nextY);
        
        sideMenuView.addSubview(sideMenuScrollView);
        
        mainView.addSubview(sideMenuView);
    }
    
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer){
        //print("translation - \(sender.translation(in: self.view))")
        if (sender.state == .began || sender.state == .changed){
            
            let translation = sender.translation(in: self.view);
            sideMenuView.frame = CGRect(x: min(max(sideMenuView.frame.minX + translation.x, mainView.frame.width - sideMenuView.frame.width), mainView.frame.width), y: 0, width: sideMenuView.frame.width, height: sideMenuView.frame.height);
            
            sender.setTranslation(.zero, in: self.view);
        }
        else if (sender.state == .ended){
            
            let thresholdPercent : CGFloat = 0.5;
            if (sideMenuView.frame.minX <= mainView.frame.width - (sideMenuView.frame.width * thresholdPercent)){ // pulled far enough, animate pull out
                UIView.animate(withDuration: 0.2, animations: {
                    self.sideMenuView.frame = CGRect(x: self.mainView.frame.width - self.sideMenuView.frame.width, y: 0, width: self.sideMenuView.frame.width, height: self.sideMenuView.frame.height);
                });
            }
            else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.sideMenuView.frame = CGRect(x: self.mainView.frame.width, y: 0, width: self.sideMenuView.frame.width, height: self.sideMenuView.frame.height);
                });
            }
            
        }
    }
    
}
