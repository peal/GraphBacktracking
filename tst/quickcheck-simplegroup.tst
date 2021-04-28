gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktracking", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> QC_Check([IsPermGroup, IsPermGroup, ], 
> function(g1,g2)
>   local rc1,rc2,m,inter,g;
>   inter := Intersection(g1,g2);
>   m := lmp(g1,g2);
>   g := GB_SimpleSearch(PartitionStack(m),
>          [GB_Con.InGroupSimple(m, g1), GB_Con.InGroupSimple(m, g2)]);
>  if g <> inter then
>    return StringFormatted("Expected {} intersection {} = {}, got {}",g1,g2,inter,g);
>  fi;
>  return true;
> end);
true
