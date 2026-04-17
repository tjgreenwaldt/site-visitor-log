//
//  ContentView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink("Sign In") {
                    SignInView()
                }

                NavigationLink("Active Visitors") {
                    ActiveVisitorsView()
                }

                NavigationLink("History") {
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Site Visitor Log")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
