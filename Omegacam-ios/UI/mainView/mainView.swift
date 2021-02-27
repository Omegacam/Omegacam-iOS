//
//  mainView.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 11/23/20.
//

import UIKit
import AVFoundation
import HaishinKit

class mainClass: UIViewController {
    
    //internal var cameraVideoDataOutput : AVCaptureVideoDataOutput? = nil;
    internal var mainView : UIView = UIView();
    internal var sideMenuView : UIView = UIView();
    internal var isShowingLogs = false;
    
    internal var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        log.add("Device model - \(UIDevice.current.model)");
        log.add("Device name - \(UIDevice.current.name)");
        log.add("OS - \(UIDevice.current.systemName) with version # \(UIDevice.current.systemVersion)");
        
        mainView = UIView(frame: CGRect(x: 0, y: AppUtility.topSafeAreaInsetHeight, width: AppUtility.getCurrentScreenSize().width, height: AppUtility.getCurrentScreenSize().height - AppUtility.topSafeAreaInsetHeight));
        self.view.addSubview(mainView);
        
        self.view.addGestureRecognizer(panGesture);
        panGesture.addTarget(self, action: #selector(self.handlePan));
        
        log.add(LocalNetworkPermissionService.obj.getIPAddress());
        if (!communication.connect(ip: "224.0.0.0", port: 28650)){
            log.addc("Failed to establish communication connection");
            showErrorView();
            return;
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotationHandler), name: UIDevice.orientationDidChangeNotification, object: nil);
        
        stream.self; // instigate init of static obj
        datamgr.self; // instigate init of static obj
        
        datamgr.shouldRun = true;
        
        showCameraUIElements();
        
        //self.view.backgroundColor = .white;
        while (!stream.getIsStreamSetup()){
            log.add("Waiting for stream to finish setting up");
        }
        
        let streamView = HKView(frame: self.view.frame);
        self.view.insertSubview(stream.attachStreamToView(streamView), at: 0);
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil);
    }
    
}

