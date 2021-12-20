gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktracking", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> QC_Check([IsPermGroup, IsPermGroup], 
> function(g1,g2)
>   local norm1, norm2, m;
>   m := lmp(g1,g2);
>   norm1 := Normaliser(g1, g2);
>   norm2 := GB_SimpleSearch(PartitionStack(m),
>          [BTKit_Refiner.InGroup(g1), GB_Con.NormaliserSimple(g2)]);
>  if norm1 <> norm2 then
>    return StringFormatted("Expected {}, got {}, from {},{}",norm1,norm2,g1,g2);
>  fi;
>  return true;
> end);
true
