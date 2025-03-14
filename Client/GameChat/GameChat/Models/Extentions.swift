//
//  ExtentionsAndSmallStructs.swift
//  GameChat
//

import Foundation
import SwiftUI

extension Date{
    var displayFormat: String {
        self.formatted(
            .dateTime
                .month()
                .day()
                .hour()
                .minute()
                .second()
        )
    }
}

struct SpecialButton: ViewModifier {
    var backroundColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(backroundColor)
                    .clipped()
            )
    }
}

extension View {
    func specialButton( color : Color) -> some View {
        modifier(SpecialButton(backroundColor: color))
    }
}

extension String{
    var displayUsername: String{
        guard self.count >= 10 else { return self}
        var end = self.endIndex
        for _ in 1...10{
            end = self.index(before: end)
        }
        return String(self[...end])
    }
}

struct BoxBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .overlay {
                Rectangle()
                    .stroke(.black)
            }
    }
}

extension View {
    func boxborder() -> some View {
        modifier(BoxBorder())
    }
}
