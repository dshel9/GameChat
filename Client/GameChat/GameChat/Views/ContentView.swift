//
//  ContentView.swift
//  GameChat
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated:
            AuthenticationView()
                
        case .authenticated:
            AuthenticatedView()
        }
    }
}
