# ``AnimateSVG``

Render SVG files as native Core Graphics components. Animate an SVG, with optional skeleton rigging, using Core Animation.

## Overview

Display animations in your app with just an SVG and movement instructions. The SVG files are quickly parsed, so can be used to load in real-time, and the animation is performant with high frame rate and resolution independence.

The main functionalities of the library:

- Parse SVG document from URL, with the [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser/),
- Interpret SVG groups of paths as [CALayers](https://developer.apple.com/documentation/quartzcore/calayer) with [CGPaths](https://developer.apple.com/documentation/coregraphics/cgmutablepath),
- Animate layers manually or provide a skeleton structure and a skeleton drawing in the SVG for the framework to use it to build the CALayers structure,
- Display animation in a SwiftUI View.

The framework has no dependencies, beyond the standard libraries.

## Contents

<doc:UserGuide>

Instructions for using the API.


<doc:CodeGuide>

In-depth documentation of the implementation.

## Topics
