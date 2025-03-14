//
//  SignUpView.swift
//  GameChat
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    
    var body: some View {
        VStack{
            Text("Sign Up")
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
            
            Button("Sign Up"){
                Task{
                    await viewModel.signUpWithEmailPassword()
                }
            }
            .disabled(viewModel.disableAuthAttemp)
            
            HStack {
                Text("Already have an account?")
                Button("Log in", action: viewModel.switchFlow)
                    .fontWeight(.semibold)
            }
            .padding(.vertical)
        }
        .padding()
        .alert("There was a problem signing up", isPresented: $viewModel.showAlert) {
            Button("Ok") { }
        }
    }
}

#Preview {
    SignUpView()
}
