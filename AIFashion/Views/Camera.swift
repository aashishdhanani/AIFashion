//
//  Camera.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct Camera: View {
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image: UIImage?
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 300)
                
                Button("choose picture") {
                    self.showSheet = true
                }.padding()
                    .actionSheet(isPresented: $showSheet, content: {
                        ActionSheet(title: Text("Select Photo"),
                                    message: Text("Choose"), buttons: [
                                        .default(Text("Photo Library")) {
                                            self.showImagePicker = true
                                            self.sourceType = .photoLibrary
                                        },
                                        .default(Text("Camera")) {
                                            self.showImagePicker = true
                                            self.sourceType = .camera
                                        },
                                        .cancel()
                                    ])
                    }
                    )
               //upload button
                if image != nil {
                    Button {
                        if let image = image {
                            photoManager.uploadPhoto(image)
                            self.image = nil
                        }
                    } label: {
                        Text("upload photo")
                    }
                }
                
                Divider()
                
            }
            .navigationTitle("Camera")
            
        }.sheet(isPresented: $showImagePicker, content: {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        })
    }
}

#Preview {
    Camera().environmentObject(PhotoManager())
}
