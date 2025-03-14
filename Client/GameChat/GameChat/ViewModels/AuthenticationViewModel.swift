//
//  AuthenticationViewModel.swift
//  GameChat
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

enum AuthenticationState {
  case unauthenticated
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}


@MainActor
class AuthenticationViewModel: ObservableObject{
    init(){
        //functions.useEmulator(withHost: "localhost", port: 5001)
        registerAuthStateHandler1()
    }
    
    @Published var username = ""
    @Published var password = ""


    @Published var flow: AuthenticationFlow = .login
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var user: User?
    @Published var displayName = ""
    @Published var rooms = [Room]()
    @Published var showAlert = false
    
    var userRef: DocumentReference?
    private var authStateHandler:AuthStateDidChangeListenerHandle?
    
    var usernameToEmail:String{
        username + "@test.com"
    }
    
    var disableAuthAttemp: Bool{
        username.isEmpty || password.isEmpty
    }
    
    func switchFlow(){
        flow = flow == .login ? .signUp : .login
        username = ""
        password = ""
    }
    
    func registerAuthStateHandler1(){
        if authStateHandler == nil{
            authStateHandler = Auth.auth().addStateDidChangeListener{ auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email ?? ""
                
                guard let userID = user?.uid else { return }
                self.userRef = db.document("Users/\(userID)")
            }
        }
    }
    
    func getRooms() async {
        do{
            let result = try await functions.httpsCallable("getRooms1").call([])
            let data = result.data as! [String:Any]
            guard let arr = data["data"] as? Array<[String:Any]> else { return }
            
            for obj in arr {
                guard let name = obj["name"] as? String else { return }
                guard let ref = obj["room"] as? String else { return }
                let roomRef = db.document(ref)
                rooms.append(Room(name: name, ref: roomRef))
            }
        }catch{
            print("Error")
            print(error.localizedDescription)
        }
    }
    
    func signInWithEmailPassword() async {
        do{
            try await Auth.auth().signIn(withEmail: usernameToEmail, password: password)
            password = ""
        }catch{
            showAlert = true
            print(error.localizedDescription)
        }
    }
    
    func signUpWithEmailPassword() async {
        do{
            try await Auth.auth().createUser(withEmail: usernameToEmail, password: password)
            password = ""
        }catch{
            showAlert = true
            print(error.localizedDescription)
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            rooms.removeAll()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func postChat1(message: String, roomRef: DocumentReference, timeDifference: Double) async{
        do{
            
            let _ = try await functions.httpsCallable("postchat").call(["message": message, "from": displayName, "time": Date.now.timeIntervalSince1970 - timeDifference, "room": roomRef.documentID])
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func checkContainsRef(ref: String) -> Bool{
        let contains = rooms.contains { room in
            if(room.ref.documentID == ref){
                return true
            }else{
                return false
            }
        }
        return contains
    }
    
    func checkContainsName(name: String) -> Bool{
        let contains = rooms.contains { room in
            if(room.name == name){
                return true
            }else{
                return false
            }
        }
        
        return contains
    }
    
    func createRoom(roomName: String) async -> Bool {
        guard checkContainsName(name: roomName) == false else{
            print("Already in with same name room")
            return false
        }
        
        do{
            let result = try await functions.httpsCallable("createRoom").call(["name": roomName])
            guard let data = result.data as? [String: Any] else { return false }
            guard let success = data["result"] as? Bool else { return false }
            if success {
                guard let value = data["value"] as? String else { return false }
                let ref = db.document(value)
                rooms.append(Room(name: roomName, ref: ref))
                return true
            }
        }catch{
            print(error.localizedDescription)
            
        }
        return false
    }
    
    func joinRoom(roomString: String) async -> Bool{
        guard checkContainsRef(ref: roomString) == false else{
            print("Already in room")
            return false
        }
        
        do{
            let result = try await functions.httpsCallable("joinRoom").call(["room": roomString])
            let data = result.data as! [String: Any]
            guard let success = data["result"] as? Bool else { return false }
            
            if success {
                guard let name = data["name"] as? String else { return false }
                let ref = db.document("Rooms/\(roomString)")
                rooms.append(Room(name: name, ref: ref))
                return true
            }
        }catch{
            print(error.localizedDescription)
        }
        return false
    }
    
    func leaveRoom(room: Room) async -> Bool{
        do{
            let result = try await functions.httpsCallable("leaveRoom").call(["room": room.ref.documentID])
            guard let data = result.data as? [String: Any] else {
                print("Could't decode result")
                return false
            }
            
            guard let success = data["result"] as? Bool else{
                print("Could't decode success")
                return false
            }
            
            if success {
                return true
            }
            
        }catch{
            print(error.localizedDescription)
            return false
        }
        return false
    }
    
    func createCalibration(room: String, event: String) async -> Bool{
        do{
            let result = try await functions.httpsCallable("createCalibration").call(["room": room, "event": event])
            guard let data = result.data as? [String: Any] else {
                print("Could't decode result")
                return false
            }
            guard let success = data["result"] as? Bool else{
                print("Could't decode success")
                return false
            }
            return success
        }catch{
            print(error.localizedDescription)
            return false
        }
    }
    
    func calibrate(room: Room, event: String) async -> Bool {
        do{
            let result = try await functions.httpsCallable("calibrateUser").call(["room": room.ref.documentID, "event": event, "time": Date.now.timeIntervalSince1970])
            guard let data = result.data as? [String: Any] else {
                print("Could't decode result")
                return false
            }
            guard let success = data["success"] as? Bool else{
                print("Could't decode success")
                return false
            }
            
            if success == false {
                return false
            }
            
            guard data["offset"] is Double else{
                print("Could't decode time")
                return false
            }
            
            return true
        }catch{
            print(error.localizedDescription)
            return false
        }
    }
     
}
