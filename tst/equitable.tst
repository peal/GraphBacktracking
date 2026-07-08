gap> LoadPackage("graphbacktracking", false);
true
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := [CycleDigraph(6)];;
gap> r := RecordingTracer();;
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> f := {x} -> (x=3);
function( x ) ... end
gap> PS_SplitCellsByFunction(ps, r, f);;
gap> PS_AsPartition(ps);
[ [ 3 ], [ 1, 2, 4, 5, 6 ] ]
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 3 ], [ 2 ], [ 4 ], [ 1 ], [ 5 ], [ 6 ] ]

#
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := [Digraph([[2,3],[],[],[],[],[]])];;
gap> r := RecordingTracer();;
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 4, 5, 6 ], [ 1 ], [ 2, 3 ] ]

#
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := _BTKit.getOrbitalListWithOptions(DihedralGroup(IsPermGroup, 12), rec(maxval := 12, skipOneLarge := true, budgetMode := false));;
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> f := {x} -> (x=3);
function( x ) ... end
gap> PS_SplitCellsByFunction(ps, r, f);;
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 3 ], [ 2, 4 ], [ 1, 5 ], [ 6 ] ]
gap> GB_MakeEquitableStrong(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 3 ], [ 2, 4 ], [ 1, 5 ], [ 6 ] ]

#
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := Concatenation(_BTKit.getOrbitalListWithOptions(Group((1,2,3,4,5,6)), rec(maxval := 6, skipOneLarge := true, budgetMode := false)), _BTKit.getOrbitalListWithOptions(Group((1,2,4,3,5,6)), rec(maxval := 6, skipOneLarge := true, budgetMode := false)));;
gap> GB_MakeEquitableWeak(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> GB_MakeEquitableStrong(ps, r, g);
true
gap> PS_AsPartition(ps);
[ [ 1 ], [ 2 ], [ 4 ], [ 3 ], [ 5 ], [ 6 ] ]
