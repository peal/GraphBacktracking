gap> LoadPackage("GraphBacktracking", false);;
gap> ps3 := PartitionStack(3);
[ [ 1, 2, 3 ] ]
gap> ps4 := PartitionStack(4);
[ [ 1, 2, 3, 4 ] ]
gap> ps6 := PartitionStack(6);
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> SymmetricGroup(3) =
> GB_SimpleSearch(ps3, [GB_Con.InGroup(SymmetricGroup(3))]);
true
gap> Group((1,2)(3,4)) =
> GB_SimpleSearch(ps4, [GB_Con.InGroup(Group((1,2)(3,4)))]);
true
gap> Set(GB_SimpleSearch(ps6, [GB_Con.InGroup(AlternatingGroup(6)),
>                              BTKit_Con.SetStab([2, 4, 6]),
>                              BTKit_Con.TupleStab([1, 2])]));
[ (), (3,5)(4,6) ]
gap> IsTrivial(GB_SimpleSearch(ps6, [GB_Con.InGroup(Group((1,2,3,4,5,6))),
>                                    GB_Con.InGroup(Group((1,2,4,3,5,6)))]));
true
gap> DirectProduct(SymmetricGroup(3), SymmetricGroup(3)) =
>  GB_SimpleSearch(PartitionStack(6), [BTKit_Con.SetStab([1 .. 3])]);
true

# Trivial intersection of two 'disjoint' C4 x C4 x C4 groups with equal orbits
# Involves no search
gap> g1 := Group([(1,2,3,4), (5,6,7,8), (9,10,11,12)]);;
gap> g2 := Group([(1,2,4,3), (5,6,8,7), (9,10,12,11)]);;
gap> IsTrivial(GB_SimpleSearch(PartitionStack(12),
>                              [GB_Con.InGroup(g1),
>                               GB_Con.InGroup(g2)]));
true

# Trivial intersection of two primitive groups in S_10 that does involve search
gap> LoadPackage("primgrp", false);;
gap> IsTrivial(GB_SimpleSearch(PartitionStack(10),
>                              [GB_Con.InGroup(PrimitiveGroup(10, 1)),
>                               GB_Con.InGroup(PrimitiveGroup(10, 3))]));
true

# Set of digraphs: G = TransitiveGroup(6, 4) and o = OrbitalGraphs(G)
# Warning: currently too slow
#gap> G := Group([(1,2,3)(4,5,6), (1,4)(2,5)]);
#gap> o := Set(["&ECA@_OG", "&EQHcQHc", "&EHcQHcQ"], DigraphFromDigraph6String);
#gap> GB_SimpleSearch(PartitionStack(6), [GB_Con.SetDigraphs(o, o)])
#> = Normaliser(SymmetricGroup(6), G);
#true
#
# Set of digraphs: cycle digraph on 4 vertices and its reverse
gap> o := Set([CycleDigraph(4), DigraphReverse(CycleDigraph(4))]);;
gap> G := Group([(2,4), (1,2)(3,4)]);;
gap> GB_SimpleSearch(PartitionStack(4), [GB_Con.SetDigraphs(o, o)]) = G;
true
gap> p := OnSetsDigraphs(o, (3,4));;
gap> GB_SimpleSinglePermSearch(PartitionStack(4), [GB_Con.SetDigraphs(o, p)])
> * (3,4) in G;
true
