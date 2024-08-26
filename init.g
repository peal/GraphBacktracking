#
# GraphBacktracking: A simple but slow implementation of graph backtracking
#
# Reading the declaration part of the package.
#


if not IsBound(_BT_SKIP_INTERFACE) and not IsBound(_BTKit.InitInterfaceGB) then
    _BTKit.InitInterfaceGB := true;
    ReadPackage( "GraphBacktracking", "gap/interface.gd");
fi;

if not IsBound(_BTKit.FilesInitGB) then
    _BTKit.FilesInitGB := true;
    ReadPackage( "GraphBacktracking", "gap/GraphBacktracking.gd");
    ReadPackage( "GraphBacktracking", "gap/Equitable.gd");
fi;
