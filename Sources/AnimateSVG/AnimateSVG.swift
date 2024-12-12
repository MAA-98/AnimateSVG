/// Client facing APIs.

import SwiftUI

public struct SVGAnimationView: View {
	public let svgURL: URL
	public let skeletonStructure: Joint?
	
	@State var animationLoaded: Bool = false
	@State var animationStarted: Bool = false
	@State var animationFinished: Bool = false
	
	public init(svgURL: URL, skeletonStructure: Joint?) {
		self.svgURL = svgURL
		if let skeleton = skeletonStructure {
			self.skeletonStructure = skeleton
		} else {
			// Need to fix this up, if there's no skeleton structure and you want to have a free scene, should do more
			self.skeletonStructure = Joint(id: 0, directedChildren: [])
		}
	}
	
	public var body: some View {
		AnimatedLayerViewRepresentable(
			svgUrl: svgURL,
			skeletonStructure: skeletonStructure!,
			closureAnimationLoaded: { animationLoaded = true }
		)
	}
}

/// A tree node for the skeletal structure
public class Joint {
	let id: Int
	let directedChildren: [Joint]
	var parent : Joint?
	var position: CGPoint?
	
	public init(id: Int, directedChildren: [Joint]) {
		self.id = id
		self.directedChildren = directedChildren
	}
}
