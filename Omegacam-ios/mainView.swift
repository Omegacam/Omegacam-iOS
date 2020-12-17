//
//  mainView.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 11/23/20.
//

import UIKit

class mainClass: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerSize = AppUtility.getCurrentScreenSize();
        let mainViewFrame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height);
        let mainView = UIView(frame: mainViewFrame);
        
        mainView.backgroundColor = UIColor.green;
        
        
        
        self.view.addSubview(mainView);
    }


}

