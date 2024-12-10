
import SwiftUI

struct SVGAnimationView: View {
	var svgUrl: URL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Resources/gingerSkeletonTest0.svg") // Fix later as init input
	
	@State var animationLoaded: Bool = false
	@State var animationStarted: Bool = false
	@State var animationFinished: Bool = false
	
	var body: some View {
		Text("Test")
//		AnimatedLayerViewRepresentable(
//			closureAnimationLoaded: { animationLoaded = true },
//			svgUrl: svgUrl
//		)
	}
}

struct SVGSkeletonAnimationView: View {
	var svgUrl: URL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Resources/gingerSkeletonTest0.svg") // Fix later as init input
	var skeletonStructure: [Int: Any]
	
	@State var animationLoaded: Bool = false
	@State var animationStarted: Bool = false
	@State var animationFinished: Bool = false
	
	var body: some View {
		AnimatedLayerViewRepresentable(
			closureAnimationLoaded: { animationLoaded = true },
			svgUrl: svgUrl
		)
	}
}
