import SwiftUI
import UIKit

public struct AnimateSVGView: UIViewRepresentable {
	private var SVGLayer: SVGLayer
	
	public init(SVGLayer: SVGLayer) {
		self.SVGLayer = SVGLayer
	}
	
	public func makeUIView(context: Context) -> UIView {
		let view = UIView()
		view.clipsToBounds = SVGLayer.clipsToBounds
		if let layer = SVGLayer.caLayer {
			layer.transform = CATransform3DScale(layer.transform, SVGLayer.scaleFactor, SVGLayer.scaleFactor, 1)
			view.layer.addSublayer(layer)
		}
		return view
	}
	
	public func updateUIView(_ uiView: UIView, context: Context) {
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	public class Coordinator: NSObject, CAAnimationDelegate {
		var parent: AnimateSVGView
		
		init(_ parent: AnimateSVGView) {
			self.parent = parent
		}
		
		// To start the animation
		func startAnimation(for layer: CALayer) {
		}
		
		// Notify when animation is completed
		public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		}
	}
}

extension CALayer {
	public func findLayer(withName name: String) -> CALayer? {
		// Check if the current layer's name matches the target name.
		if self.name == name {
			return self // Return the current layer if it matches.
		}

		// Recursively iterate through the sublayers.
		for sublayer in self.sublayers ?? [] {
			if let foundLayer = sublayer.findLayer(withName: name) {
				return foundLayer // Return the layer if found in the sublayers.
			}
		}

		// If no matching layer is found, return nil.
		return nil
	}
}
