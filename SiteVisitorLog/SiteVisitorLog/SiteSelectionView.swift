//
//  SiteSelectionView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import SwiftUI

struct SiteSelectionView: View {
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)

                    Image("origis_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .frame(maxWidth: .infinity)

                    Text("Select Site")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.secondaryNavy)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Text("Choose the site you want to work in for this session.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryNavy.opacity(0.75))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 14) {
                        ForEach(SiteSource.sites) { site in
                            Button {
                                selectedSiteId = site.id
                                selectedSiteName = site.name
                            } label: {
                                Text(site.name)
                            }
                            .buttonStyle(
                                selectedSiteId == site.id
                                ? AnyButtonStyle(PrimaryButtonStyle())
                                : AnyButtonStyle(SecondaryButtonStyle())
                            )
                        }
                    }

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let makeBodyClosure: (Configuration) -> AnyView

    init<Style: ButtonStyle>(_ style: Style) {
        makeBodyClosure = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        makeBodyClosure(configuration)
    }
}

#Preview {
    NavigationStack {
        SiteSelectionView()
    }
}
