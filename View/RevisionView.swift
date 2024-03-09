import Foundation
import SwiftUI
import SwiftData
import WebKit

struct RevisionView: View {
    @Bindable var revision: Revision

    var body: some View {
        Text("\(revision.user)")
            .italic()

        Text("\(revision.size) bytes")

        let comment = revision.comment != "" ? revision.comment : "<i>No comment</i>"
        HTMLText(html: comment)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 500, maxHeight: .infinity, alignment: .center)
                .padding()
    }
}

struct HTMLText: UIViewRepresentable {
    let html: String
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            if let data = self.html.data(using: .utf8), let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                uiView.attributedText = attributedString
            }
        }
    }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let textView = UITextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.backgroundColor = .clear
        return textView
    }
}
