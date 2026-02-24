//
//  Gotcha.swift
//  Gotcha
//
//  MVVM - App entry point
//

import SwiftUI
import UIKit

@main
struct Receipt_FinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Root View
struct RootView: View {
    var body: some View {
        NavigationStack {
            ResultView()
        }
    }
}
