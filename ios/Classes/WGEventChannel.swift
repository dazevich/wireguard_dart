//
//  WGEventChannel.swift
//  wireguard_dart
//
//  Created by Daniil on 05.07.2023.
//

import Foundation
import Flutter

class WGEventChannel : NSObject, FlutterStreamHandler {
    static var sink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        Self.sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        Self.sink = nil
        return nil
    }
    
    static func sendState(state: String) {
        guard let sink = Self.sink else {return}
        
        sink(state)
    }
    
}
