//
//  cameraManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/4/21.
//

import Foundation
import UIKit
import AVFoundation

class cameraManager{
    static let obj = cameraManager(); // singleton
    //private var captureSession : AVCaptureSession?;
    private let photoOutput = AVCapturePhotoOutput();
    
    private init(){ // singleton
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        
        case .authorized:
            self.setupCaptureSession();
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if (granted){
                    DispatchQueue.main.async {
                        self.setupCaptureSession();
                    }
                }
                else{
                    log.addc("The user has not granted acces to the camera");
                    self.handleDismiss();
                }
            });
        case .denied:
            log.addc("The user has previously denied access to the camera");
            self.handleDismiss();
        case .restricted:
            log.addc("The user can't give camera access due to some unknown restriction");
            self.handleDismiss();
        default:
            log.addc("There was an unknown error that occured when trying to access the camera");
            self.handleDismiss();
        }
        
    }
    
    private func setupCaptureSession(){
        let captureSession = AVCaptureSession();
        if let captureDevice = AVCaptureDevice.default(for: .video){
            
            do{
                let input = try AVCaptureDeviceInput(device: captureDevice);
                if (captureSession.canAddInput(input)){
                    captureSession.addInput(input);
                }
            } catch let error{
                log.addc("Failed to set input device with error: \(error)");
                handleDismiss();
                return;
            }
            
            if (captureSession.canAddOutput(photoOutput)){
                captureSession.addOutput(photoOutput);
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            let dataDict = ["cameraLayer" : cameraLayer];
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: dataDict);
            
            captureSession.startRunning();
            
        }
    }
    
    private func handleDismiss(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
    }
    
}
