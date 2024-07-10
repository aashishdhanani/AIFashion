//
//  AppStateManager.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import Firebase

class AppStateManager: ObservableObject {
    @Published var userIsLoggedIn: Bool = false
    @Published var userEmail: String = ""
    
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Running in preview mode, set mock data
            self.userIsLoggedIn = true
            self.userEmail = "preview@example.com"
        } else {
            // Running in the actual app, setup Firebase
            setupFirebaseAuthListener()
        }
        #else
        setupFirebaseAuthListener()
        #endif
    }
    
    func setupFirebaseAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.userIsLoggedIn = user != nil
            self?.userEmail = user?.email ?? ""
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            userIsLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
