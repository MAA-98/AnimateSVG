# Code Guide

Guide to the codebase.

For ease of explanation, animation using a skeleton is explained only. The case without a skeleton should be an obvious special case where the skeleton is `nil`. This guide will present the framework in a decreasing level of abstraction.

## AnimateSVG.swift

*Last updated: 08/01/2025*

### SVGLayer

The central part of the API is the ``SVGLayer``. To initialize, it requires the `URL` of the SVG file to be animated, and the root node ``Joint`` of the tree that is the skeleton structure. To actually load the SVG as an animatable layer, the ``SVGLayer/loadLayer(completion:)`` method is called with a required closure to be applied when the SVG parsing is done:

![SVGLayer](SVGLayer)

### Joint

Skeleton structure is given by a DAG with the root node `Joint` being the input. The joint is (EXPLAIN LATER, BUT STILL IMPROVING THIS PART)

The `skeletonStructure` as illustrated:

![Skeleton](skeleton)

is the `public` example ``ExampleSkeletonStructure``.

## ToSwiftUI.swift

*Last updated: 08/01/2025*

SwiftUI does not natively support Core Animation as a View, there is a View for SpriteKit scenes, but SpriteKit has less functionality and low level control than Core Animation, so we go around using UIKit with [UIViewRepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable/).

### AnimateSVGView

![ToSwiftUI.swift](ToSwiftUI.swift)
