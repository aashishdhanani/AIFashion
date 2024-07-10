//
//  Pictures.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI

struct Pictures: View {
    @EnvironmentObject var photoManager: PhotoManager

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(photoManager.photos.indices, id: \.self) { index in
                        VStack {
                            Image(uiImage: photoManager.photos[index])
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                            Button(action: {
                                photoManager.deletePhoto(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pictures")
        }
    }
}

#Preview {
    Pictures().environmentObject(PhotoManager())
}
