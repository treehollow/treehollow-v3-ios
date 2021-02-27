//
//  ImagePicker.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/12.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImagePickerModifier: ViewModifier {
    @Binding var presented: Bool
    @Binding var image: UIImage?
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $presented) {
            ImagePicker(presented: $presented, image: $image)
        }
    }
}

struct ImagePicker: View {
    @Binding var presented: Bool
    @Binding var image: UIImage?
    
    var body: some View {
        ImagePickerWrapper(image: $image, presented: $presented)
    }
}

fileprivate struct ImagePickerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    
    var image: Binding<UIImage?>
    var presented: Binding<Bool>
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        controller.mediaTypes = ["public.image"]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerWrapper
        
        init(_ parent: ImagePickerWrapper) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presented.wrappedValue = false
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.image.wrappedValue = image
            parent.presented.wrappedValue = false
        }
    }
}
