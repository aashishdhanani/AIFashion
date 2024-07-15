//
//  SuggestionsViewModel.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI
import SwiftOpenAI

@Observable class ChatVisionProvider {
   
   // MARK: - Private Properties
   private let service: OpenAIService
   
   // Accumulates the streamed message content for real-time display updates in the UI.
   private var temporalReceivedMessageContent: String = ""
   // Tracks the identifier of the last message displayed, enabling updates in the from the streaming API response.
   private var lastDisplayedMessageID: UUID?

   // MARK: - Public Properties

   // A collection of messages for display in the UI, representing the conversation.
   var chatMessages: [ChatDisplayMessage] = []

   // MARK: - Initializer
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   // MARK: - Public Methods
   
   func startStreamedChat(
       parameters: ChatCompletionParameters,
       content: [ChatCompletionParameters.Message.ContentType.MessageContent]) async throws
   {
       print("Inside startStreamedChat function") // Debugging statement

       // Filter out text prompts and keep only image URLs for display
       let displayContent = content.filter {
           if case .imageUrl(_) = $0 {
               return true
           }
           return false
       }

       await startNewUserDisplayMessage(displayContent)
       await startNewAssistantEmptyDisplayMessage()
       
       do {
           let stream = try await service.startStreamedChat(parameters: parameters)
           print("Stream started") // Debugging statement
           for try await result in stream {
               print("Received a result from the stream") // Debugging statement
               guard let choice = result.choices.first else {
                   print("No choices found in stream result")
                   return
               }
               
               print("Stream result choice: \(choice)") // Debugging statement
               let newContent = choice.message.content ?? ""
               print("Updating last assistant message with content: \(newContent)")
               await updateLastAssistantMessage(content: newContent, role: choice.message.role ?? "")
           }
       } catch {
           print("Error while streaming chat: \(error)") // Debugging statement
           updateLastDisplayedMessage(.init(content: .error("\(error)"), type: .received, delta: nil))
       }
   }
     
   
   // MARK: - Private Methods
   
   @MainActor
   private func startNewUserDisplayMessage(_ content: [ChatCompletionParameters.Message.ContentType.MessageContent]) {
      print("Starting new user message with content: \(content)")
      guard !content.isEmpty else { return } // Prevent displaying empty content
      let startingMessage = ChatDisplayMessage(
         content: .content(content),
         type: .sent, delta: nil)
      addMessage(startingMessage)
   }
   
   @MainActor
   private func startNewAssistantEmptyDisplayMessage() {
      print("Starting new assistant empty message")
      temporalReceivedMessageContent = ""
      let newMessage = ChatDisplayMessage(content: .text(temporalReceivedMessageContent), type: .received, delta: nil)
      let newMessageId = newMessage.id
      lastDisplayedMessageID = newMessageId
      addMessage(newMessage)
   }
   
   @MainActor
   private func updateLastAssistantMessage(
      content: String,
      role: String)
   {
      temporalReceivedMessageContent += content
      guard let id = lastDisplayedMessageID, let index = chatMessages.firstIndex(where: { $0.id == id }) else { return }
      chatMessages[index] = ChatDisplayMessage(id: id, content: .text(temporalReceivedMessageContent), type: .received, delta: nil)
   }
   
   @MainActor
   private func addMessage(_ message: ChatDisplayMessage) {
      print("Adding new message: \(message)")
      withAnimation {
         chatMessages.append(message)
      }
   }
   
   private func updateLastDisplayedMessage(_ message: ChatDisplayMessage) {
      print("Updating last displayed message: \(message)")
      chatMessages[chatMessages.count - 1] = message
   }
}
