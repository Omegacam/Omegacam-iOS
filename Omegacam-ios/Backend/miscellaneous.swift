//
//  miscellaneous.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 12/16/20.
//

import Foundation
import UIKit

// SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black

// shared colors from assets

let AccentColor = UIColor(named: "AccentColor")!;
let BackgroundColor = UIColor(named: "BackgroundColor")!;
let BackgroundGray = UIColor(named: "BackgroundGray")!;
let InverseBackgroundColor = UIColor(named: "InverseBackgroundColor")!;

// singleton macros

let communication = communicationClass.obj;
let discoveryCommunication = discoveryCommunicationClass.obj;
let camera = cameraManager.obj;
let datamgr = dataManager.obj;

// NSNotification macros

let mainView_showErrorView = "mainView_showErrorView";
let mainView_showCameraView = "mainView_showCameraView";

let dataManager_imageBuffer = "dataManager_imageBuffer";


