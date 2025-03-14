//
//  IndividualChatView.swift
//  GameChat
//

import SwiftUI

struct IndividualChatView: View {
    var chat: Chat
    var displayName: String
    var body: some View {
        VStack{
            if chat.from != displayName {
                HStack{
                    Text(chat.from.displayUsername)
                        .font(.subheadline)
                        .foregroundStyle(Color.init(white: 0.25))
                        .padding(.leading)
                    Spacer()
                }
            }
            
            HStack{
                if chat.from == displayName {
                    Spacer()
                }
                Text(chat.message)
                    .foregroundStyle(chat.from == displayName ? .white : .black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(chat.from == displayName ? .blue : Color.init(white: 0.95))
                    )
                if chat.from != displayName {
                    Spacer()
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
        
    }
}
