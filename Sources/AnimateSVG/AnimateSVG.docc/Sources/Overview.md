# ``AnimateSVG``

Render SVG files as native Core Graphics components. Animate an SVG, with optional skeleton rigging, using Core Animation.

## Overview

Build the animations with just an SVG and instructions how to move each group. The SVG files are quickly parsed, so can be used to load in real-time, and the animation is performant with high frame rate and resolution independence.

The main functionalities of the library:

- Parse SVG document from URL, with the [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser/),
- Interpret SVG path's drawing commands as [CGPaths](https://developer.apple.com/documentation/coregraphics/cgmutablepath),
- Interpret SVG path's style commands with the CGPaths to create [CAShapeLayers](https://developer.apple.com/documentation/quartzcore/cashapelayer/),
- Interpret SVG groups of paths as [CALayers](https://developer.apple.com/documentation/quartzcore/calayer),
- Animate layers manually, or provide a skeleton structure and a skeleton drawing in the SVG for the framework to organize the CALayers by,
- Display animation in a SwiftUI View.

The framework has no dependencies, other than the standard libraries.

## Contents

- [Getting Started](Sources/GettingStarted)
- [API Reference](Sources/APIReference)
- [Implementation Overview](Sources/ImplementationOverview)

