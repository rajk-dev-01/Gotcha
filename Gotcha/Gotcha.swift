//
//  Receipt_FinderApp.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 7/29/25.
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

struct RootView: View {
    @State private var fileName: String = ""
    @State private var searchText: String = ""
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        NavigationStack {
            ResultView(
                fileName: $fileName,
                searchText: searchText,
                selectedImage: $selectedImage
            )
        }
    }
}
