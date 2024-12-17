///  PathConverter.swift

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
			print(#function, string, "does not have two elements after split.")
		}
		
		let coords = coordsSplit.compactMap{Double($0)}
		
		if coords.count == 2 {
			let x = coords[0]
			let y = coords[1]
			self.init(x: x, y: y)
		} else {
			print(#function, string, "does not have two Double.")
			return nil
		}
	}
}

func convertPath(_ pathAttribute: String) -> CGPath {

	let commands = pathAttribute.split(separator: " ").map { String($0) }
	let supportedCommands = ["M", "m", "C", "c", "L", "l", "Z", "z"]
	let path = CGMutablePath()
	
	var pointsBuffer: [CGPoint] = []
	var cmd: String? = nil
	var firstPoint: CGPoint? = nil
	
	// To do later: add HhVv commands
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
			}
		default:
			// Only accessed when cmd = nil
			// Clear any possible points added before a valid cmd
			pointsBuffer.removeAll()
		}
	}
	
	for command in commands {
		if supportedCommands.contains(command) {
			// Apply cmd to buffer
			drawCommand()
			// Update cmd and continue
			cmd = command
		} else {
			// Command either coordinate string or just unsupported/error
			if let coords = CGPoint(string: command) {
				pointsBuffer.append(coords)
			}
		}
	}
	// For cmd not nil and non empty buffer at end:
	drawCommand()
	return path
}

extension CAShapeLayer {
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
		self.fillColor = fillValue == "none" ? nil : CGColor.fromHex(hex: fillValue)
		
		let strokeWidth = Double(commandsDict["stroke-width"] ?! "0" 		~> "\(#function), stroke-width in \(pathStyle) unrecognized.")
		self.lineWidth = strokeWidth ?! 0 									~> "\(#function), stroke-width in \(pathStyle) unrecognized as Double."
		
		// If no stroke, assume same color as fill:
		let strokeValue = commandsDict["stroke"] ?! "none" 					~> "\(#function), stroke in \(pathStyle) unrecognized."
		self.strokeColor = strokeValue == "none" ? self.fillColor : CGColor.fromHex(hex: strokeValue)
	}
}

// Extension to convert hex color string to CGColor
extension CGColor {
	static func fromHex(hex: String) -> CGColor? {
		
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
