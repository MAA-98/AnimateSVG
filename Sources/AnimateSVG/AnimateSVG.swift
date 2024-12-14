/// Client facing APIs.

import SwiftUI

/// SwiftUI integration
public struct SVGAnimationView: View {
	public let svgUrl: URL
	public let skeletonStructure: Joint?
	
	public let clipsToBounds: Bool
	
	@State var animationLoaded: Bool = false
	@State var animationStarted: Bool = false
	@State var animationFinished: Bool = false
	
	public init(svgUrl: URL, skeletonStructure: Joint?, clipsToBounds: Bool = false) {
		self.svgUrl = svgUrl
		if let skeleton = skeletonStructure {
			self.skeletonStructure = skeleton
		} else {
			// Need to fix this up, if there's no skeleton structure and you want to have a free scene, should do more
			self.skeletonStructure = Joint(id: 0, directedChildren: [])
		}
		self.clipsToBounds = clipsToBounds
	}
	
	public var body: some View {
		AnimatedLayerViewRepresentable(
			svgUrl: svgUrl,
			skeletonStructure: skeletonStructure!,
			closureAnimationLoaded: { animationLoaded = true },
			clipsToBounds: clipsToBounds,
			sizeScaleFactor: 1, // Temp
			UISize: CGSize.zero // Temp
		)
	}
}

public struct SVGSkeletonAnimationView: View {
	public let svgUrl: URL
	public let skeletonStructure: Joint
	public let clipsToBounds: Bool
	public var sizeScaleFactor: CGFloat
	
	public init(svgUrl: URL, skeletonStructure: Joint, clipsToBounds: Bool = false, sizeScaleFactor: CGFloat = 1) {
		self.svgUrl = svgUrl
		self.skeletonStructure = skeletonStructure
		self.clipsToBounds = clipsToBounds
		self.sizeScaleFactor = sizeScaleFactor
	}
	
	public var body: some View {
		GeometryReader { geometry in
			AnimatedLayerViewRepresentable(
				svgUrl: svgUrl,
				skeletonStructure: skeletonStructure,
				clipsToBounds: clipsToBounds,
				sizeScaleFactor: sizeScaleFactor,
				UISize: geometry.size
			)
		}
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
