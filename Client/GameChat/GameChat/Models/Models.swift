//
//  Models.swift
//  GameChat
//

import Foundation
import FirebaseFirestore

struct Chat: Codable{
    var message: String
    var from: String
    var time: Double
    var room: DocumentReference
}

struct Calibration:Codable{
    var event:String
}

struct Room: Hashable{
    var name:String
    var ref: DocumentReference
}

struct TimeDifference:Codable{
    var timeDifference: Double
}
