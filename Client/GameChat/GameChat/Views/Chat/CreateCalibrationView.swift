//
//  CreateCalibrationView.swift
//  GameChat
//
 
import SwiftUI

struct CreateCalibrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel:AuthenticationViewModel
    @State private var event = ""
    @State private var showingAlert = false
    let room: String
    
    var body: some View {
        VStack{
            Text("Create new calibration event")
                .font(.title)
            TextField("Event", text: $event)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black)
                }
            HStack{
                Button{
                    dismiss()
                }label:{
                    Text("Cancel")
                        .specialButton(color: Color.red.opacity(0.9))
                }
                
                Spacer()
                
                Button{
                    Task{
                        let result = await viewModel.createCalibration(room: room, event: event)
                        if result{
                            dismiss()
                        }else{
                            showingAlert = true
                        }
                    }
                    
                }label:{
                    Text("Create")
                        .specialButton(color: .green)
                }
                .disabled(event.isEmpty)
            }
            .padding(.vertical)
        }
        .padding()
        .alert("There was a problem creating the calibration event", isPresented: $showingAlert){
            Button("Ok") {}
        } message: {
            Text("Make sure there isn't already an event with the same name")
        }
    }
}

#Preview {
    CreateCalibrationView(room: "TestDocID")
}
 
