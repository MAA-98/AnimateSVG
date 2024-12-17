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

// An older version of the function, CURRENTLY IN USE
func oldConvertPath(_ pathAttribute: String) -> CGPath {

	let commands = pathAttribute.split(separator: " ").map { String($0) }
	let supportedCommands = ["M", "m", "C", "c", "L", "l", "Z", "z"]
	let path = CGMutablePath()
	
	var pointsBuffer: [CGPoint] = []
	var cmd: String? = nil
	var firstPoint: CGPoint? = nil
	
	for (index, command) in commands.enumerated() {
		
		// Check on command first, if a new command or is the last command then go into switch
		if supportedCommands.contains(command) || index == commands.count - 1 {
			// If last command is a coordinate, need to add to buffer
			if index == commands.count - 1 {
				if let coords = CGPoint(string: command) {
					pointsBuffer.append(coords)
				}
			}
			if cmd == nil {
				cmd = command
				continue
				// Note if last command, not supported, and cmd is nil then there's no issue setting cmd as command
			} else {
				// Need to apply cmd to buffer
				switch cmd {
				case "M":
					// If firstPoint is nil then update
					if firstPoint == nil {
						firstPoint = pointsBuffer.first
					}
					path.move(to: pointsBuffer.removeFirst())
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
					path.move(to: pointsBuffer.removeFirst())
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
					path.addLine(to: firstPoint!) // Draw a line back to the first point
				default:
					// Not ever accessed
					print("Unknown or unsupported command: \(cmd!)")
				}
				// Update cmd and continue
				cmd = command
				// Deal with when command is last in commands
				if cmd == "Z" || cmd == "z" {
					path.addLine(to: firstPoint!)
				}
			}
		} else {
			// Command either coordinate string or just unsupported/error
			if let coords = CGPoint(string: command) {
				pointsBuffer.append(coords)
			}
		}
	}
	return path
}

// An older version of the function, CURRENTLY UPDATING
func old2ConvertPath(_ pathAttribute: String) -> CGPath {

	let commands = pathAttribute.split(separator: " ").map { String($0) }
	let supportedCommands = ["M", "m", "C", "c", "L", "l", "Z", "z"]
	let path = CGMutablePath()
	
	var pointsBuffer: [CGPoint] = []
	var cmd: String? = nil
	var firstPoint: CGPoint? = nil
	
	// To do later: add HhVv commands
	func drawCommand(_ command: String) {
		switch cmd {
		case "M":
			// If firstPoint is nil then update
			if firstPoint == nil {
				firstPoint = pointsBuffer.first
			}
			path.move(to: pointsBuffer.removeFirst())
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
			path.move(to: pointsBuffer.removeFirst())
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
			path.addLine(to: firstPoint!)
		default:
			// Not ever accessed
			print("\(#function), Unknown or unsupported command: \(cmd!)")
		}
	}
	
	for command in commands {
		if supportedCommands.contains(command) {
			if let comm = cmd {
				// Apply cmd to buffer
				drawCommand(comm)
			} else {
				// Clear any possible points added before valid command
				pointsBuffer.removeAll()
			}
			// Update cmd and continue
			cmd = command
		} else {
			// Command either coordinate string or just unsupported/error
			if let coords = CGPoint(string: command) {
				pointsBuffer.append(coords)
			}
		}
	}
	
	// If finished loop with non-empty buffer then need to draw finally
	if let comm = cmd {
		drawCommand(comm)
	} else {
		print("\(#function), \(pathAttribute) has no recognized commands.")
	}
	
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
		if cmd == nil && ["M", "m", "C", "c", "L", "l", "Z", "z"].contains(command) {
			cmd = command
		} else {
			if let coords = CGPoint(string: command), cmd != nil{
				if Character(cmd!).isLowercase {
					if pathPoints.isEmpty {
						pathPoints.append(coords)
					} else {
						pathPoints.append(pathPoints.last!.applying(CGAffineTransform(translationX: coords.x, y: coords.y)))
					}
				} else {
					pathPoints.append(coords)
				}
			} else {
				if ["M", "m", "C", "c", "L", "l", "Z", "z"].contains(command) {
					cmd = command
				}
			}
		}
	}
	return pathPoints
}
