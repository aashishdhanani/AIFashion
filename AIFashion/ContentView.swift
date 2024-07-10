//
//  ContentView.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var showSignUpView = false
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                // Handle the error
                print(error.localizedDescription)
                // Show an alert to the user
            }
        }
    }
    
    var body: some View {
        if userIsLoggedIn {
            WelcomePage()
        } else {
            content
        }
    }

    var content: some View {
        ZStack {
            Color.black

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)

            VStack(spacing: 20) {
                Text("FashionAI")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: -90, y: -100)

                if showSignUpView {
                    signUpView
                } else {
                    loginView
                }

                Toggle("Don't have an account? Click to Register!", isOn: $showSignUpView.animation())
                    .foregroundColor(.white)
                    .padding(.top)
                    .offset(y: 110)
            }
            .frame(width: 350)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn.toggle()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    var signUpView: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .placeholder(when: email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.white)
                        .bold()
                }

            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.white)

            SecureField("Password", text: $password)
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .placeholder(when: password.isEmpty) {
                    Text("Password")
                        .foregroundColor(.white)
                        .bold()
                }

            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.white)

            Button {
                register()
            } label: {
                Text("Sign up")
                    .bold()
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.purple, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
            }
        }
    }

    var loginView: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .placeholder(when: email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.white)
                        .bold()
                }

            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.white)

            SecureField("Password", text: $password)
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .placeholder(when: password.isEmpty) {
                    Text("Password")
                        .foregroundColor(.white)
                        .bold()
                }

            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.white)

            Button {
                login()
            } label: {
                Text("Login")
                    .bold()
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.purple, .red], startPoint: .top, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.white)
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }


}

#Preview {
    ContentView()
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
