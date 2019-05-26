//
//  PushModel.swift
//  App
//
//  Created by Patrick Gatewood on 5/26/19.
//

struct PushModel : Codable {
    var alert: String
    var sound: String
    
    init(alert: String, sound: String = "default") {
        self.alert = alert
        self.sound = sound
    }
}
