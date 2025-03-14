//
//  CreateOrJoinRoomView.swift
//  GameChat
//

import SwiftUI

struct CreateOrJoinRoomView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var localViewModel = CreateOrJoinRoomViewModel()
    var body: some View {
        Form{
            Section{
                TextField("Room name", text: $localViewModel.roomName)
                CreateRoomButton
            } header: {
                Text("Create Room")
            }
            Section{
                TextField("Room ID", text: $localViewModel.roomId)
                JoinRoomButton
            } header: {
                Text("Join Room")
            }
        }
        .alert("There was an error with your attempted action", isPresented: $localViewModel.showingAlert){
            Button("OK") {}
        } message: {
            Text("Make sure you aren't already in a room with the same name and try again")
        }
    }
    
    private var CreateRoomButton: some View {
        Button{
            Task{
                let result = await viewModel.createRoom(roomName: localViewModel.roomName)
                if result {
                    dismiss()
                }else{
                    localViewModel.showingAlert = true
                }
            }
        }label: {
            HStack{
                Spacer()
                Text("Create")
                Spacer()
            }
            .disabled(localViewModel.roomName.isEmpty)
        }
    }
    
    private var JoinRoomButton: some View {
        Button{
            Task{
                let result = await viewModel.joinRoom(roomString: localViewModel.roomId)
                if result {
                    dismiss()
                }else{
                    localViewModel.showingAlert = true
                }
            }
        }label: {
            HStack{
                Spacer()
                Text("Join")
                Spacer()
            }
            .disabled(localViewModel.roomId.isEmpty)
        }
    }
}

#Preview {
    CreateOrJoinRoomView()
}
