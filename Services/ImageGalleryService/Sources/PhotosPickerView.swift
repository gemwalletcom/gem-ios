// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

public struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)var presentationMode
    @Binding var image: UIImage?
    
    public init(image: Binding<UIImage?>) {
        _image = image
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @Binding var presentationMode: PresentationMode
        @Binding var image: UIImage?
        
        public init(
            presentationMode: Binding<PresentationMode>,
            image: Binding<UIImage?>
        ) {
            _presentationMode = presentationMode
            _image = image
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
            image = uiImage
            presentationMode.dismiss()
        }
        
        public func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            presentationMode.dismiss()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(presentationMode: presentationMode, image: $image)
    }
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) {}
}
