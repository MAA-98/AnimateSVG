/// Client facing APIs.

import SwiftUI

/// Tree node for the skeletal structure
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

/// Example skeleton structure used:
public struct ExampleSkeletonStructure {
	public let skeleton = Joint(id: 11, directedChildren:
			[Joint(id: 10, directedChildren:
					[Joint(id: 1, directedChildren:
							[Joint(id: 0, directedChildren: []),
							 Joint(id: 2, directedChildren:
									[Joint(id: 4, directedChildren:
											[Joint(id: 6, directedChildren:
													[Joint(id: 8, directedChildren: [])])])]),
							 Joint(id: 3, directedChildren:
									[Joint(id: 5, directedChildren:
											[Joint(id: 7, directedChildren:
													[Joint(id: 9, directedChildren: [])])])])])]),
			 Joint(id: 12, directedChildren: [
				Joint(id: 14, directedChildren: [
					Joint(id: 16, directedChildren: [
						Joint(id: 18, directedChildren: [])])])]),
			 Joint(id: 13, directedChildren: [
				Joint(id: 15, directedChildren: [
					Joint(id: 17, directedChildren: [
						Joint(id: 19, directedChildren: [])])])])])
	
	public init(){}
}
  
/// New API for greater control
public class SVGAnimation {
	let svgUrl: URL
	let skeletonStructure: Joint
	var sizeScaleFactor: CGFloat
	let clipsToBounds: Bool
	
	public var layer: CALayer?
	
	public init(
		svgUrl: URL,
		skeletonStructure: Joint,
		sizeScaleFactor: CGFloat = 1,
		clipsToBounds: Bool = false
	) {
		self.svgUrl = svgUrl
		self.skeletonStructure = skeletonStructure
		self.sizeScaleFactor = sizeScaleFactor
		self.clipsToBounds = clipsToBounds
	}
	
	public func loadLayer(loadFinishedClosure: @escaping (CALayer) -> Void) {
		do {
			try SVGtoCALayer(url: svgUrl, skeletonStructure: skeletonStructure, closureOnFinish: { scene in
				self.layer = scene
				loadFinishedClosure(scene)
			})
		} catch {
			print("Error loading SVG: \(error)")
		}
	}
}

// DEPRACATED? ------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
