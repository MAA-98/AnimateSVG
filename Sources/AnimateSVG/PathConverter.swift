///  PathConverter.swift

import Foundation
import CoreGraphics
import QuartzCore

/// Function: Initializer creating a point from a coordinate string that contains two comma-separated values, representing the x and y coordinates.
/// Example: `CGPoint(string: "1.2,3")` returns the same value as `GCPoint(x: 1.2, y: 3.0)`.
/// Error Handling: If splitting doesn't give two elements then an error is printed but parsing continues.
/// 	If the split string is not parsed into two `Double` values, ingoring nil, the initializer will return `nil` value and print error.
extension CGPoint{
	init?(string: String) {
		
		let coordsSplit = string.split(separator: ",")
			
		if coordsSplit.count != 2 {
			print("Non-critical Non-nil Error: Error for input \(string): \(coordsSplit) does not have two elements.")
		}
		
		let coords = coordsSplit.compactMap{Double($0)}
		
		if coords.count == 2 {
			let x = coords[0]
			let y = coords[1]
			self.init(x: x, y: y)
		} else {
			print("Non-critical Nil Error: Error for input \(string): \(coords) does not have two elements.")
			return nil
		}
	}
}

// Mutate a CGPath by adding path command from an SVG "d" attribute
extension CGMutablePath {
	
	func addSVGCommand(_ command: Character, buffer: [CGPoint]) -> (Void) {
		
		let CapitalCommandDict: [Character : ([CGPoint]) -> (Void)] = [
			"L" : { pointsBuffer in
				self.addLines(between: pointsBuffer)
			},
			"M" : { pointsBuffer in
				guard let firstPoint = pointsBuffer.first else { return }
				self.move(to: firstPoint)
				self.addLines(between: Array(pointsBuffer.dropFirst()))
			},
			"C" : { pointsBuffer in
				var pointsBuffer = pointsBuffer
				while pointsBuffer.count >= 3 {
					let control1 = pointsBuffer.removeFirst()
					let control2 = pointsBuffer.removeFirst()
					let endPoint = pointsBuffer.removeFirst()
					self.addCurve(to: endPoint, control1: control1, control2: control2)
				}
			}
		]
		
		var newBuffer = buffer
		var command = command
		if command.isLowercase {
			command = command.uppercased().first!
			if CapitalCommandDict.keys.contains(command) {
				if !self.isEmpty {
					newBuffer[0] = self.currentPoint.applying(CGAffineTransform(translationX: newBuffer[0].x, y: newBuffer[0].y))
				} // Without this, there's a mistake: it's not that simple M 10,10 l -10,-10 should give a diagonal line to origin, but will give diagonal twice as long PAST the origin
				for index in 1..<newBuffer.count {
					let translationPoint = buffer[index]
					newBuffer[index] = newBuffer[index - 1].applying(CGAffineTransform(translationX: translationPoint.x, y: translationPoint.y))
					
				}
			} else {
				print("Unsupported command \(command).")
			}
		}
		print("newBuffer \(newBuffer) and command \(command)")
		CapitalCommandDict[command]!(newBuffer)
	}
}

// IS WRONG AND NOT FIXED
func convertPath(_ pathAttribute: String) -> CGPath {

	let commands = pathAttribute.split(separator: " ").map { String($0) }
	let supportedCommands = ["L", "l", "M", "m", "C", "c", "Z", "z"]

	var cmd: Character? = nil
	var pointsBuffer: [CGPoint] = []
	var firstPoint: CGPoint? = nil
	let path = CGMutablePath()
	
	print(pathAttribute)
	for (index, command) in commands.enumerated() {
		
		if supportedCommands.contains(command) {
			print(command, pointsBuffer)
			let command = Character(command)
			print(command)
			print(cmd)
			if cmd != nil {
				path.addSVGCommand(cmd!, buffer: pointsBuffer)
				print(path.currentPoint)
			}
			pointsBuffer.removeAll()
			cmd = command
			if command.lowercased() == "z" {
				// Draw path so far and get back
				path.addLine(to: firstPoint!) // Draw a line back to the first point
			}
		} else {
			let coords = CGPoint(string: command)
			if coords != nil {
				if firstPoint == nil {
					firstPoint = coords
				}
				pointsBuffer.append(coords!)
			} else {
				print("Unsupported command \(command)")
			}
			if index == commands.count - 1 {
				path.addSVGCommand(cmd!, buffer: pointsBuffer)
			}
		}
	}
	return path
}


func addPathStyle(path: CGPath, pathStyle: String) -> CAShapeLayer {
	let supportedCommands = ["fill", "stroke", "stroke-width"]
	// Creating dict of styles
	let commandsList = pathStyle.split(separator: ";").map { String($0) }
	let commandsDict = commandsList.reduce(into: [String : String]()) { dict, string in
		let components = string.split(separator: ":", maxSplits: 1).map { String($0) }
		if supportedCommands.contains(components[0]) {
			let key = String(components[0])
			let value = String(components[1])
			dict[key] = value
		}
	}
	let shapeLayer = CAShapeLayer()
	shapeLayer.path = path
	
	if let fillValue = commandsDict["fill"] {
		if fillValue == "none" {
			shapeLayer.fillColor = nil
		} else {
			shapeLayer.fillColor = CGColor.fromHex(hex: fillValue)! // Getting error here!?!?!?!?
		}
		// If there's stroke width, but no stroke (or stroke:none), then assume same color as fill:
		if let strokeWidth = Double(commandsDict["stroke-width"]!) {
			shapeLayer.lineWidth = strokeWidth
			if let strokeValue = commandsDict["stroke"], strokeValue != "none"{
				shapeLayer.strokeColor = CGColor.fromHex(hex: strokeValue)!
			} else {
				shapeLayer.strokeColor = shapeLayer.fillColor
			}
		}
	}
	return shapeLayer
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
		} else if hexString.count == 8 { // ARGB
			return CGColor(
				red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
				green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
				blue: CGFloat(rgb & 0xFF) / 255.0,
				alpha: CGFloat((rgb >> 24) & 0xFF) / 255.0
			)
		} else {
			return nil // Invalid hex string
		}
	}
}

// An older version of the function, CURRENTLY IN USE
func oldConvertPath(_ pathAttribute: String) -> CGPath {

	let commands = pathAttribute.split(separator: " ").map { String($0) }
	let supportedCommands = ["M", "m", "C", "c", "L", "l", "Z", "z"]
	var cmd: String? = nil
	
	let path = CGMutablePath()
	var pointsBuffer: [CGPoint] = []
	var firstPoint: CGPoint? = nil
	
	for (index, command) in commands.enumerated() {
		// Check on command first
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
			// Otherwise command just ignored
		}
	}
	return path
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
