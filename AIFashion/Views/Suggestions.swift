//
//  Suggestions.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import PhotosUI
import SwiftOpenAI
import FirebaseStorage

struct Suggestions: View {
    @State private var chatProvider: ChatVisionProvider
    @State private var isLoading = false
    @State private var prompt = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var selectedImageURLS: [URL] = []
    
    init(service: OpenAIService) {
       _chatProvider = State(initialValue: ChatVisionProvider(service: service))
    }
    
    var body: some View {
       ScrollViewReader { proxy in
          VStack {
             List(chatProvider.chatMessages) { message in
                ChatDisplayMessageView(message: message)
                   .listRowSeparator(.hidden)
             }
             .listStyle(.plain)
             .onChange(of: chatProvider.chatMessages.last?.content) {
                let lastMessage = chatProvider.chatMessages.last
                if let id = lastMessage?.id {
                   proxy.scrollTo(id, anchor: .bottom)
                }
             }
             .onTapGesture {
                 dismissKeyboard()
             }
             textArea
          }
          .gesture(
            TapGesture()
                .onEnded { _ in
                    dismissKeyboard()
                }
          )
       }
    }
    
    var textArea: some View {
       HStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 0) {
             textField
                .padding(6)
          }
          .padding(.vertical, 2)
          .padding(.horizontal, 2)
          .animation(.bouncy, value: selectedImages.isEmpty)
          .background(
              RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 1)
          )
          .padding(.horizontal, 8)
          textAreSendButton
       }
       .padding(.horizontal)
       .disabled(isLoading)
    }
    
    var textField: some View {
       TextField(
          "Describe your event...",
          text: $prompt,
          axis: .vertical)
    }
    
    let fashionExpertPrompt = """
    You are an expert fashion stylist with a keen eye for current trends and timeless style. Analyze the attached images of clothing items and accessories. Based on these images, create a cohesive outfit suggestion. Consider factors such as color coordination, style compatibility, appropriateness for different occasions, and current fashion trends. If any essential items are missing for a complete outfit, recommend what could be added. Keep the reponse to no more than 3-4 sentences.
    """
    
    var textAreSendButton: some View {
        Button {
            print("Send button tapped with input: \(prompt)") // Debugging statement
            Task {
                isLoading = true
                defer {
                    // ensure isLoading is set to false after the function executes.
                    isLoading = false
                }
                
                fetchImagesFromFirebase { result in
                    switch result {
                    case .success:
                        // Images fetched successfully, continue with the rest of your logic
                        let content: [ChatCompletionParameters.Message.ContentType.MessageContent] = [
                            .text(fashionExpertPrompt),
                            .text(prompt)
                        ] + selectedImageURLS.map { .imageUrl(.init(url: $0)) }
                        resetInput()
                        
                        Task {
                            do {
                                try await chatProvider.startStreamedChat(parameters: .init(
                                    messages: [.init(role: .user, content: .contentArray(content))],
                                    model: .gpt4o, maxTokens: 100), content: content)
                                print("startStreamedChat function called") // Debugging statement
                            } catch {
                                print("Error calling startStreamedChat: \(error)") // Debugging statement
                            }
                        }
                        
                    case .failure(let error):
                        print("Error fetching images: \(error)")
                    }
                }
            }
        } label: {
            Text("Analyze Outfits")
        }
        .buttonStyle(.bordered)
        .disabled(prompt.isEmpty)
    }
    
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func fetchImagesFromFirebase(completion: @escaping (Result<Void, Error>) -> Void) {
        selectedImages.removeAll()
        selectedImageURLS.removeAll()
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images/")

        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error fetching images from Firebase: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.success(()))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for item in result.items {
                dispatchGroup.enter()
                item.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                    defer { dispatchGroup.leave() }
                    if let error = error {
                        print("Error fetching individual image data: \(error)")
                        return
                    }
                    
                    if let data = data {
                        let base64String = data.base64EncodedString()
                        let url = URL(string: "data:image/jpeg;base64,\(base64String)")!
                        self.selectedImageURLS.append(url)
                        
                        // If you need the image to be displayed in the UI, convert it to UIImage
                        // if let uiImage = UIImage(data: data) {
                        //    let image = Image(uiImage: uiImage)
                        //    self.selectedImages.append(image)
                        // }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(()))
            }
        }
    }
    
    /// Called when the user taps on the send button. Clears the selected images and prompt.
    private func resetInput() {
       prompt = ""
       selectedImages = []
       selectedItems = []
       selectedImageURLS = []
    }
}


