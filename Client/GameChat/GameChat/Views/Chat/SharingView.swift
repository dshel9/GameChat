import SwiftUI

// Custom View Modifier for Share Sheet
struct ShareSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let items: [Any]
    
    func body(content: Content) -> some View {
        content.background(
            ShareSheetView(
                isPresented: $isPresented,
                activityItems: items
            )
        )
    }
}

// Helper View to Present the Share Sheet
struct ShareSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController() // Dummy controller to anchor the presentation
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let activityController = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            activityController.completionWithItemsHandler = { _, _, _, _ in
                isPresented = false // Dismiss when done
            }
            uiViewController.present(activityController, animated: true, completion: nil)
        }
    }
}

// Extension to Make it Reusable
extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        modifier(ShareSheetModifier(isPresented: isPresented, items: items))
    }
}
