import SwiftUI

/// For now, only with skeleton.
public class SVGLayer {
	let svgUrl: URL
	let skeletonStructure: Joint
	var scaleFactor: CGFloat
	let clipsToBounds: Bool
	
	public var caLayer: CALayer?
	
	public init(
		svgUrl: URL,
		skeletonStructure: Joint,
		scaleFactor: CGFloat = 1,
		clipsToBounds: Bool = false
	) {
		self.svgUrl = svgUrl
		self.skeletonStructure = skeletonStructure
		self.scaleFactor = scaleFactor
		self.clipsToBounds = clipsToBounds
	}
	
	// Note: If struct SVGLayer is preferred,
	// I could make the loadLayer instead create a new instance of SVGLayer with the new layer now,
	// and perform completion with that new layer as the input.
	public func loadLayer(completion: @escaping (CALayer) -> Void) {
		do {
			try SVGtoCALayer(url: svgUrl, skeletonStructure: skeletonStructure, closureOnFinish: { layer in
				self.caLayer = layer
				completion(layer)
			})
		} catch {
			print("Error loading SVG: \(error)")
		}
	}
}

/// Tree graph node for encoding the skeletal structure.
public class Joint {
	let id: Int
	let directedChildren: [Joint]
	// Do I need these?:
	var parent : Joint?
	var position: CGPoint?
	
	public init(id: Int, directedChildren: [Joint]) {
		self.id = id
		self.directedChildren = directedChildren
	}
}

/// An example of a skeleton structure.
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
