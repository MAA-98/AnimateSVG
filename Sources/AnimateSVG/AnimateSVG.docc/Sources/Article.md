## API

Supported SVG files have a limited structure that allows the framework to interpret it as animatable. The library can be used to automatically create an animation of a character, with only data to rotate the limbs being needed for a performant and resolution-independent skeleton animation. The library is intended for, but not limited to, the modern SwiftUI framework.

// ADD IMAGE (HIGH LEVEL OVERVIEW) --------------------------------WAIT TO IMPROVE IMPLEMENTATION ----------------------------------------------------

The library parses the SVG data of a file, creates Core Graphics paths for each group in the SVG and displays them on Core Animation layers. If given a skeleton structure as an input in the API and the SVG having a designated path of the skeleton joints, then the Core Animation layers are automatically built up as given by the skeleton structure and the corresponding CGPaths are displayed attached to the layers for seamless animation.

### SwiftUI Integration

The recommended way to access the framework is through the dedicated SwiftUI Views:

```Swift
// TO DO
```

// TO DO
The view, with no further inputs, will display the SVG as a resolution independent image scaled to the size of the frame. Therefore, this library can be used as an SVG to Core Graphics renderer also.

### If you prefer UIKit View

// TO DO

## Possible Improvements for Later

### High priority:

- Add to supported commands: v,V, h, H for example
- add sizing functionality, size changing with View size with different aspect change options

### Medium priority:

- clean up PathConverter.swift

### Low priority:

- A concurrent method of building the skeleton of CALayers and drawing the paths on the layers.
