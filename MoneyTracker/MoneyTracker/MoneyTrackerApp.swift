//
//  MoneyTrackerApp.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/3/21.
//

import SwiftUI

@main
struct MoneyTrackerApp: App {
//    @StateObject private var dataController = DataController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DataController.shared.container.viewContext)
        }
    }
}
