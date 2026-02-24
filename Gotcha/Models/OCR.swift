//
//  OCR.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 11/10/25.
//  MVVM - Model: Vision OCR service
//

import Foundation
import Vision
import UIKit

class OCRHelper {
    static func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { completion("Failed to convert UIImage to CGImage") }
            return
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let recognizedText = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                DispatchQueue.main.async { completion(recognizedText) }
            } catch {
                DispatchQueue.main.async {
                    completion("OCR failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
