//
//  LoginView.swift
//  GameChat
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    
    var body: some View {
        VStack{
            Text("Login")
                .font(.largeTitle)
            
            TextField("Username", text: $viewModel.username)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .boxborder()
            
            SecureField("Password", text: $viewModel.password)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .boxborder()
                .padding(.vertical)
            
            Button("Log In"){
                Task{
                    await viewModel.signInWithEmailPassword()
                }
            }
            .disabled(viewModel.disableAuthAttemp)
            
            HStack {
                Text("Don't have an account yet?")
                Button("Sign up", action: viewModel.switchFlow)
                    .fontWeight(.semibold)
            }
            .padding(.vertical)
        }
        .padding()
        .alert("There was a problem logging in", isPresented: $viewModel.showAlert) {
            Button("Ok") { }
        }
    }
}

#Preview {
    LoginView()
}
