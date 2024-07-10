//
//  PhotoManager.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

class PhotoManager: ObservableObject {
    @Published var photos: [UIImage] = []
    @Published var photoPaths: [String] = []

    let localFolderPath = "/Users/aashish/Desktop/pictures"

    init() {
        retrievePhotos()
    }

    func uploadPhoto(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference()
        let uuid = UUID().uuidString
        let path = "images/\(uuid).jpg"
        let fileRef = storageRef.child(path)
        
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if error == nil, metadata != nil {
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url": path]) { error in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.photos.append(image)
                            self.photoPaths.append(path)
                            print("Photo uploaded. Path: \(path)")

                            // Save the image locally
                            let localPath = "\(self.localFolderPath)/\(uuid).jpg"
                            self.saveImageLocally(imageData: imageData, to: localPath)
                        }
                    }
                }
            }
        }
    }

    func saveImageLocally(imageData: Data, to path: String) {
        do {
            let url = URL(fileURLWithPath: path)
            try imageData.write(to: url)
            print("Image saved locally at: \(path)")
        } catch {
            print("Error saving image locally: \(error)")
        }
    }

    func retrievePhotos() {
        let db = Firestore.firestore()
        db.collection("images").getDocuments { snapshot, error in
            if let snapshot = snapshot, error == nil {
                var paths = [String]()
                for doc in snapshot.documents {
                    if let url = doc["url"] as? String {
                        paths.append(url)
                    }
                }
                self.photoPaths = paths
                print("Retrieved photo paths: \(self.photoPaths)")
                for path in paths {
                    let storageRef = Storage.storage().reference().child(path)
                    storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let data = data, error == nil {
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.photos.append(image)
                                    print("Photo retrieved and added. Path: \(path)")
                                }
                            }
                        }
                    }
                }
            } else {
                print("Error retrieving photos: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func deletePhoto(at index: Int) {
        guard index < photoPaths.count && index < photos.count else {
            print("Index out of range. Photos count: \(photos.count), PhotoPaths count: \(photoPaths.count), Index: \(index)")
            return
        }

        let path = photoPaths[index]
        print("Deleting photo at path: \(path)")

        let storageRef = Storage.storage().reference().child(path)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting from storage: \(error.localizedDescription)")
                return
            }
            print("Deleted from storage")

            let db = Firestore.firestore()
            db.collection("images").whereField("url", isEqualTo: path).getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else {
                    print("No snapshot returned")
                    return
                }
                for doc in snapshot.documents {
                    db.collection("images").document(doc.documentID).delete { error in
                        if let error = error {
                            print("Error deleting document: \(error.localizedDescription)")
                            return
                        }
                        print("Deleted document from Firestore")
                        DispatchQueue.main.async {
                            if index < self.photos.count && index < self.photoPaths.count {
                                let localUUID = path.components(separatedBy: "/").last ?? ""
                                let localPath = "\(self.localFolderPath)/\(localUUID)"
                                self.deleteImageLocally(at: localPath)
                                self.photos.remove(at: index)
                                self.photoPaths.remove(at: index)
                                print("Removed photo from local arrays")
                            } else {
                                print("Index out of range after async operation. Photos count: \(self.photos.count), PhotoPaths count: \(self.photoPaths.count), Index: \(index)")
                            }
                        }
                    }
                }
            }
        }
    }

    func deleteImageLocally(at path: String) {
        do {
            let url = URL(fileURLWithPath: path)
            try FileManager.default.removeItem(at: url)
            print("Image deleted locally at: \(path)")
        } catch {
            print("Error deleting image locally: \(error)")
        }
    }
}
