//
//  ImagePicker.swift
//  Taichi
//
//  Created by Toan Nguyen on 1/7/25.
//

import Foundation
import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    var selectionLimit: Int = 1
    var onSuccess: ([UIImage]) -> Void
    
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            var images: [UIImage] = []
            let dispatchGroup = DispatchGroup()
            
            for result in results {
                let provider = result.itemProvider
                guard provider.canLoadObject(ofClass: UIImage.self) else { continue }
                
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { dispatchGroup.leave() }
                    if let image = object as? UIImage {
                        images.append(image)
                    } else if let error {
                        print("ImagePicker load error: \(error.localizedDescription)")
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if !images.isEmpty {
                    self.parent.onSuccess(images)
                }
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
