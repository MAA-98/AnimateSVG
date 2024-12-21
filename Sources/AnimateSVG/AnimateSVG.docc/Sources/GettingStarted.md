# Getting Started


## Skeleton Rigging

Supported SVG files have a limited structure that allows the framework to interpret it as animatable. The library can be used to automatically create an animation of a character, with only data to rotate the limbs being needed for a performant and resolution-independent skeleton animation. 

When wanting to create a skeleton rigging of an SVG, there have to be three additional pieces of information provided: The skeleton tree-graph structure, which gives the 'bone' relationships for the rig, and positions of the joints to be attached, each components corresponding joint.

The skeleton given can be as detailed as one would like, although more detailed than is necessary for the SVG drawing is useless. If animation directions will be provided from motion capture technology, then that will give the appropriate skeleton. An example of a skeleton from some motion capture technology:

![Skeleton](skeleton)
