//
//  CustomChatCompletionChunkObject.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import Foundation

/// Placeholder definitions
public struct ToolCall: Decodable {
    // Define properties if needed
}

public struct FunctionCall: Decodable {
    // Define properties if needed
}

/// Custom model matching the expected API response structure
public struct CustomChatCompletionChunkObject: Decodable {
   
   public let id: String
   public let choices: [ChatChoice]
   public let created: Int
   public let model: String
   public let systemFingerprint: String?
   public let object: String
   
   public struct ChatChoice: Decodable {
      
      public let message: ChatMessage
      public let finishReason: String?
      public let index: Int
      public let finishDetails: FinishDetails?
      public let logprobs: LogProb?
      
      public struct ChatMessage: Decodable {
         public let content: String?
         public let toolCalls: [ToolCall]?
         public let functionCall: FunctionCall?
         public let role: String?
         
         enum CodingKeys: String, CodingKey {
            case content
            case toolCalls = "tool_calls"
            case functionCall = "function_call"
            case role
         }
      }
      
      public struct LogProb: Decodable {
         let content: [TokenDetail]
      }
      
      public struct TokenDetail: Decodable {
         let token: String
         let logprob: Double
         let bytes: [Int]?
         let topLogprobs: [TopLogProb]
         
         enum CodingKeys: String, CodingKey {
            case token, logprob, bytes
            case topLogprobs = "top_logprobs"
         }
         
         struct TopLogProb: Decodable {
            let token: String
            let logprob: Double
            let bytes: [Int]?
         }
      }
      
      public struct FinishDetails: Decodable {
         let type: String
      }
      
      enum CodingKeys: String, CodingKey {
         case message
         case finishReason = "finish_reason"
         case index
         case finishDetails = "finish_details"
         case logprobs
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case choices
      case created
      case model
      case systemFingerprint = "system_fingerprint"
      case object
   }
}

