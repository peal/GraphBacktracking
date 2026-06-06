#
# GraphBacktracking: A simple but slow implementation of graph backtracking
#
# This file is a script which compiles the package manual.
#
if fail = LoadPackage("AutoDoc", "2018.02.14") then
    Error("AutoDoc version 2018.02.14 or newer is required.");
fi;

# Load the package (and hence BacktrackKit) so that cross-references into
# the BacktrackKit manual resolve.
if fail = LoadPackage("GraphBacktracking") then
    Error("GraphBacktracking could not be loaded.");
fi;

# The chapters all come from AutoDoc comments; listing the source files
# explicitly fixes the order in which the chapters appear in the manual.
AutoDoc( rec(
    autodoc := rec(
        files := [
            "gap/GraphBacktracking.gd",  # Introduction, Executing a search
            "gap/interface.gd",          # Executing a search, Refiners
            "gap/Equitable.gd",          # Equitable Graphs
        ],
    ),
    scaffold := true,
) );
