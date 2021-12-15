#
# GraphBacktracking: A simple but slow implementation of graph backtracking
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "GraphBacktracking", false );

TestDirectory(DirectoriesPackageLibrary( "GraphBacktracking", "tst" ),
  rec(exitGAP := true));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
