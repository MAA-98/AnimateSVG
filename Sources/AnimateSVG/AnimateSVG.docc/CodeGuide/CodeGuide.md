# Code Guide

Guide to the codebase.

For ease of explanation, animation using a skeleton is explained only. The case without a skeleton should be an obvious special case where the skeleton is `nil`. This guide will present the framework in a decreasing level of abstraction.

## API

### SVGLayer

The central part of the API is the ``SVGLayer``. To initialize, it requires the `URL` of the SVG file to be animated, and the root node ``Joint`` of the tree that is the skeleton structure. To actually load the SVG as an animatable layer, the ``SVGLayer/loadLayer(completion:)`` method is called with a required closure to be applied when the SVG parsing is done:

(TO DO IMAGE)

### Joint

Skeleton structure is given by a DAG with a source `Joint` being the input. The joint is (EXPLAIN LATER, BUT STILL IMPROVING THIS PART)

The `skeletonStructure` as illustrated:

![Skeleton](skeleton)

is the public example ``ExampleSkeletonStructure``.
