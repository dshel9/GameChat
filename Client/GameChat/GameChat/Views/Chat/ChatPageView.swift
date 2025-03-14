//
//  ChatPageView.swift
//  GameChat
//

import SwiftUI


struct ChatPageView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @State private var showingSheet = false
    
    var body: some View {
        NavigationStack{
            List{
                Text("You are in \(viewModel.rooms.count) room\(viewModel.rooms.count == 1 ? "" : "s")")
                ForEach(viewModel.rooms, id: \.ref.documentID){room in
                    NavigationLink(value: room){
                        Text(room.name)
                    }
                    
                }
            }
            .sheet(isPresented: $showingSheet){
                CreateOrJoinRoomView()
            }
            .navigationDestination(for: Room.self) { room in
                ChatView(room: room, userRef: viewModel.userRef)
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        showingSheet = true
                    }label:{
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
