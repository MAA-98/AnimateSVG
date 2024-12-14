import Foundation
import QuartzCore
import UIKit // temp for drawing shape

func SVGtoCALayer(url: URL, skeletonStructure: Joint?, closureOnFinish: @escaping (CALayer) -> Void) throws -> Void {
	do {
		let (stream, parser) = try SVGParserFromFile(fileURL: url)
		let parserDelegate = SVGParserDelegate(skeletonStructure: skeletonStructure, closureOnFinish: { animationLayer in
			closureOnFinish(animationLayer)
			stream.close()
		})
		parser.delegate = parserDelegate
		stream.open()
		parser.parse()
	} catch {
		print("Error parsing SVG: \(error)")
	}
}

enum SVGParserFromFileError: Error {
	case fileNotFound
	case invalidFileType
	case inputStreamCreationError
}

func SVGParserFromFile(fileURL: URL) throws -> (InputStream, XMLParser) {
	// Check if the file exists at the provided URL
	guard FileManager.default.fileExists(atPath: fileURL.path) else {
		throw SVGParserFromFileError.fileNotFound
	}
	// Check the file extension is SVG
	guard fileURL.pathExtension.lowercased() == "svg" else {
		throw SVGParserFromFileError.invalidFileType
	}
	// Create an InputStream from the URL
	guard let inputStream = InputStream(url: fileURL) else {
		throw SVGParserFromFileError.inputStreamCreationError
	}
	// Initialize the XMLParser with InputStream
	let parser = XMLParser(stream: inputStream)
	// Return the inputStream and parser
	return (inputStream, parser)
}

// Functions for the parser building up CALayer
class SVGParserDelegate: NSObject, XMLParserDelegate {
	private var skeletonStructure: Joint?
	private var closureOnFinish: ((CALayer) -> Void)
	init(skeletonStructure: Joint? = nil, closureOnFinish: @escaping ((CALayer) -> Void)) {
		self.closureOnFinish = closureOnFinish
		self.skeletonStructure = skeletonStructure
	}
	
	var rootLayer: CALayer? = nil // The layer for the whole SVG
	var skeletonPoints: [CGPoint]? = nil // Positions of joints in the SVG
	var zIndex: CGFloat = 0 // tracker for displaying layers as in SVG
	var layerDict: [Int : CALayer] = [:] // Dict built up for the SVG components
	var currentLayer: CALayer? = nil // Tracker for adding paths to layer
	
	// Enable debug output for testing
	private var debug: Bool = true
	private var debugConsole: [String] = []
	
	// Start of document
	func parserDidStartDocument(_ parser: XMLParser) {
		if debug {
			print("parserDidStartDocument")
		}
	}
	
	// Start of element
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if debug {
			debugConsole.append(" \(elementName)")
		}
		if elementName == "svg" {
			rootLayer = CALayer() // This layers sizing is 750x1000, inherited from the parent layer view in CAtoSwiftUIView
			if let name = attributeDict["id"] {
				rootLayer!.name = name
			}
//			// For sizing?
//			guard let viewBox = attributeDict["viewBox"]?.split(separator: " ").map({ Double($0) }),
//				viewBox.count == 4 else {
//				fatalError("Missing or invalid viewBox attribute in SVG element")
//			}
//			// viewBox gives the size of canvas to be displayed:
//			scene = SKScene(size: CGSize(width: viewBox[2]!-viewBox[0]!, height: viewBox[3]!-viewBox[1]!))
		}
		if elementName == "g" {
			let groupLayer = CALayer()
			if let name = attributeDict["id"] {
				groupLayer.name = name
			}
			if let transform = attributeDict["transform"] { // Change this -----------------Change this -----------------Change this -----------------Change this -----------------Change this -----------------
				groupLayer.svgTransformString(transform)
			}
//			// Set z depth by its ordering in the SVG
			groupLayer.zPosition = zIndex
			// Add to dict of layers
			let key = groupLayer.name!.split(separator: "-").compactMap{ Int($0) }.last
			layerDict.updateValue(groupLayer, forKey: key!)
			currentLayer = groupLayer
		}
		if elementName == "path" {
			if attributeDict["id"] == "skeletonPath" {
				// ASSUMED NO TRANSFORM HERE
				
				// Pull path attribute and set into absolute positions, type [CGPoint], length 20 expected
				skeletonPoints = pathPoints(attributeDict["d"]!) // Could check here same length as the skeletonStructure
			} else {
				let pathCAShapeLayer = addPathStyle(path: oldConvertPath(attributeDict["d"]!), pathStyle: attributeDict["style"]!)
				if let name = attributeDict["id"] {
					pathCAShapeLayer.name = name
				}
				if let transform = attributeDict["transform"] {
					pathCAShapeLayer.svgTransformString(transform)
				}
				pathCAShapeLayer.zPosition = zIndex
				currentLayer!.addSublayer(pathCAShapeLayer)
			}
		}
	}

	// Called when the parser finds text
	func parser(_ parser: XMLParser, foundCharacters string: String) {
	}

	// Called when the parser finds the end of an element
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "g" {
			currentLayer = currentLayer?.superlayer
			zIndex += 1
		}
	}
	
	// End of document
	func parserDidEndDocument(_ parser: XMLParser) {
		if debug {
			//print("debugConsole: (Parent, Element): ", debugConsole)
		}
		if skeletonStructure != nil && skeletonPoints != nil {
			func createSkeletonLayer(joint: Joint, parentJoint: Joint?, parentLayer: CALayer) {
				
				// Set the position of the joint from SVG skeletonPath
				joint.position = skeletonPoints![joint.id]
				if let parent = parentJoint {
					joint.parent = parent
				}
				print("Joint ID and position: ", joint.id, joint.position!) // Makes sense
				
				// Create layer to add onto the 'layerSkeleton'
				let jointLayer = CAShapeLayer()
				jointLayer.name = String(joint.id) // The layer name is only referred by the second joint in the bone
				
				// Calculate position relative to the parent joint's position, first joint placed in center
				let parentX = parentJoint?.position?.x ?? 0
				let parentY = parentJoint?.position?.y ?? 0
				
				let grandparentX = parentJoint?.parent?.position?.x ?? 0
				let grandparentY = parentJoint?.parent?.position?.y ?? 0
				
				// Set the anchorPoint as the normalized position of the joint
				jointLayer.anchorPoint = CGPoint(
					x: 0,
					y: 0
				)
				// Calculate position relative to the anchorPoint, I think this is wrong -----------------------------------------------------------------------
				jointLayer.position = CGPoint(
					x: parentX - grandparentX,
					y: parentY - grandparentY
				)
				
				// TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP
				//			let radius: CGFloat = 10.0
				//			let center = CGPoint(x: 0, y: 0)
				//			let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
				//			jointLayer.path = circlePath.cgPath
				// TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP ----TEMP
				parentLayer.addSublayer(jointLayer)
				
				if let svgComponent = layerDict[joint.id] {
					svgComponent.anchorPoint = CGPoint(
						x: 0,
						y: 0
					)
					// Because the anchorPoint is at (0,0), you'll want to draw the paths with the parentJoint at origin
					let plainAnchor = CATransform3DMakeTranslation(-parentX, -parentY, 0)
					//print("plainAnchor of joint \(joint.id): ", plainAnchor)
					svgComponent.transform = CATransform3DConcat(svgComponent.transform, plainAnchor)
					
					jointLayer.addSublayer(svgComponent)
					// You don't want the skeleton tree hierarchy to determine drawing order but the SVG's drawing order
					jointLayer.zPosition = svgComponent.zPosition
				}
				
				let children = joint.directedChildren
				if !children.isEmpty {
					for child in children {
						let jointLayer =
						createSkeletonLayer(joint: child, parentJoint: joint, parentLayer: jointLayer)
					}
				}
			}
			createSkeletonLayer(joint: skeletonStructure!, parentJoint: nil, parentLayer: rootLayer!)
		}
		closureOnFinish(rootLayer!)
	}

	// Called if an error occurs
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print("Error: \(parseError.localizedDescription)")
	}
}

extension CALayer {
	
	func svgTransformString(_ transformString: String) {
			
		guard let transform = splitString(transformString) else {
			print("Invalid transform attribute in SVG element: \(transformString)")
			return
		}
		
		if transform.first == "translate" && transform.count == 3 {
			let translation = CATransform3DMakeTranslation(Double(transform[1])!, Double(transform[2])!, 0)
			self.transform = CATransform3DConcat(self.transform, translation)
		}
		if transform.first == "matrix" && transform.count == 7 {
			let a: CGFloat = Double(transform[1])!
			let b: CGFloat = Double(transform[2])!
			let c: CGFloat = Double(transform[3])!
			let d: CGFloat = Double(transform[4])!
			let transform = CATransform3DMakeAffineTransform(
				CGAffineTransform(a: a, b: b, c: c, d: d, tx: Double(transform[5])!, ty: Double(transform[6])!)
			)
			self.transform = CATransform3DConcat(self.transform, transform)
		}
	}
}

func splitString(_ string: String) -> [String]? {
	// Define a regular expression pattern that matches any of the separators
	let pattern = "[(),]+"
	
	// Use NSRegularExpression to split the string
	do {
		let regex = try NSRegularExpression(pattern: pattern, options: [])
		// Use the regex to find matches and make splits based on them
		let range = NSRange(location: 0, length: string.utf16.count)
		let splitArray = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: " ").components(separatedBy: .whitespaces).filter { !$0.isEmpty }
		return splitArray
	} catch {
		print("Invalid regex: \(error.localizedDescription)")
	}
	return nil
}
