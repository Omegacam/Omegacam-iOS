//
//  streamManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 2/4/21.
//

import Foundation
import UIKit
import AVFoundation
import HaishinKit

class streamManager{

    static let obj = streamManager(); // singleton
    
    /*private let rtmpConnection = RTMPConnection();
    private var rtmpStream : RTMPStream? = nil;*/
    
    private var httpStream : HTTPStream? = nil;
    private var httpService : HLSService? = nil;
    
    private var isStreamSetup : Bool = false;
    
    private init(){ // singleton
        setupAudioSession();
        setupStream();
    }
    
    public func getIsStreamSetup() -> Bool{
        return isStreamSetup;
    }
    
    public func attachStreamToView(_ view: HKView) -> HKView{
        if (isStreamSetup){
            view.attachStream(httpStream!);
        }
        else{
            log.add("Can't attach stream to view because stream hasn't been setup yet.");
        }
        return view;
    }
    
    private func startStream(){
        //rtmpConnection.connect("rtmp://localhost/Omegacam");
        //rtmpStream?.publish("streamName");
        
        httpService = HLSService(domain: "", type: "_http._tcp", name: "HaishinKit", port: 8080);
        httpService?.startRunning();
        httpService?.addHTTPStream(httpStream!);
        
    }
    
    private func setupStream(){
        /*rtmpStream = RTMPStream(connection: rtmpConnection);
        rtmpStream?.attachAudio(AVCaptureDevice.default(for: .audio)){ (error) in
            log.addc("Failed to attach audio");
        }
        
        rtmpStream?.attachCamera(DeviceUtil.device(withPosition: .back)){ (error) in
            log.addc("Failed to attach video device");
        }*/
        httpStream = HTTPStream();
        
        httpStream?.attachCamera(DeviceUtil.device(withPosition: .back)){ (error) in
            log.addc("Failed to attach video device");
        }
        /*httpStream?.attachAudio(AVCaptureDevice.default(for: .audio)){ (error) in
            log.addc("Failed to attach audio device");
        }*/
        
        startStream();
        
        httpStream?.publish("hello");
        
        isStreamSetup = true;
    }
    
    private func setupAudioSession(){
    
        let session = AVAudioSession.sharedInstance();
        do {
            // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
            if #available(iOS 10.0, *) {
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth]);
            } else {
                
                session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
                    AVAudioSession.CategoryOptions.allowBluetooth,
                    AVAudioSession.CategoryOptions.defaultToSpeaker]
                );
                
                try session.setMode(.default);
            }
            try session.setActive(true);
        } catch {
            log.addc("Encountered error while setting up audio session - \(error)");
        }
        
    }
    
    
    
    
}
