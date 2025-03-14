//
//  AuthenticationView.swift
//  GameChat
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    var body: some View {
        switch viewModel.flow {
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        }
    }
}

#Preview {
    AuthenticationView()
}
