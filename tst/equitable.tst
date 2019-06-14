gap> LoadPackage("graphbacktracking", false);
true
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := [CycleDigraph(6)];;
gap> r := RecordingTracer();;
gap> GB_MakeEquitableWeak(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> f := {x} -> (x=3);
function( x ) ... end
gap> PS_SplitCellsByFunction(ps, r, f);;
gap> PS_AsPartition(ps);
[ [ 3 ], [ 1, 2, 4, 5, 6 ] ]
gap> GB_MakeEquitableWeak(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 3 ], [ 2 ], [ 4 ], [ 1 ], [ 5 ], [ 6 ] ]

#
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := OrbitalGraphs(DihedralGroup(IsPermGroup, 12));;
gap> GB_MakeEquitableWeak(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> f := {x} -> (x=3);
function( x ) ... end
gap> PS_SplitCellsByFunction(ps, r, f);;
gap> GB_MakeEquitableWeak(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 3 ], [ 1, 5 ], [ 6 ], [ 2, 4 ] ]
gap> GB_MakeEquitableStrong(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 3 ], [ 1, 5 ], [ 6 ], [ 2, 4 ] ]

#
gap> ps := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> g := Concatenation(OrbitalGraphs(Group((1,2,3,4,5,6))), OrbitalGraphs(Group((1,2,4,3,5,6))));;
gap> GB_MakeEquitableWeak(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> GB_MakeEquitableStrong(ps, r, g);
gap> PS_AsPartition(ps);
[ [ 1 ], [ 3 ], [ 4 ], [ 2 ], [ 6 ], [ 5 ] ]
