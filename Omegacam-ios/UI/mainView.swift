//
//  mainView.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 11/23/20.
//

import UIKit

class mainClass: UIViewController {

    @objc internal func clicked(_ sender: UIButton){
        communication.send("Test".data(using: .utf8)!, completion: { (isSuccessful, err) in
            if (isSuccessful){
                print("successful send");
            }
            else{
                print("failed send - \( err == nil ? "sent called before ready" : err?.localizedDescription )");
            }
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let containerSize = AppUtility.getCurrentScreenSize();
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
        
        self.view.addSubview(mainView);

        communication.connect(address: "220.100.100.1", port: 7000);
        
    }


}
