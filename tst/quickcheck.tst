gap> LoadPackage("quickcheck", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> QC_CheckEqual([IsPermGroup, IsPermGroup], Intersection, 
> {g1,g2} -> GB_SimpleSearch(PartitionStack(lmp(g1,g2)), 
>           [GB_Con.InGroup(g1), GB_Con.InGroup(g2)]));
true
gap> QC_CheckEqual([IsPermGroup, IsPermGroup], Intersection, 
> {g1,g2} -> GB_SimpleSearch(PartitionStack(lmp(g1,g2)), 
>           [GB_Con.InGroup(g1), GB_Con.InGroup(g2)],
>           rec(consolidator := GB_MakeEquitableWeak)));
true
gap> QC_CheckEqual([IsPermGroup, IsPermGroup], Intersection, 
> {g1,g2} -> GB_SimpleSearch(PartitionStack(lmp(g1,g2)), 
>           [GB_Con.InGroup(g1), GB_Con.InGroup(g2)],
>           rec(consolidator := GB_MakeEquitableFull)));
true
gap> QC_CheckEqual([IsPermGroup, QC_SetOf(IsPosInt)], {g,s} -> Stabilizer(g,s,OnSets), 
> function(g,s)
>  local maxpnt;
>  maxpnt := Maximum(LargestMovedPoint(g), Maximum(s));
>  return GB_SimpleSearch(PartitionStack(maxpnt), 
>           [GB_Con.InGroup(g), BTKit_Con.SetStab(s)]);
>  end);
true
