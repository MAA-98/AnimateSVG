///  PathConverter.swift
///
///  - Possible improvements:
///   - Add v, V, h, H commands functionality in convertPath, drawCommand.
///   - Add handling of SVG's attributes of style, rather than only supporting CSS style command.

import Foundation
import CoreGraphics
import QuartzCore

/// Function: Initializer creating a point from a coordinate string that contains two comma-separated values, representing the x and y coordinates.
/// Example: `CGPoint(string: "1.2,3")` returns the same value as `GCPoint(x: 1.2, y: 3.0)`.
/// Error Handling: If splitting doesn't give two elements then an error is printed but parsing continues.
/// 	If the split string is not parsed into two `Double` values, ingoring nil, the initializer will return `nil` value and print non-blocking error.
extension CGPoint{
	init?(string: String) {
		 
		let coordsSplit = string.split(separator: ",")
			
		if coordsSplit.count != 2 {
			print(#function, string, " does not have two elements after split.")
		}
		
		let coords = coordsSplit.compactMap{Double($0)}
		
		if coords.count == 2 {
			let x = coords[0]
			let y = coords[1]
			self.init(x: x, y: y)
		} else {
			print(#function, string, " does not have two Double elements.")
			return nil
		}
	}
}

/// Converts a string representation of an SVG path into a `CGPath`.
/// The path is defined by a `String` interpreted as a series of commands and coordinate pairs, separated by space.
/// This function supports the basic path commands:
/// - Move (M, m), Line (L, l), Curve (C, c), Close (Z, z)
/// Example: Given the string `"M 10,10 L 20,20"`, this function will create a path that moves to `(10, 10)` and then draws a line to `(20, 20)`.
/// - Returns:
///   - `CGPath` as interpreted from the SVG's <path d=(pathAttribute)>.
/// - Parameters:
///   - pathAttribute:a `String` as interpreted to be SVG's XML path's "d" attribute.
/// - Throws:
///   - Prints errors when commands are unrecognized and continues building the path.
func convertPath(_ pathAttribute: String) -> CGPath {

	// Split the input string by space and convert to an array of strings, possibly nil value
	let commands = pathAttribute.split(separator: " ").map { String($0) }
	// Supported commands array, to be updated when functionality added
	let supportedCommands = ["M", "m", "C", "c", "L", "l", "Z", "z"]
	// Create a mutable path to hold the results
	let path = CGMutablePath()
	// Some vars for keeping track
	var pointsBuffer: [CGPoint] = []
	var cmd: String? = nil
	var firstPoint: CGPoint? = nil
	
	/// Internal method for adding to `path = CGMutablePath()`,
	/// dependent on the current value of `cmd` and `pointsBuffer` in `func convertPath`.
	///
	/// > Warning: When called, `pointsBuffer` will always be cleared back to empty array `[]` after altering path.
	/// > This means when `cmd == nil` and function is callled, then the function simply clears the buffer without changing the `path`.
	///
	/// - Throws:
	///   - Prints error message when the command `"z"` is called and `firstPoint == nil`.
	///   - Prints error when `switch cmd { ... default: ...` case is accessed.
	func drawCommand() {
		switch cmd {
		case "M":
			// If firstPoint is nil then update
			if firstPoint == nil {
				firstPoint = pointsBuffer.first
			}
			if !pointsBuffer.isEmpty {
				path.move(to: pointsBuffer.removeFirst())
			}
			// Implicit L
			for point in pointsBuffer {
				path.addLine(to: point)
			}
			pointsBuffer.removeAll()
		case "m":
			// If firstPoint is nil then update
			if firstPoint == nil {
				firstPoint = pointsBuffer.first
			}
			if !pointsBuffer.isEmpty {
				path.move(to: pointsBuffer.removeFirst())
			}
			// Implicit l
			for point in pointsBuffer {
				path.addLine(to: CGPointApplyAffineTransform(path.currentPoint, CGAffineTransform(translationX: point.x, y: point.y)))
			}
			pointsBuffer.removeAll()
		case "C":
			while pointsBuffer.count >= 3 {
				let control1 = pointsBuffer.removeFirst()
				let control2 = pointsBuffer.removeFirst()
				let endPoint = pointsBuffer.removeFirst()
				path.addCurve(to: endPoint, control1: control1, control2: control2)
			}
		case "c":
			while pointsBuffer.count >= 3 {
				var point = pointsBuffer.removeFirst()
				let control1 = CGPointApplyAffineTransform(path.currentPoint, CGAffineTransform(translationX: point.x, y: point.y))
				point = pointsBuffer.removeFirst()
				let control2 = CGPointApplyAffineTransform(path.currentPoint, CGAffineTransform(translationX: point.x, y: point.y))
				point = pointsBuffer.removeFirst()
				let endPoint = CGPointApplyAffineTransform(path.currentPoint, CGAffineTransform(translationX: point.x, y: point.y))
				path.addCurve(to: endPoint, control1: control1, control2: control2)
			}
		case "L":
			for point in pointsBuffer {
				path.addLine(to: point)
			}
			pointsBuffer.removeAll()
		case "l":
			for point in pointsBuffer {
				path.addLine(to: CGPointApplyAffineTransform(path.currentPoint, CGAffineTransform(translationX: point.x, y: point.y)))
			}
			pointsBuffer.removeAll()
		case "Z", "z":
			if let start = firstPoint {
				path.addLine(to: start)
			} else {
				print("\(#function), \(pathAttribute), command z is called but first point in path is not set.")
			}
		default:
			// In the logic of convertPath, this is only accessed when cmd = nil
			print("\(#function), \(pathAttribute), drawCommand is called but cmd is nil. Clearing pointsBuffer.")
			pointsBuffer.removeAll()
		}
	}
	
	// Parses the `commands`, building up the `path`. Errors handled internally by `CGPoint` extension.
	for command in commands {
		if supportedCommands.contains(command) {
			drawCommand()
			cmd = command
		} else {
			if let coords = CGPoint(string: command) {
				pointsBuffer.append(coords)
			}
		}
	}
	// Final draw call for any non-empty `pointsBuffer`.
	drawCommand()
	return path
}

/// Extension to `CAShapeLayer` to provide a convenience initializer.
///
/// Allows you to create a `CAShapeLayer` with a given `CGPath` and customize its appearance
/// through a string of CSS style definitions. It supports configuring properties such as fill color, stroke color,
/// and line width based on the input string format.
///
/// Example:
/// ```swift
/// let shapeLayer = CAShapeLayer(path: someCGPath, pathStyle: "fill:red;stroke:blue;stroke-width:2")
/// ```
/// The above will create a shape layer with a red fill, a blue stroke, and a line width of 2 points.
///
/// > Warning: Only CSS style commands in the SVG are supported currently.
///
/// Error Handling:
/// If the path style string contains unrecognized commands or values, appropriate messages will
/// be printed, and defaults will be used where necessary.
extension CAShapeLayer {
	
	/// Initializes a `CAShapeLayer` with a specified path and CSS style modifiers.
	/// - Parameters:
	///   - path: A `CGPath` that defines the shape of the layer.
	///   - pathStyle: A string containing styling properties in ``supportedCommands = ["fill", "stroke", "stroke-width"]`` .
	///   The format should be CSS-style: "fill:<color>;stroke:<color>;stroke-width:<value>" (e.g., "fill:red;stroke:blue;stroke-width:2").
	///   Only recognized commands will be applied to the layer.
	/// - Throws:
	/// 	- Any unrecognized, but supported, command will be ignored and an error message printed.
	/// 	- Unsupported commands are ignored without notice.
	/// 	- Uses the operators in ErrorOperator.swift, which returns second input if first input is `nil` and prints the `String` in third input.
	convenience init(path: CGPath, pathStyle: String) {
		
		let supportedCommands = ["fill", "stroke", "stroke-width"]
		
		let commandsList = pathStyle.split(separator: ";").map { String($0) }
		let commandsDict = commandsList.reduce(into: [String : String]()) { dict, string in
			let components = string.split(separator: ":", maxSplits: 1).map { String($0) }
			if supportedCommands.contains(components[0]) {
				let key = String(components[0])
				let value = String(components[1])
				dict[key] = value
			}
		}
		self.init()
		self.path = path
		
		let fillValue = commandsDict["fill"] ?! "none" 						~> "\(#function), fill in \(pathStyle) unrecognized."
		self.fillColor = fillValue == "none" ? nil : CGColor.fromHex(fillValue)
		
		let strokeWidth = Double(commandsDict["stroke-width"] ?! "0" 		~> "\(#function), stroke-width in \(pathStyle) unrecognized.")
		self.lineWidth = strokeWidth ?! 0 									~> "\(#function), stroke-width in \(pathStyle) unrecognized as Double."
		
		// If no stroke, assume same color as fill:
		let strokeValue = commandsDict["stroke"] ?! "none" 					~> "\(#function), stroke in \(pathStyle) unrecognized, value \"none\" used."
		self.strokeColor = strokeValue == "none" ? self.fillColor : CGColor.fromHex(strokeValue)
	}
}

/// Extension to the `CGColor` struct providing a method to create `CGColor` from a hexadecimal color string.
///
/// This extension allows you to easily convert HTML/CSS-style hex color strings into `CGColor` instances.
/// Both 6-digit and 8-digit hex strings are supported.
///
/// Example: The 6-digit string represents RGB values (e.g., "#FF5733") and the 8-digit string includes an alpha value (e.g., "#FF573380").
extension CGColor {
	
	/// Creates a `CGColor` from a hexadecimal color string.
	/// - Parameter hex: A hexadecimal color string. It can be in the format of:
	///   - `#RRGGBB` (6 digits) for full opacity colors.
	///   - `#RRGGBBAA` (8 digits) for colors with alpha.
	/// - Returns: An optional `CGColor`.
	/// - Throws: Function returns `nil` if the provided string is not valid and prints error message.
	static func fromHex(_ hex: String) -> CGColor? {
		
		var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		if hexString.hasPrefix("#") {
			hexString.remove(at: hexString.startIndex)
		}
		var rgb: UInt64 = 0
		Scanner(string: hexString).scanHexInt64(&rgb)
		
		if hexString.count == 6 {
			return CGColor(
				red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
				green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
				blue: CGFloat(rgb & 0xFF) / 255.0,
				alpha: 1.0
			)
		} else if hexString.count == 8 {
			return CGColor(
				red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
				green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
				blue: CGFloat(rgb & 0xFF) / 255.0,
				alpha: CGFloat((rgb >> 24) & 0xFF) / 255.0
			)
		} else {
			print("\(#function), \(hex) seems invalid.")
			return nil
		}
	}
}

/// Converts an SVG path attribute string into an array of `CGPoint` values, the points that make up the path.
///
/// This function takes a string representation of an SVG path (e.g., "M 100,100 L 200,200")
/// and extracts the coordinates defined within it. It recognizes absolute and relative movement accordingly.
///
/// The function supports the following SVG path commands:
/// - **M** or **m**: Move To - defines a new starting point.
/// - **L** or **l**: Line To - draws a line to the specified coordinates.
/// - **C** or **c**: Curve To - creates a Bézier curve to a specified endpoint using control points.
/// - **Z** or **z**: Close Path - draws a line back to the starting point.
///
/// - Parameters:
///   - pathAttribute: A string representing the SVG path's `"d"` attribute, which contains commands
///     and coordinate pairs separated by spaces.
///
/// - Returns:
///   - An array of `CGPoint` representing the extracted path points based on the provided commands.
///
/// - Throws:
///   - Returns empty array if pathAttribute completely unrecoginzed.
///
/// - Prints:
///   - An error message if it encounters unrecognized commands or invalid coordinate values.
func pathPoints(_ pathAttribute: String) -> [CGPoint] {
	let commands = pathAttribute.split(separator: " ").map { String($0) }
	var pathPoints: [CGPoint] = []
	var cmd: String? = nil
	
	for command in commands {
		if ["M", "m", "C", "c", "L", "l", "Z", "z"].contains(command) {
			cmd = command
		} else {
			// command is either unsupported or coord
			if let comm = cmd {
				if let coords = CGPoint(string: command) {
					
					if Character(comm).isLowercase {
						pathPoints.append((pathPoints.last ?? CGPoint.zero).applying(CGAffineTransform(translationX: coords.x, y: coords.y)))
					} else {
						pathPoints.append(coords)
					}
					
				} else {
					print("\(#function), \(pathAttribute) invalid coord (\(command)) or unsupported command.")
				}
			} else {
				print("\(#function), \(pathAttribute) seems invalid (unsupported command)")
			}
		}
	}
	return pathPoints
}
