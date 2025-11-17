//
//  CameraView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/6/25.
//

import SwiftUI
import VisionKit
import Vision

struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    // Pass scanned images + OCR text back to parent
    var onScanComplete: (_ images: [UIImage], _ recognizedText: String) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            print("❌ Scanning failed: \(error.localizedDescription)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            
            parent.presentationMode.wrappedValue.dismiss()
            
            // ✅ Run OCR on first page (or loop if multi-page)
            DispatchQueue.global(qos: .userInitiated).async {
                guard let firstImage = images.first else {
                    DispatchQueue.main.async {
                        self.parent.onScanComplete(images, "❌ No image found for OCR")
                    }
                    return
                }
                
                // ✅ Use the shared OCRHelper instead of inline OCR logic
                OCRHelper.extractText(from: firstImage) { recognizedText in
                    DispatchQueue.main.async {
                        self.parent.onScanComplete(images, recognizedText)
                    }
                }
            }
        }
    }
}
