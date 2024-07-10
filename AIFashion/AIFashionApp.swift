//
//  AIFashionApp.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import Firebase

@main
struct fashionAIApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var photoManger = PhotoManager()
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            if appState.userIsLoggedIn {
                WelcomePage()
                    .environmentObject(appState)
                    .environmentObject(photoManger)
            } else {
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(photoManger)
            }
        }
    }
}
