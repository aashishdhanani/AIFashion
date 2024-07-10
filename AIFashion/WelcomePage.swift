//
//  WelcomePage.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import Firebase

struct WelcomePage: View {
    @State private var showWelcomePopup = true
    @State private var showContent = false  // New state variable
    
    var body: some View {
        ZStack {
            // Background
            Color.white.edgesIgnoringSafeArea(.all)
            
            // Content (only shown after "Get Started" is clicked)
            if showContent {
                VStack {
                    HomePage()
                }
            }
            
            // Welcome popup
            if showWelcomePopup {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        WelcomePopupView(isPresented: $showWelcomePopup, onGetStarted: {
                            showContent = true  // Show content when "Get Started" is clicked
                        })
                    )
            }
        }
    }
}

struct WelcomePopupView: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var isPresented: Bool
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack {
            Text("Welcome to FashionAI!")
                .font(.title).foregroundColor(.black)
                .padding()
                //.background(Color.red.opacity(0.3)) // Add background color for debugging
            
            Text("Use AI to upgrade your fashion sense! Click below to begin!")
                .padding()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                //.background(Color.green.opacity(0.3)) // Add background color for debugging
            
            Button("Get Started") {
                onGetStarted()  // Call the closure when "Get Started" is tapped
                isPresented = false
            }
            .padding()
            .background(Color.blue.opacity(0.5))
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    WelcomePage()
}
