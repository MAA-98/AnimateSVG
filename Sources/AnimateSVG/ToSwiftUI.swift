import SwiftUI
import UIKit

// A wrapper for a UIView to integrate into SwiftUI
struct AnimatedLayerViewRepresentable: UIViewRepresentable {
	private var svgUrl: URL
	private var skeletonStructure: Joint?
	private let closureAnimationLoaded: (() -> Void)?
	
	/// Options for the View
	private let clipsToBounds: Bool
	
	init(svgUrl: URL, skeletonStructure: Joint? = nil, closureAnimationLoaded: (() -> Void)? = nil, clipsToBounds: Bool) {
		self.svgUrl = svgUrl
		self.skeletonStructure = skeletonStructure
		self.closureAnimationLoaded = closureAnimationLoaded
		self.clipsToBounds = clipsToBounds
	}
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		// Set options
		view.clipsToBounds = clipsToBounds
		do {
			try SVGtoCALayer(url: svgUrl, skeletonStructure: skeletonStructure, closureOnFinish: { animationLayer in
				DispatchQueue.main.async { // Ensure UI updates are on the main thread
					view.layer.addSublayer(animationLayer)
					closureAnimationLoaded?()
					
					// TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------
					// Make another function to call with closure to return animation data here
					let rotLayer = animationLayer.findLayer(withName: "6")
					if let layer = rotLayer {
						context.coordinator.startAnimation(for: layer)
					}
					// TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------ TEMP ------
				}
			})
		} catch {
			print("Error loading SVG: \(error)")
		}
		return view
	}
	
	// TO DO ---------------------------------------------------------------------------------------------------------------------------------------------------------
	// Updates the state of the specified view with new information from SwiftUI.
	func updateUIView(_ uiView: UIView, context: Context) {
		// Update the layer size (or do any other updates needed)
		let width = uiView.frame.width
		let height = uiView.frame.height
		
		if let layer = uiView.layer.sublayers?.first {
			layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
		}
	}
	
	func sizeThatFits(_ proposedSize: CGSize) -> CGSize {
		// Return the size that fits your requirements here.
		return CGSize(width: 100, height: 100) // Example size
	}
	
	class Coordinator: NSObject, CAAnimationDelegate {
		// Manage any coordination here, if needed.
		var parent: AnimatedLayerViewRepresentable
		
		init(_ parent: AnimatedLayerViewRepresentable) {
			self.parent = parent
		}
		
		// To start the animation
		func startAnimation(for layer: CALayer) {
			// Create a keyframe animation for rotation around the z-axis
			let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")

			// Define the keyframes for clockwise and counterclockwise rotations
			animation.values = [Double.pi/2, 3*Double.pi / 4, Double.pi/2, 3*Double.pi / 4, Double.pi/2]

			// Specify the duration for each keyframe (3 seconds for a full cycle)
			animation.keyTimes = [0, 0.25, 0.5, 0.75, 1] // Corresponds to 0%, 25%, 50%, 75%, 100%
			animation.duration = 6.0 // Total duration for one complete loop
			animation.repeatCount = .infinity // Loop infinitely
			
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
