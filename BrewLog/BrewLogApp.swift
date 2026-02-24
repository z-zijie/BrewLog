//
//  BrewLogApp.swift
//  BrewLog
//
//  Created by Zijie Zhang on 2026/2/23.
//

import SwiftUI
import SwiftData

@main
struct BrewLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BrewRecord.self)
    }
}
