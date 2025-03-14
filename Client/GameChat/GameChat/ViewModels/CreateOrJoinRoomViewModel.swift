//
//  CreateOrJoinRoomViewModel.swift
//  GameChat
//

import Foundation

class CreateOrJoinRoomViewModel: ObservableObject{
    @Published var showingAlert = false
    @Published var roomName = ""
    @Published var roomId = ""
}
