//
//  SiteSelectionView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import SwiftUI
import SwiftData

struct SiteSelectionView: View {
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""
    @Query(
        filter: #Predicate<SiteEntity> { site in
            site.isActive
        },
        sort: \SiteEntity.name
    ) private var activeSites: [SiteEntity]

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

                    if activeSites.isEmpty {
                        ContentUnavailableView(
                            "No Active Sites",
                            systemImage: "building.2.crop.circle",
                            description: Text("Add or reactivate a site to continue.")
                        )
                    } else {
                        VStack(spacing: 14) {
                            ForEach(activeSites) { site in
                                Button {
                                    selectedSiteId = site.siteId
                                    selectedSiteName = site.name
                                } label: {
                                    Text(site.name)
                                }
                                .buttonStyle(
                                    selectedSiteId == site.siteId
                                    ? AnyButtonStyle(PrimaryButtonStyle())
                                    : AnyButtonStyle(SecondaryButtonStyle())
                                )
                            }
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
        .navigationTitle("Sites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Manage") {
                    SiteManagementView()
                }
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
