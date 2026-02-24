//
//  ContentView.swift
//  BrewLog
//
//  Created by Zijie Zhang on 2026/2/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            RecordListView()
                .tabItem {
                    Label("记录", systemImage: "list.bullet.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(.coffee)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
