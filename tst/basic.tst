gap> LoadPackage("GraphBacktracking", false);;
gap> ps3 := PartitionStack(3);
[ [ 1, 2, 3 ] ]
gap> ps4 := PartitionStack(4);
[ [ 1, 2, 3, 4 ] ]
gap> ps6 := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> Set(GB_SimpleSearch(ps3, [GB_Con.InGroup(3, SymmetricGroup(3))]));
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> Set(GB_SimpleSearch(ps4, [GB_Con.InGroup(4, Group((1,2)(3,4)))]));
[ (), (1,2)(3,4) ]
gap> Set(GB_SimpleSearch(ps6, [GB_Con.InGroup(6, AlternatingGroup(6)), GB_Con.SetStab(6,[2,4,6]), GB_Con.TupleStab(6,[1,2]) ]));
[ (), (3,5)(4,6) ]
gap> Set(GB_SimpleSearch(ps6, [GB_Con.InGroup(6, Group((1,2,3,4,5,6))), GB_Con.InGroup(6, Group((1,2,4,3,5,6))) ]));
[ () ]

# Trivial intersection of two 'disjoint' C4 x C4 x C4 groups with equal orbits
# Involves no search
gap> g1 := Group([(1,2,3,4), (5,6,7,8), (9,10,11,12)]);;
gap> g2 := Group([(1,2,4,3), (5,6,8,7), (9,10,12,11)]);;
gap> Set(GB_SimpleSearch(PartitionStack(12),
>                        [GB_Con.InGroup(12, g1), GB_Con.InGroup(12, g2)]));
[ () ]

# Trivial intersection of two primitive groups in S_10 that does involve search
gap> LoadPackage("primgrp", false);;
gap> Set(GB_SimpleSearch(PartitionStack(10),
>                        [GB_Con.InGroup(10, PrimitiveGroup(10, 1)),
>                         GB_Con.InGroup(10, PrimitiveGroup(10, 3))]));
[ () ]
