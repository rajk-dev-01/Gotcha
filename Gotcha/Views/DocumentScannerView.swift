//
//  DocumentScannerView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/6/25.
//

import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onScanComplete: (_ image: UIImage) -> Void
    
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
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.presentationMode.wrappedValue.dismiss()
            guard scan.pageCount > 0 else { return }
            let originalImage = scan.imageOfPage(at: 0)
            let resizedImage = resizeImage(image: originalImage, targetWidth: 1200) ?? originalImage
            parent.onScanComplete(resizedImage)
        }
        
        private func resizeImage(image: UIImage, targetWidth: CGFloat) -> UIImage? {
            let scale = targetWidth / image.size.width
            let targetHeight = image.size.height * scale
            let targetSize = CGSize(width: targetWidth, height: targetHeight)
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
    }
}
