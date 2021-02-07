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

    @objc internal func clicked(_ sender: UIButton){
        if (communication.send("test".data(using: .utf8)!)){
            print("success send");
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        /*let containerSize = AppUtility.getCurrentScreenSize();
        let mainViewFrame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height);
        let mainView = UIView(frame: mainViewFrame);
        
        mainView.backgroundColor = BackgroundColor;
        
        let buttonWidth = CGFloat(UIScreen.main.bounds.width / 3);
        let buttonFrame = CGRect(x: (UIScreen.main.bounds.width / 2) - (buttonWidth / 2), y: UIScreen.main.bounds.height / 2, width: buttonWidth, height: buttonWidth * 0.4);
        let button = UIButton(frame: buttonFrame);
        button.setTitle("Click me", for: .normal);
        button.setTitleColor(BackgroundColor, for: .normal);
        button.titleLabel?.textAlignment = .center;
        button.backgroundColor = InverseBackgroundColor;
        
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside);
        
        mainView.addSubview(button);
        
        self.view.addSubview(mainView);*/
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        
        if (communication.connect(connectionstr: "tcp://*:1234")){
            print(LocalNetworkPermissionService.obj.getIPAddress());
            
            AppUtility.lockOrientation(.portrait);
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorView), name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.showCameraView), name:NSNotification.Name(rawValue: mainView_showCameraView), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotationHandler), name: UIDevice.orientationDidChangeNotification, object: nil);
            
            camera.self; // instigate init of static obj
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

