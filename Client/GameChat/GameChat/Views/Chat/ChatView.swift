//
//  ChatView.swift
//  GameChat
//

import SwiftUI
import FirebaseFirestore

struct ChatView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @StateObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            ScrollView{
                ScrollViewReader{ scrollViewProxy in
                    ForEach(chatViewModel.orderedChats, id: \.time){ chat in
                        IndividualChatView(chat: chat, displayName: viewModel.displayName)
                    }
                    
                    ForEach(chatViewModel.calibrations, id: \.event) { cal in
                        CalibrationView(chatViewModel: chatViewModel, calibration: cal)
                    }
                    
                    HStack{Spacer()}
                        .id("Bottom")
                        .onReceive(chatViewModel.$count) { _ in
                            scrollViewProxy.scrollTo("Bottom", anchor: .bottom)
                        }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ChatBarView(chatViewModel: chatViewModel)
            }
        }
        .navigationTitle(chatViewModel.room.name)
        .alert("Are you sure you want to leave the room", isPresented: $chatViewModel.showingLeaveAlert){
            Button("Cancel", role: .cancel) {}
            LeaveConfirmation
        }
        .sheet(isPresented: $chatViewModel.showingCalibrationSheet){
            CreateCalibrationView(room: chatViewModel.room.ref.documentID)
        }
        .shareSheet(isPresented: $chatViewModel.showingShareSheet, items: [chatViewModel.room.ref.documentID])
        .onAppear(perform: chatViewModel.subscribe1)
        .onDisappear(perform: chatViewModel.unsubscribe)
        .toolbar{
            ToolbarItemGroup(placement: .topBarTrailing){
                ShareSheetButton
                LeaveRoomButton
                CalibrateSheetButton
            }
        }
    }

    init(room: Room, userRef: DocumentReference?) {
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(room: room, userRef: userRef!))
    }
    
    private var ShareSheetButton: some View{
        Button{
            chatViewModel.showingShareSheet = true
        }label:{
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private var LeaveRoomButton: some View {
        Button{
            chatViewModel.showingLeaveAlert = true
        }label:{
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundStyle(.red)
        }
    }
    
    private var CalibrateSheetButton: some View {
        Button{
            chatViewModel.showingCalibrationSheet = true
        }label:{
            Image(systemName: "clock")
        }
    }
    
    private var LeaveConfirmation: some View {
        Button("Leave", role: .destructive) {
            Task{
                let result = await viewModel.leaveRoom(room: chatViewModel.room)
                if(result){
                    dismiss()
                     viewModel.rooms.removeAll { temp in
                         temp.ref == chatViewModel.room.ref
                     }
                }
            }
        }
    }
}
