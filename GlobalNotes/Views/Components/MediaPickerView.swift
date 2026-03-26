import SwiftUI
import PhotosUI

/// A SwiftUI view that presents a PhotosPicker for selecting images.
struct MediaPickerView: View {
    let onImageSelected: (UIImage) -> Void

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Choose Photo", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(10)
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onImageSelected(image)
                }
            }
        }
    }
}
