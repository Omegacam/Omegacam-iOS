//
//  errorManager.swift
//  Omegacam-ios
//
//  Created by Richard Wei on 1/30/21.
//

import Foundation

class log{
    static private var logBuffer : [String] = [String]();
    static public func add(_ s: String){
        print(s);
        logBuffer.append(s);
    }
    static public func addc(_ s: String){ // critical
        print(s);
        logBuffer.append(s);
    }
    static public func getBuffer() -> [String]{
        return logBuffer;
    }
}
