//
//  ChatBarView.swift
//  GameChat
//

import SwiftUI

struct ChatBarView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack{
            TextField("Message", text: $chatViewModel.message, axis: .vertical)
                .lineLimit(5)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black)
                }
            Spacer()
            Button{
                Task{
                    await viewModel.postChat1(message: chatViewModel.message, roomRef: chatViewModel.room.ref, timeDifference: chatViewModel.timeDifference)
                    chatViewModel.message = ""
                }
            }label:{
                Image(systemName: "arrow.up.circle")
                    .disabled(chatViewModel.message.isEmpty)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
