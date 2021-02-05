//
//  mainView.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 11/23/20.
//

import UIKit

class mainClass: UIViewController {

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
        
        if (communication.connect(connectionstr: "tcp://*:1234")){
            print(LocalNetworkPermissionService.obj.getIPAddress());
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorView), name:NSNotification.Name(rawValue: mainView_showErrorView), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.showCameraView), name:NSNotification.Name(rawValue: mainView_showCameraView), object: nil);
            camera.self;
        }
        else{
            log.addc("Failed to establish communication connection");
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
        }
    }

    
}

