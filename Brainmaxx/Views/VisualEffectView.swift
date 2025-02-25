import SwiftUI
import UIKit

// A helper view to use UIKit's blur effect in SwiftUI for backward compatibility
struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
} 