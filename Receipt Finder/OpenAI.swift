//
//  OpenAI.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 10/2/25.
//

import Foundation
import SwiftUI

class OpenAIService {
    // ✅ Securely read API key from Info.plist
    private let apiKey: String = {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let key = infoDictionary["OPENAI_API_KEY"] as? String,
              !key.isEmpty else {
            fatalError("❌ Missing OpenAI API key. Please add 'OPENAI_API_KEY' to Info.plist.")
        }
        return key
    }()
    
    /// Sends receipt text to OpenAI and returns parsed fields as a dictionary
    func extractReceiptInfo(from text: String, completion: @escaping ([String: Any]?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let prompt = """
        You are a receipt parser. Extract the following fields from this text:
        - Store Name
        - Name (Customer Name only if not available mention NOT AVAILABLE)
        - Date
        - Total Amount
        - Address
        - Payment Method
        - Phone Number
        - Receipt Id
        - Tracking Numbers (numbers used to track packages available only for package receipts, if not available mention NOT AVAILABLE)
        Return them strictly as JSON with keys: storeName, date, totalAmount, address, paymentMethod, name, phoneNumber, receiptId, tracking.
        No extra text, no explanation.

        Receipt text:
        \(text)
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful receipt parser."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to serialize request body: \(error)")
            completion(nil)
            return
        }
        
        // 🔄 Network call
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ OpenAI API error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Extract pure JSON from model response
                    if let start = content.firstIndex(of: "{"),
                       let end = content.lastIndex(of: "}") {
                        let jsonString = String(content[start...end])
                        if let contentData = jsonString.data(using: .utf8),
                           let parsed = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any] {
                            completion(parsed)
                            return
                        }
                    }
                }
                completion(nil)
            } catch {
                print("❌ JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
