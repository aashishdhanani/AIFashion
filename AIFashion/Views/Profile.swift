//
//  Profile.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var userIsLoggedIn: Bool
    @EnvironmentObject var photoManager: PhotoManager
   // @State private var isAirplaneOn = false
    //@State private var wifiSelection = "Home_wifi"
    //let wifiNames = ["Home_wifi", "rand_name"]
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Image(systemName: "person.crop.circle").resizable()
                        .frame(width:50, height: 50).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    VStack (alignment: .leading){
                        Text(appState.userEmail).font(.system(size:20))
                    }
                }
                
            //Section
                Section {
                    //pictures
                    NavigationLink(destination: Pictures()) {
                        IconView(iconColor: .purple, iconName: "camera")
                        HStack {
                            Text("Pictures")
                            Spacer()
                        }

                    }
                    //logout
                    
                    HStack {
                        IconView(iconColor: .mint, iconName: "lock")
                        Button("Logout") {
                            appState.signOut()
                        }
                    }
                }
            
            }.navigationTitle("Profile")
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
            RoundedRectangle(cornerRadius: 4).fill(iconColor)
                .frame(width: 25, height: 25)
            Image(systemName: iconName).foregroundColor(.white)
        }
    }
}

