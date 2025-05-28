[![Build Status](https://github.com/peal/GraphBacktracking/workflows/CI/badge.svg?branch=master)](https://github.com/peal/GraphBacktracking/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Coverage](https://codecov.io/github/peal/GraphBacktracking/coverage.svg?branch=master&token=)](https://codecov.io/gh/peal/GraphBacktracking)

# The GAP package GraphBacktracking

This package provides an implementation of the graph backtracking algorithm, as described in the paper [Computing canonical images in permutation groups with Graph Backtracking](https://arxiv.org/abs/2209.02534) by Christopher Jefferson, Rebecca Waldecker, and Wilf A. Wilson. It extends the **BacktrackKit** package to support graph backtracking.

This algorithm can be used to perform calculations in permutation groups, such as:
* Group and coset intersection
* Finding canonical images of combinatorial structures in any permutation group

This package is intended for learning and exploring the graph backtracking algorithm. The performance is **extremely poor**. For a modern, high-performance version of this algorithm, please see the [**vole**](https://github.com/peal/vole) package.

`GraphBacktracking` requires GAP version >= 4.13.0, and recent versions of the following packages (see the `PackageInfo.g` file for specific versions):
* BacktrackKit
* datastructures
* digraphs
* images
* primgrp

Additionally, [the QuickCheck package](https://github.com/ChrisJefferson/QuickCheck) is required to run all of the tests.

## Contact

This package is a work in progress, both in terms of code and documentation.

If you have any issues or questions about this package, please post an issue at https://github.com/peal/GraphBacktracking/issues
