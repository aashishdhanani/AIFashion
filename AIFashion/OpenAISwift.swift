//
//  OpenAISwift.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import Foundation
import SwiftOpenAI

public enum APIError: Error {
    case requestFailed(description: String)
    case responseUnsuccessful(description: String, statusCode: Int)
    case invalidData
    case jsonDecodingFailure(description: String)
    case dataCouldNotBeReadMissingData(description: String)
    case bothDecodingStrategiesFailed
    case timeOutError

    public var displayDescription: String {
        switch self {
        case .requestFailed(let description): return description
        case .responseUnsuccessful(let description, _): return description
        case .invalidData: return "Invalid data"
        case .jsonDecodingFailure(let description): return description
        case .dataCouldNotBeReadMissingData(let description): return description
        case .bothDecodingStrategiesFailed: return "Decoding strategies failed."
        case .timeOutError: return "Time Out Error."
        }
    }
}

public enum Authorization {
    case apiKey(String)
    case bearer(String)

    var headerField: String {
        switch self {
        case .apiKey:
            return "api-key"
        case .bearer:
            return "Authorization"
        }
    }

    var value: String {
        switch self {
        case .apiKey(let value):
            return value
        case .bearer(let value):
            return "Bearer \(value)"
        }
    }
}

public protocol OpenAIService {
    var session: URLSession { get }
    var decoder: JSONDecoder { get }

    func startChat(parameters: ChatCompletionParameters) async throws -> ChatCompletionObject
    func startStreamedChat(parameters: ChatCompletionParameters) async throws -> AsyncThrowingStream<CustomChatCompletionChunkObject, Error>
}

public class DefaultOpenAIService: OpenAIService {
    public let session: URLSession
    public let decoder: JSONDecoder
    private let baseURL: URL
    private let authorization: Authorization

    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder(), baseURL: URL, authorization: Authorization) {
        self.session = session
        self.decoder = decoder
        self.baseURL = baseURL
        self.authorization = authorization
        
        // Configure decoder settings if needed
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func startChat(parameters: ChatCompletionParameters) async throws -> ChatCompletionObject {
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/chat/completions"))
        request.httpMethod = "POST"
        request.addValue(authorization.value, forHTTPHeaderField: authorization.headerField)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(parameters)

        return try await fetch(type: ChatCompletionObject.self, with: request)
    }

    public func startStreamedChat(parameters: ChatCompletionParameters) async throws -> AsyncThrowingStream<CustomChatCompletionChunkObject, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/chat/completions"))
        request.httpMethod = "POST"
        request.addValue(authorization.value, forHTTPHeaderField: authorization.headerField)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(parameters)

        return try await fetchStream(type: CustomChatCompletionChunkObject.self, with: request)
    }

    private func fetch<T: Decodable>(type: T.Type, with request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response: unable to get a valid HTTPURLResponse")
        }
        guard httpResponse.statusCode == 200 else {
            let errorMessage = "Status code \(httpResponse.statusCode)"
            throw APIError.responseUnsuccessful(description: errorMessage, statusCode: httpResponse.statusCode)
        }
        return try decoder.decode(type, from: data)
    }

    public func fetchStream<T: Decodable>(
        type: T.Type,
        with request: URLRequest)
        async throws -> AsyncThrowingStream<T, Error>
    {
        let (data, response) = try await session.bytes(
            for: request,
            delegate: session.delegate as? URLSessionTaskDelegate
        )
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response: unable to get a valid HTTPURLResponse")
        }
        guard httpResponse.statusCode == 200 else {
            var errorMessage = "status code \(httpResponse.statusCode)"
            do {
                let data = try await data.reduce(into: Data()) { data, byte in
                    data.append(byte)
                }
                let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
                errorMessage += " \(error.error.message ?? "NO ERROR MESSAGE PROVIDED")"
            } catch {
                // If decoding fails, proceed with a general error message
                errorMessage = "status code \(httpResponse.statusCode)"
            }
            throw APIError.responseUnsuccessful(description: errorMessage,
                                                statusCode: httpResponse.statusCode)
        }
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    print("Starting to read stream lines") // Debugging statement
                    var jsonString = ""
                    for try await line in data.lines {
                        print("Read a line: \(line)") // Debugging statement
                        jsonString.append(line)
                        jsonString.append("\n")
                    }
                    
                    // Attempt to decode the accumulated JSON string after the loop completes
                    if let data = jsonString.data(using: .utf8) {
                        do {
                            let decoded = try self.decoder.decode(T.self, from: data)
                            continuation.yield(decoded)
                        } catch let DecodingError.keyNotFound(key, context) {
                            print("Decoding error: Key '\(key.stringValue)' not found: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        } catch let DecodingError.typeMismatch(type, context) {
                            print("Decoding error: Type '\(type)' mismatch: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        } catch let DecodingError.valueNotFound(value, context) {
                            print("Decoding error: Value '\(value)' not found: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        } catch let DecodingError.dataCorrupted(context) {
                            print("Decoding error: Data corrupted: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        } catch {
                            print("Decoding error: \(error.localizedDescription)")
                            throw error
                        }
                    }
                    continuation.finish()
                } catch let DecodingError.keyNotFound(key, context) {
                    let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                    let codingPath = "codingPath: \(context.codingPath)"
                    let debugMessage = debug + codingPath
                    #if DEBUG
                    print(debugMessage)
                    #endif
                    throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
                } catch {
                    #if DEBUG
                    print("CONTINUATION ERROR DECODING \(error.localizedDescription)")
                    #endif
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}

