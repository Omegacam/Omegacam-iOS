//
//  cameraManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/4/21.
//

import Foundation
import UIKit
import AVFoundation

// https://medium.com/flawless-app-stories/capture-photo-using-avcapturesession-in-swift-842bb95751f0

class cameraManager{

    static let obj = cameraManager(); // singleton
    //private var captureSession : AVCaptureSession?;
    
    private init(){ // singleton
        setup();
    }
    
    public func setup(){
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
                    self.handleDismiss("The user has not granted acces to the camera");
                }
            });
        case .denied:
            self.handleDismiss("The user has previously denied access to the camera");
        case .restricted:
            self.handleDismiss("The user can't give camera access due to some unknown restriction");
        default:
            self.handleDismiss("There was an unknown error that occured when trying to access the camera");
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
                handleDismiss("Failed to set input device with error: \(error)");
                return;
            }
        
            
            let videoDataOutput = AVCaptureVideoDataOutput();
            if (captureSession.canAddOutput(videoDataOutput)){
                captureSession.addOutput(videoDataOutput);
            }
            else{
                handleDismiss("Unable to create data stream from camera");
                return;
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            cameraLayer.connection?.videoOrientation = .portrait;
            var dataDict : [String : Any] = [:];
            dataDict["cameraLayer"] = cameraLayer;
            dataDict["videoDataOutput"] = videoDataOutput;
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showCameraView), object: nil, userInfo: dataDict);
            
            captureSession.startRunning();
            
        }
        else{
            handleDismiss("Unable to find capture device");
        }
    }
    
    private func handleDismiss(_ s: String){
        log.addc(s);
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: mainView_showErrorView), object: nil, userInfo: nil);
    }
    
    public func captureImageData() -> Data{
        return Data();
    }
    
}
