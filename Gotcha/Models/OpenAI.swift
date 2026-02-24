//
//  OpenAI.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 10/2/25.
//  MVVM - Model: OpenAI receipt parsing service
//

import Foundation

class OpenAIService {
    private let apiKey: String = {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let key = infoDictionary["OPENAI_API_KEY"] as? String,
              !key.isEmpty else {
            print("❌ CRITICAL ERROR: Missing OpenAI API key in Info.plist")
            return ""
        }
        return key
    }()
    
    func extractReceiptInfo(from text: String) async throws -> [String: Any] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing API Key"])
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        let prompt = """
        Analyze this receipt text and extract the following fields:
        - Store Name
        - Date
        - Total Amount
        - Address
        - Payment Method
        - Name (Customer Name)
        - Phone Number
        - Receipt Id
        - Tracking Numbers (if package receipt)

        If a field is missing, use "NOT AVAILABLE".
        Return ONLY valid JSON.
        Keys: storeName, date, totalAmount, address, paymentMethod, name, phoneNumber, receiptId, tracking.
        
        Receipt Text:
        \(text)
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": "You are a helpful receipt parsing assistant. You output strict JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.1
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("❌ OpenAI API Error: \(errorMsg)")
            throw NSError(domain: "OpenAIService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String,
           let data = content.data(using: .utf8),
           let parsedResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("✅ Successfully parsed JSON: \(parsedResult)")
            return parsedResult
        }
        
        throw NSError(domain: "OpenAIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI JSON structure"])
    }
}
