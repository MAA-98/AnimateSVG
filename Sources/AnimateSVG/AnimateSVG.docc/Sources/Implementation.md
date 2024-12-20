# Implementation

Mid-level overview of how the framework works.

### Interpreting SVG Paths

Every SVG path with attributes `"d"` and `"style"` creates a CAShapeLayer:

![PathConverter.swift](PathConverter.swift.png)

The `"id"` attribute of the path sets the `name` of the CAShapeLayer, and if the path has a `"transform"` attribute, an analogous transformation is added to the CAShapeLayer.

> Warning: Only CSS style instructions are parsed, and only the style attributes fill, stroke color and stroke width are currently used.

*Possible future improvements:*
- *Add path commands v, V, h, H,*
- *Add more style attributes which have analogies in CGPath*
- *Add non-CSS style commands, which overwrite any CSS style commands.*

### Parsing SVG

Parsing is done using an implementation of Foundation's [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser/) with [InputStream](https://developer.apple.com/documentation/foundation/inputstream/). 

The main CALayer is built with a buffered series of instructions:

![SVGParsing](SVGParsing.swift.png)

*Possible future improvements: Implement concurrent method of loading layers.*

### Parsing SVG with Skeleton



### Displaying SwiftUI View

To display the animation as a SwiftUI View, we use a UIViewRepresentable to have UIKit intermediate between SwiftUI and Core Animation, which is required since there's no official dedicated View for Core Animations in SwiftUI. There is a View for SpriteKit scenes, but SpriteKit has less functionality and low level control than Core Animation.

<img src="Resources/ToSwiftUI.swift.png" width="910" height="520">

