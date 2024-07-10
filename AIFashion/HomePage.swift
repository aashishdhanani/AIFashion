//
//  HomePage.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI

struct HomePage: View {
    @State private var userIsLoggedIn = true
    private let openAIService: DefaultOpenAIService

    init() {
        var apiKey: String = ""

        do {
            apiKey = try Configuration.value(for: "API_KEY")
            if apiKey.isEmpty {
                fatalError("API Key is empty in environment variables")
            }
        } catch {
            fatalError("Error occurred while retrieving API Key: \(error.localizedDescription)")
        }

        self.openAIService = DefaultOpenAIService(baseURL: URL(string: "https://api.openai.com/")!, authorization: .bearer(apiKey))
    }

    var body: some View {
        TabView {
            Profile(userIsLoggedIn: $userIsLoggedIn)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            Camera()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Camera")
                }
            Suggestions(service: openAIService)
                .tabItem {
                    Image(systemName: "tshirt")
                    Text("Suggestions")
                }
        }
    }
}

#Preview {
    HomePage()
}

