//
//  PushService.swift
//  App
//
//  Created by Patrick Gatewood on 5/26/19.
//
import Vapor

protocol PushService {
    static func sendPush(_ push: PushModel, to deviceToken: String)
}

final class PushHandler: (PushService) {
    
    static func ServiceDown(name: String) -> PushModel {
        return PushModel(alert: "\(name) is offline!")
    }
    
    public static func sendPush(_ push: PushModel, to deviceToken: String) {
        // Can't do this in a Swifty way until Vapor supports HTTP/2
        
        let pushJsonData = try! JSONEncoder().encode(push)
        let pushString = String(data: pushJsonData, encoding: .utf8)!
        let pushPayload = "{\"aps\":\(pushString)}" // TODO do this wrapping as part of PushModel
        
        let certPassword: String = ""
        guard !certPassword.isEmpty else {
            fatalError("You need to set the push certificate password!")
        }
        
        // TODO store certificate elsewhere
        let curlArguments: [String] = ["-v", "-d", pushPayload, "--cert", "/Users/patrickgatewood/Downloads/dashboard-push-cert.pem:\(certPassword)",  "-H", "apns-topic: com.willowtreeapps.patrick.gatewood.dashboard", "--http2",   "https://api.development.push.apple.com/3/device/\(deviceToken)"]
        
        ProcessRunner.shell("/usr/bin/curl", curlArguments)
    }
}
