import UIKit

/// Utility for converting attachments to HTML representations.
enum AttachmentService {

    /// Converts a UIImage to an inline base64-encoded HTML `<img>` tag.
    static func imageToHTML(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let base64 = data.base64EncodedString()
        return """
        <img src="data:image/jpeg;base64,\(base64)" \
        style="max-width:100%;height:auto;border-radius:8px;margin:8px 0;" />
        """
    }

    /// Creates an HTML div representing a generic file attachment.
    static func fileToHTML(filename: String) -> String {
        """
        <div style="display:flex;align-items:center;gap:8px;\
        padding:12px;background:#f0f0f0;border-radius:8px;\
        margin:8px 0;font-family:system-ui;">
            <span style="font-size:24px;">📎</span>
            <span style="font-weight:600;">\(filename)</span>
        </div>
        """
    }
}
