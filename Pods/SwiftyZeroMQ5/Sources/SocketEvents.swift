//
// Copyright (c) 2016-2017 Ahmad M. Zawawi (azawawi)
//
// This package is distributed under the terms of the MIT license.
// Please see the accompanying LICENSE file for the full text of the license.
//

extension SwiftyZeroMQ {
    
    /**
     An set of socket events that map out to a 32-bit integer
     */
    public struct SocketEvents : OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
                
        public static let connected           = SocketEvents(rawValue: ZMQ_EVENT_CONNECTED)
        public static let connectDelayed      = SocketEvents(rawValue: ZMQ_EVENT_CONNECT_DELAYED)
        public static let connectRetried      = SocketEvents(rawValue: ZMQ_EVENT_CONNECT_RETRIED)
        public static let listening           = SocketEvents(rawValue: ZMQ_EVENT_LISTENING)
        public static let bindFailed          = SocketEvents(rawValue: ZMQ_EVENT_BIND_FAILED)
        public static let accepted            = SocketEvents(rawValue: ZMQ_EVENT_ACCEPTED)
        public static let acceptFailed        = SocketEvents(rawValue: ZMQ_EVENT_ACCEPT_FAILED)
        public static let closed              = SocketEvents(rawValue: ZMQ_EVENT_CLOSED)
        public static let closeFailed         = SocketEvents(rawValue: ZMQ_EVENT_CLOSE_FAILED)
        public static let disconnected        = SocketEvents(rawValue: ZMQ_EVENT_DISCONNECTED)
        public static let monitorStopped      = SocketEvents(rawValue: ZMQ_EVENT_MONITOR_STOPPED)
        public static let all                 = SocketEvents(rawValue: ZMQ_EVENT_ALL)
    }
    
}
