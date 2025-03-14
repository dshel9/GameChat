//
//  ChatViewModel.swift
//  GameChat
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject{
    @Published var chats = [Chat]()
    @Published var count = 0
    @Published var timeDifference = 0.0
    @Published var calibrations = [Calibration]()
    @Published var showingShareSheet = false
    @Published var showingCalibrationSheet = false
    @Published var showingLeaveAlert = false
    @Published var message = ""
    
    var room: Room
    var userRef: DocumentReference
    
    private var listenerRegistration: ListenerRegistration?
    private var calibrationListenerRegistration: ListenerRegistration?
    private var timeDifferenceListenerRegistration: ListenerRegistration?
    
    var orderedChats:[Chat] {
        chats.sorted { left, right in
            return left.time < right.time
        }
    }
    
    init(room: Room, userRef: DocumentReference){
        self.room = room
        self.userRef = userRef
    }
    
    public func unsubscribe(){
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
        if calibrationListenerRegistration != nil {
            calibrationListenerRegistration?.remove()
            calibrationListenerRegistration = nil
        }
        if timeDifferenceListenerRegistration != nil {
            timeDifferenceListenerRegistration?.remove()
            timeDifferenceListenerRegistration = nil
        }
        calibrations = []
        chats = []
    }
    
    func subscribe1(){
        if listenerRegistration == nil {
            listenerRegistration = db.collection("Chats").whereField("room", isEqualTo: room.ref).addSnapshotListener{[weak self] (querySnapshot, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("No query snapshot")
                    return
                }
                
                querySnapshot.documentChanges.forEach { change in
                    if change.type == .added{
                        do{
                            let chat = try change.document.data(as: Chat.self)
                            let difference = chat.time + (self?.timeDifference ?? 0.0) - Date.now.timeIntervalSince1970
                            
                            if(difference < 0){
                                self?.chats.append(chat)
                                self?.count += 1
                             }else{
                                 DispatchQueue.main.asyncAfter(deadline: .now() + difference){
                                     self?.chats.append(chat)
                                     self?.count += 1
                                 }
                             }
                        }catch{
                            print("Couldn't convert chat \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        if timeDifferenceListenerRegistration == nil {
            listenerRegistration = db.collection("User_rooms")
                .whereField("room", isEqualTo: room.ref)
                .whereField("user", isEqualTo: userRef)
                .addSnapshotListener{ [weak self] (querySnapshot, error) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        print("No query snapshot")
                        return
                    }
                    
                    querySnapshot.documentChanges.forEach { change in
                        if change.type == .modified {
                            do{
                                let temp = try change.document.data(as: TimeDifference.self)
                                self?.timeDifference = temp.timeDifference
                            }catch{
                                print(error.localizedDescription)
                            }
                        } else if change.type == .added {
                            do{
                                let temp = try change.document.data(as: TimeDifference.self)
                                self?.timeDifference = temp.timeDifference
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
        }
        
        if calibrationListenerRegistration == nil {
            calibrationListenerRegistration = db.collection("calibrations")
                .whereField("room", isEqualTo: room.ref)
                .addSnapshotListener{ [weak self] (querySnapshot, error) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        print("No query snapshot")
                        return
                    }
                    
                    querySnapshot.documentChanges.forEach { change in
                        if change.type == .added {
                            do{
                                let temp = try change.document.data(as: Calibration.self)
                                self?.calibrations.append(temp)
                                self?.count += 1
                            }catch{
                                print(error.localizedDescription)
                            }
                        }else if change.type == .removed {
                            do{
                                let temp = try change.document.data(as: Calibration.self)
                                self?.calibrations.removeAll(where: { cal in
                                    cal.event == temp.event
                                })
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
        }
    }
    
    func removeCalibration(calibration: Calibration){
        self.calibrations.removeAll { element in
            element.event == calibration.event
        }
    }
}
