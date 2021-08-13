gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktracking", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> QC_Check([IsPermGroup, IsPermGroup], 
> function(g1,g2)
>   local conj, m, p;
>   m := lmp(g1,g2);
>   p := Random(g1);
>   conj := GB_SimpleSinglePermSearch(PartitionStack(m),
>          [BTKit_Con.InGroup(g1), GB_Con.GroupConjugacySimple2(g2, g2^p)]);
>  if conj=fail or g2^conj <> g2^p then
>    return StringFormatted("In {}, expected {}^{}={} but got {}^{}",g1,g2,p,g2^p,g2,conj);
>  fi;
>  return true;
> end);
true