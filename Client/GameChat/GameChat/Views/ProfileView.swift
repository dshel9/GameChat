//
//  ProfileView.swift
//  GameChat
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @State private var showingAlert = false
    
    var body: some View {
        VStack{
            Text("User: \(viewModel.displayName.displayUsername)")
                .font(.largeTitle)
                .padding()
            Button{
                showingAlert = true
            }label: {
                Text("Sign out")
                    .specialButton(color: .red)
            }
            .padding()
        }
        .alert("Are you sure you want to sign out?", isPresented: $showingAlert){
            Button("Cancel", role: .cancel) {}
            Button("Sign out", role: .destructive) {
                viewModel.signOut()
            }
        }
    }
}

#Preview {
    ProfileView()
}
