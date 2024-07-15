import SwiftUI

struct Profile: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var userIsLoggedIn: Bool
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(appState.userEmail)
                                .font(.system(size: 20))
                        }
                    }
                    
                    // Section
                    Section {
                        // Pictures
                        NavigationLink(destination: Pictures()) {
                            HStack {
                                IconView(iconColor: .purple, iconName: "camera")
                                Text("Pictures")
                                Spacer()
                            }
                        }
                        
                        // Logout
                        HStack {
                            IconView(iconColor: .mint, iconName: "lock")
                            Button("Logout") {
                                appState.signOut()
                            }
                        }
                    }
                }
                .background(Color.clear) // Ensure the form background is clear
                .scrollContentBackground(.hidden) // Hide default form background for iOS 16 and later
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    Profile(userIsLoggedIn: .constant(true))
        .environmentObject(AppStateManager())
        .environmentObject(PhotoManager())
}

struct IconView: View {
    
    let iconColor: Color
    let iconName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(iconColor)
                .frame(width: 25, height: 25)
            Image(systemName: iconName)
                .foregroundColor(.white)
        }
    }
}
