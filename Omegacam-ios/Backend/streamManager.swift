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
    
    private let rtmpConnection = RTMPConnection();
    private var rtmpStream : RTMPStream? = nil;
    
    private init(){ // singleton
        setupAudioSession();
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
