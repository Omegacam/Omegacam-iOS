//
//  mainView.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 11/23/20.
//

import UIKit
import AVFoundation

class mainClass: UIViewController {
    
    internal var cameraPreviewLayer : AVCaptureVideoPreviewLayer? = nil;
    //internal var cameraVideoDataOutput : AVCaptureVideoDataOutput? = nil;
    internal var isShowingLogs = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        log.add("Device model - \(UIDevice.current.model)");
        log.add("Device name - \(UIDevice.current.name)");
        log.add("OS - \(UIDevice.current.systemName) with version # \(UIDevice.current.systemVersion)");
        
        UIApplication.shared.isIdleTimerDisabled = true;
        
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        
        if (!communication.connect(connectionstr: "tcp://*:\(cameraConnectionPort)")){
            log.addc("Failed to establish communication connection");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
            return;
        }
        
        log.add(LocalNetworkPermissionService.obj.getIPAddress());
        
        //AppUtility.lockOrientation(.portrait);
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorView), name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupCameraPreviewLayer), name:NSNotification.Name(rawValue: mainView_setupCameraPreviewLayer), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotationHandler), name: UIDevice.orientationDidChangeNotification, object: nil);
        
        camera.self; // instigate init of static obj
        datamgr.self; // instigate init of static obj
        
        renderUI();
        
        AppUtility.lockOrientation(.all, andRotateTo: .portrait);
        
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: mainView_setupCameraPreviewLayer), object: nil);
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil);
    }
    
}

