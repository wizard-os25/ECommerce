//
//  APIErrorParser.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import Foundation

/// Helper to parse error messages from API error responses
struct APIErrorParser {
    
    /// Parse error message from DataTransferError
    static func parseErrorMessage(from error: Error) -> String {
        // Check if it's a DataTransferError
        if let dataTransferError = error as? DataTransferError {
            return parseErrorMessage(from: dataTransferError)
        }
        
        // Check if it's a NetworkError
        if let networkError = error as? NetworkError {
            return parseErrorMessage(from: networkError)
        }
        
        // Fallback to localized description
        return error.localizedDescription
    }
    
    /// Parse error message from DataTransferError
    static func parseErrorMessage(from error: DataTransferError) -> String {
        switch error {
        case .networkFailure(let networkError):
            return parseErrorMessage(from: networkError)
        case .parsing(let parsingError):
            // Try to parse API error response from parsing error
            if let decodingError = parsingError as? DecodingError {
                return parseDecodingError(decodingError)
            }
            return parsingError.localizedDescription
        case .resolvedNetworkFailure(let resolvedError):
            if let networkError = resolvedError as? NetworkError {
                return parseErrorMessage(from: networkError)
            }
            return resolvedError.localizedDescription
        case .noResponse:
            return "No response from server. Please try again."
        }
    }
    
    /// Parse error message from NetworkError
    static func parseErrorMessage(from error: NetworkError) -> String {
        switch error {
        case .error(let statusCode, let data):
            // Try to parse error message from response data
            if let errorMessage = parseAPIErrorResponse(data: data) {
                return errorMessage
            }
            
            // Fallback to status code based message
            return getDefaultErrorMessage(for: statusCode)
        case .notConnected:
            return "No internet connection. Please check your network and try again."
        case .cancelled:
            return "Request was cancelled."
        case .generic(let genericError):
            return genericError.localizedDescription
        case .urlGeneration:
            return "Invalid request. Please try again."
        }
    }
    
    /// Parse API error response structure: { "statusCode": 400, "success": false, "message": "Error message" }
    private static func parseAPIErrorResponse(data: Data?) -> String? {
        guard let data = data else { return nil }
        
        // Debug: Print raw response data in debug mode
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("API Error Response: \(jsonString)")
        }
        #endif
        
        // First try to parse as dictionary to be more flexible
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // Check for "errors" array with objects (format: [{"field":"...","code":"...","message":"..."}])
            if let errorsArray = jsonObject["errors"] as? [[String: Any]], !errorsArray.isEmpty {
                let errorMessages = errorsArray.compactMap { errorObj -> String? in
                    if let message = errorObj["message"] as? String, !message.isEmpty {
                        return message
                    }
                    return nil
                }
                if !errorMessages.isEmpty {
                    return errorMessages.joined(separator: ". ")
                }
            }
            
            // Check for "errors" array of strings (some APIs return errors as array of strings)
            if let errors = jsonObject["errors"] as? [String], !errors.isEmpty {
                return errors.joined(separator: ". ")
            }
            
            // Check for "message" key (most common)
            if let message = jsonObject["message"] as? String, !message.isEmpty {
                return message
            }
            
            // Check for "error" key
            if let errorMessage = jsonObject["error"] as? String, !errorMessage.isEmpty {
                return errorMessage
            }
            
            // Check for nested error message
            if let errorDict = jsonObject["error"] as? [String: Any],
               let message = errorDict["message"] as? String, !message.isEmpty {
                return message
            }
            
            // Check for "detail" key (some APIs use this)
            if let detail = jsonObject["detail"] as? String, !detail.isEmpty {
                return detail
            }
        }
        
        // Try to decode as structured API error response
        do {
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            if !errorResponse.message.isEmpty {
                return errorResponse.message
            }
        } catch {
            // Decoding failed, but we already tried dictionary parsing above
            #if DEBUG
            print("Failed to decode API error response: \(error)")
            #endif
        }
        
        return nil
    }
    
    /// Get default error message based on HTTP status code
    private static func getDefaultErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Invalid request. Please check your input and try again."
        case 401:
            return "Unauthorized. Please login again."
        case 403:
            return "Access denied. Please check your credentials or contact support."
        case 404:
            return "Resource not found."
        case 422:
            return "Validation error. Please check your input."
        case 500:
            return "Server error. Please try again later."
        case 503:
            return "Service unavailable. Please try again later."
        default:
            return "An error occurred. Please try again. (Error code: \(statusCode))"
        }
    }
    
    /// Parse DecodingError to get more specific error message
    private static func parseDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            return context.debugDescription
        case .keyNotFound(let key, let context):
            return "Missing field: \(key.stringValue). \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            return "Type mismatch for field: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Expected \(type). \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Missing value for type \(type) at: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
        @unknown default:
            return "Failed to parse response. Please try again."
        }
    }
}

/// API Error Response structure
private struct APIErrorResponse: Decodable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case success
        case message
        case data
    }
}
