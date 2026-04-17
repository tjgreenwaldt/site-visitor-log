//
//  ContentView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""

    var body: some View {
        NavigationStack {
            if selectedSiteId.isEmpty {
                SiteSelectionView()
            } else {
                ZStack {
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Spacer()

                        Image("origis_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .frame(maxWidth: .infinity)

                        Text("Site Visitor Log")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondaryNavy)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        VStack(spacing: 10) {
                            Text("Current Site")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)

                            Text(selectedSiteName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.secondaryNavy)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)

                        VStack(spacing: 10) {
                            NavigationLink {
                                SignInView()
                            } label: {
                                Text("Sign In")
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            NavigationLink {
                                ActiveVisitorsView(selectedSiteId: selectedSiteId)
                            } label: {
                                Text("Active Visitors")
                            }
                            .buttonStyle(SecondaryButtonStyle())

                            NavigationLink {
                                HistoryView(selectedSiteId: selectedSiteId)
                            } label: {
                                Text("History")
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        Button("Change Site") {
                            selectedSiteId = ""
                            selectedSiteName = ""
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.secondaryNavy)
                        .opacity(0.8)

                        Spacer()
                    }
                    .frame(maxWidth: 420)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
