
import SwiftUI
import UIKit

// A wrapper for a UIView to integrate into SwiftUI
struct AnimatedLayerViewRepresentable: UIViewRepresentable {
	private var svgUrl: URL
	private var skeletonStructure: Joint
	private let closureAnimationLoaded: (() -> Void)
	
	init(svgUrl: URL, skeletonStructure: Joint, closureAnimationLoaded: @escaping (() -> Void)) {
		self.svgUrl = svgUrl
		self.skeletonStructure = skeletonStructure
		self.closureAnimationLoaded = closureAnimationLoaded
	}
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		do {
			try SVGtoCALayer(url: svgUrl, skeletonStructure: skeletonStructure, closureOnFinish: { animationLayer in
				DispatchQueue.main.async { // Ensure UI updates are on the main thread
					view.layer.addSublayer(animationLayer)
					closureAnimationLoaded()
					// SVG is loaded, but not animation?
					// Probably make another function to call with closure to return animation data here
					let rotLayer = animationLayer.findLayer(withName: "4")
					context.coordinator.startAnimation(for: rotLayer!)
				}
			})
		} catch {
			print("Error loading SVG: \(error)")
		}
		return view
	}
	
	class Coordinator: NSObject, CAAnimationDelegate {
		// Manage any coordination here, if needed.
		var parent: AnimatedLayerViewRepresentable
		
		init(_ parent: AnimatedLayerViewRepresentable) {
			self.parent = parent
		}
		
		// To start the animation
		func startAnimation(for layer: CALayer) {
			// Create a basic animation for rotation around the z-axis
			let animation = CABasicAnimation(keyPath: "transform.rotation.z")
			
			// Set the starting rotation angle (in radians)
			animation.fromValue = 0 // Start at 0 radians (no rotation)
			animation.toValue = 2*Double.pi // Rotate to 2π radians (360 degrees)
			
			// Set animation duration
			animation.duration = 10.0 // Duration of rotation
			
			// Configure animation behavior
			animation.fillMode = .forwards // Keep the final state after animation
			animation.isRemovedOnCompletion = false // Prevent removal of the animation from the layer
			animation.delegate = self // Set self as delegate if using delegate methods

			// Adding the animation to the layer
			layer.add(animation, forKey: "rotationAnimation")
		}
		
		// Notify when animation is completed
		func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
			// Call the closure to notify SwiftUI view------------------------------------------------------------------------------------------------
//			parent.closureAnimationLoaded()
		}
		
	}
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	// Updates the state of the specified view with new information from SwiftUI.
	func updateUIView(_ uiView: UIView, context: Context) {
		// Update the layer size (or do any other updates needed)
		let width = uiView.frame.width
		let height = uiView.frame.height
		
		if let layer = uiView.layer.sublayers?.first {
			layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
		}
	}
	
//	func sizeThatFits(_ proposedSize: CGSize) -> CGSize {
//		// Return the size that fits your requirements here.
//		return CGSize(width: 100, height: 100) // Example size
//	}
}

extension CALayer {
	func findLayer(withName name: String) -> CALayer? {
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
