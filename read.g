#
# GraphBacktracking: A simple but slow implementation of graph backtracking
#
# Reading the implementation part of the package.
#


# Private methods of package
_GB := AtomicRecord(rec());

if not IsBound(_BT_SKIP_INTERFACE) then
    ReadPackage( "GraphBacktracking", "gap/GraphBacktracking.gi");
fi;

ReadPackage( "GraphBacktracking", "gap/Equitable.gi");
ReadPackage( "GraphBacktracking", "gap/constraints/simpleconstraints.g");
ReadPackage( "GraphBacktracking", "gap/constraints/normaliser.g");
ReadPackage( "GraphBacktracking", "gap/constraints/canonicalconstraints.g");
ReadPackage( "GraphBacktracking", "gap/constraints/conjugacy.g");
ReadPackage( "GraphBacktracking", "gap/constraints/digraphs.g");
ReadPackage( "GraphBacktracking", "gap/refiners.gi");

Perform(["GB_Con", "_GB"],
        SetNamesForFunctionsInRecord);
