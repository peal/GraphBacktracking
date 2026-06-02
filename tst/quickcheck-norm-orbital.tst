gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktracking", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;

# Every orbital-graph normaliser refiner must compute N_{g1}(g2) correctly.
# The variants differ only in which graphs and deductions they push into the
# search, so on every input they must all agree with GAP's Normaliser.
gap> refiners := ["Orbital", "OrbitalRoot", "OrbitalNone", "OrbitalDeep",
>                 "OrbitalSmall", "OrbitalRegOrbit", "OrbitalRegOrbitChar"];;
gap> QC_Check([IsPermGroup, IsPermGroup],
> function(g1, g2)
>   local m, norm1, rn, norm2;
>   m := lmp(g1, g2);
>   norm1 := Normaliser(g1, g2);
>   for rn in refiners do
>     norm2 := GB_SimpleSearch(PartitionStack(m),
>            [BTKit_Refiner.InGroup(g1), GB_Con.(Concatenation("Normaliser", rn))(g2)]);
>     if norm1 <> norm2 then
>       return StringFormatted("Refiner {}: expected {}, got {}, from {},{}",
>                              rn, norm1, norm2, g1, g2);
>     fi;
>   od;
>   return true;
> end, rec(tests := 150, limit := 6));
true

# GroupConjugacyOrbital is the dispatch target for group transport under
# OnPoints; it must find a conjugating element exactly when one exists in g1.
gap> QC_Check([IsPermGroup, IsPermGroup, IsPermGroup],
> function(g1, g2, g3)
>   local conj, p, m;
>   m := lmp(g1, g2, g3);
>   conj := IsConjugate(g1, g2, g3);
>   p := GB_SimpleSinglePermSearch(PartitionStack(m),
>       [BTKit_Refiner.InGroup(g1), GB_Con.GroupConjugacyOrbital(g2, g3)]);
>  if conj then
>    if p = fail then return StringFormatted("Expected coset, got nothing"); fi;
>  else
>    if p <> fail then return StringFormatted("Expected nothing, got {}",p); fi;
>  fi;
>  return true;
> end, rec(tests := 200, limit := 6));
true
