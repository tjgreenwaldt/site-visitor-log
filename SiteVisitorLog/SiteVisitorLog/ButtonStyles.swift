//
//  ButtonStyles.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primaryOrange)
                    .opacity(configuration.isPressed ? 0.88 : 1)
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .foregroundStyle(Color.secondaryNavy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.secondaryNavy.opacity(configuration.isPressed ? 0.12 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.secondaryNavy.opacity(configuration.isPressed ? 0.75 : 1), lineWidth: 1)
            )
    }
}
