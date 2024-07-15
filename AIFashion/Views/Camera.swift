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
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 300)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .transition(.slide) // Animation
                    } else {
                        Image("new_placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 300)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .transition(.slide) // Animation
                    }
                    
                    Button(action: {
                        self.showSheet = true
                    }) {
                        Text("Choose Picture")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
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
                    })
                    
                    if image != nil {
                        Button(action: {
                            if let image = image {
                                photoManager.uploadPhoto(image)
                                self.image = nil
                            }
                        }) {
                            Text("Upload Photo")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding()
                        .transition(.opacity) // Animation
                    }
                    
                    Divider()
                    
                }
                .navigationTitle("Camera")
            }
        }.sheet(isPresented: $showImagePicker, content: {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        })
    }
}

#Preview {
    Camera().environmentObject(PhotoManager())
}
