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
    internal var cameraVideoDataOutput : AVCaptureVideoDataOutput? = nil;
    internal var mainView : UIView = UIView();
    internal var sideMenuView : UIView = UIView();
    internal var isShowingLogs = false;
    
    internal var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        mainView = UIView(frame: CGRect(x: 0, y: AppUtility.topSafeAreaInsetHeight, width: AppUtility.getCurrentScreenSize().width, height: AppUtility.getCurrentScreenSize().height - AppUtility.topSafeAreaInsetHeight));
        self.view.addSubview(mainView);
        
        self.view.addGestureRecognizer(panGesture);
        panGesture.addTarget(self, action: #selector(self.handlePan));
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        
        if (communication.connect(connectionstr: "tcp://*:1234")){
            log.add(LocalNetworkPermissionService.obj.getIPAddress());
            
            AppUtility.lockOrientation(.portrait);
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorView), name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.showCameraView), name:NSNotification.Name(rawValue: mainView_showCameraView), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotationHandler), name: UIDevice.orientationDidChangeNotification, object: nil);
            
            camera.self; // instigate init of static obj
            
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
            
        }
        else{
            log.addc("Failed to establish communication connection");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
        }
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: mainView_showCameraView), object: nil);
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil);
    }
    
}

