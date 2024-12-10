
import Foundation
import QuartzCore

// Humanoid skeleton structure for animation of Ginger
class Joint {
	let id: Int
	let directedChildren: [Joint]
	var position: CGPoint?
	
	init(id: Int, directedChildren: [Joint]) {
		self.id = id
		self.directedChildren = directedChildren
	}
}

func gingerSkeleton() -> Joint {
	let gingerSkeleton =
	Joint(id: 11, directedChildren:
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
	return gingerSkeleton
}

// Parser creation
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
	
	// Return the inputStream (for opening and closing) and parser
	return (inputStream, parser)
}

// Functions for the parser building up Core Animation
class SVGParserDelegate: NSObject, XMLParserDelegate {
	private var closureOnFinish: ((CALayer) -> Void)
	init(closureOnFinish: @escaping ((CALayer) -> Void)) {
		self.closureOnFinish = closureOnFinish
	}
	
	var rootLayer: CALayer? = nil
	var currentLayer: CALayer? = nil
	var layerDict: [[Int] : CALayer] = [:]
	var sourceJoint: Joint? = nil
	var zIndex: CGFloat = 0
	
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
			rootLayer = CALayer()
			if let name = attributeDict["id"] {
				rootLayer!.name = name
			}
			// This layers sizing is 750x1000, inherited from the parent layer view in CAtoSwiftUIView
			
//			// For sizing?
//			guard let viewBox = attributeDict["viewBox"]?.split(separator: " ").map({ Double($0) }),
//				viewBox.count == 4 else {
//				fatalError("Missing or invalid viewBox attribute in SVG element")
//			}
//			// viewBox gives the size of canvas to be displayed:
//			scene = SKScene(size: CGSize(width: viewBox[2]!-viewBox[0]!, height: viewBox[3]!-viewBox[1]!))
		}
		if elementName == "g" {
//			let groupLayer = CALayer()
//			if let name = attributeDict["id"] {
//				groupLayer.name = name
//			}
//			if let transform = attributeDict["transform"] {
//				groupLayer.svgTransformString(transform)
//			}
//			// Change position and anchorPoint here ----------------------------------------------------------------------------------
//			// TO ADD HERE ----------------------------------------------------------------------------------------------------------------
//			groupLayer.positionTransform(CGPoint(x: 0, y: 250))
//
//			// Set z depth by its ordering in the SVG
//			groupLayer.zPosition = zIndex
//			zIndex += 1
//			// Add to dict of layers
//			let key = groupLayer.name!.split(separator: "-").compactMap{ Int($0) }
//			layerDict.updateValue(groupLayer, forKey: key)
//			currentLayer = groupLayer
		}
		if elementName == "path" {
			if attributeDict["id"] == "skeletonPath" {
				// Pull joint structure
				sourceJoint = gingerSkeleton()
				// Pull path attribute and set into absolute positions, type [CGPoint], length 20 expected
				let skeletonPoints = pathPoints(attributeDict["d"]!)
				// Create a "layer skeleton" from the two info
				func createSkeletonLayer(sourceJoint: Joint, positions: [CGPoint]) {
					sourceJoint.position = positions[sourceJoint.id]
					let children = sourceJoint.directedChildren
					if !children.isEmpty {
						for child in children {
							createSkeletonLayer(sourceJoint: child, positions: positions)
						}
					}
				}
				createSkeletonLayer(sourceJoint: sourceJoint!, positions: skeletonPoints)
			} else {
//				let pathCAShapeLayer = addPathStyle(path: oldConvertPath(attributeDict["d"]!), pathStyle: attributeDict["style"]!)
//				if let name = attributeDict["id"] {
//					pathCAShapeLayer.name = name
//				}
//				if let transform = attributeDict["transform"] {
//					pathCAShapeLayer.svgTransformString(transform)
//				}
//				currentLayer!.addSublayer(pathCAShapeLayer)
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
		}
	}
	
	// End of document
	func parserDidEndDocument(_ parser: XMLParser) {
		if debug {
			print("debugConsole: (Parent, Element): ", debugConsole)
		}
		// Join up the layers here, using known skeleton data, have to wait for all the layers to be created--------------------------------------------------------------------------
//		func drawLayersRecursive(_ superLayer: CALayer, sourceJoint: Joint) {
//			let children = sourceJoint.directedChildren
//			for child in children {
//				layersDict(superLayer.name)
//			}
//			
//			for (key, value) in layerDict {
//				if key.first == sourceJointID {
//					superLayer.addSublayer(value)
//					drawLayersRecursive(value, sourceJointID: key[1])
//				}
//			}
//		}
//		drawLayersRecursive(rootLayer, sourceJoint: sourceJoint)
		
		

		
//		for layer in layerDict.values {
//			rootLayer?.addSublayer(layer)
//			// TO ADD HERE ----------------------------------------------------------------------------------------------------------------
//		}
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
			// Create a 2x2 matrix
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
	
	func anchorTransform(_ anchor: CGPoint) {
		// TO ADD HERE ----------------------------------------------------------------------------------------------------------------
		print("Current anchor point: \(self.anchorPoint)")
		
	}
	
	func positionTransform(_ position: CGPoint) {
		// TO ADD HERE ----------------------------------------------------------------------------------------------------------------
		print("Current position point: \(self.position)")
		self.position = position
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

//func projectMatrix(_ matrix: [Double]) -> (Double, Double, Double) {
//	// This function takes in a matrix and returns a projection of it onto the space spanned by rotation and axis scaling
//	guard matrix.count == 4 else {
//		fatalError("Matrix must have 4 elements")
//	}
//	// We have 4 simultaneous equations: Acos(angle) = matrix[0], -Bsin(angle) = matrix[2], Asin(angle) = matrix[1], Bcos(angle) = matrix[3]
//	var angle = 0.0
//	// In general, solutions do not have existence and uniqueness
//	// Pythagoras on first column gives two possibilities for A, fix A>=0 for now
//	let A = sqrt(pow(matrix[0], 2) + pow(matrix[1], 2))
//	print("projectMatrix(matrix): A is: ",A)
//	// cos(angle) = matrix[0]/A gives two possibilities for angle in [0,2*pi), use the sign of matrix[1]=A*sin(angle) for unique determination
//	if matrix[1] >= 0 {
//		angle = acos(matrix[0] / A)
//	} else {
//		angle = -acos(matrix[0] / A)
//	}
//	// Note: if A was instead fixed A<=0, then it would determine the negative of current angle
//	let B = matrix[3]*A/matrix[0]
//	let distance = abs(matrix[2] + matrix[1]*matrix[3]/matrix[0])
//	print("projectMatrix(matrix): Distance: ",distance)
//	// Return the found A, B, angle
//	return (A, B, angle)
//}
