# Implementation Overview

Mid-level overview of how the framework is implemented.

### Interpreting SVG paths



### Parsing SVG

Parsing is done using an implementation of Foundation's XMLParser with InputStream. This is written in SVGParsing.swift and the methods of drawing the CGPaths are in PathConverter.swift.

By default, the main CALayer is built with a buffered series of instructions:

<img src="Resources/SVGParsing.swift.png" width="900" height="330">

### Displaying SwiftUI View

To display the animation as a SwiftUI View, we use a UIViewRepresentable to have UIKit intermediate between SwiftUI and Core Animation, which is required since there's no official dedicated View for Core Animations in SwiftUI. There is a View for SpriteKit scenes, but SpriteKit has less functionality and low level control than Core Animation.

<img src="Resources/ToSwiftUI.swift.png" width="910" height="520">

