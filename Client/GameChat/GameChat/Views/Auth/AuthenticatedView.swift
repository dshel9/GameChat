//
//  AuthenticatedView.swift
//  GameChat
//

import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    var body: some View {
        TabView{
            ChatPageView()
                .tabItem {
                    Image(systemName: "envelope")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .onAppear{
            Task{
                await viewModel.getRooms()
            }
        }
    }
}

#Preview {
    AuthenticatedView()
}
