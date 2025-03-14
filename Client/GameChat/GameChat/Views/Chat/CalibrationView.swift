//
//  CalibrationView.swift
//  GameChat
//

import SwiftUI

struct CalibrationView: View {
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    var calibration: Calibration
    
    var body: some View {
        VStack{
            HStack{
                Text(calibration.event)
                Spacer()
                Button{
                    Task{
                        let result = await viewModel.calibrate(room: chatViewModel.room, event: calibration.event) 
                        print(result)
                        if result {
                            chatViewModel.removeCalibration(calibration: calibration)
                        }
                        
                    }
                }label:{
                    Text("Now")
                        .specialButton(color: .blue)
                }
                
                Button{
                    chatViewModel.removeCalibration(calibration: calibration)
                }label:{
                    Text("X")
                }
            }
            .padding(.horizontal)
        }
    }
}
