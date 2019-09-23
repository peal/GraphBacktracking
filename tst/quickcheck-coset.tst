gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktrack", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> List([GB_MakeEquitableNone, GB_MakeEquitableWeak, GB_MakeEquitableStrong, GB_MakeEquitableFull], consol ->
> QC_Check([IsPermGroup, IsPerm], 
> function(g1,p1)
>   local rc1,m,p;
>   rc1 := RightCoset(g1,p1);
>   m := lmp(g1,p1);
>   p := GB_SimpleAllPermSearch(PartitionStack(m),
>          [GB_Con.InCoset(m, g1, p1)],rec(consolidator := consol));
>   if Set(rc1) <> Set(p) then
>    return StringFormatted("Expected {}, got {}", Set(rc1), Set(p));
>   fi;
>   return true;
> end));
[ true, true, true, true ]
gap> List([GB_MakeEquitableNone, GB_MakeEquitableWeak, GB_MakeEquitableStrong, GB_MakeEquitableFull], consol ->
> QC_Check([IsPermGroup, IsPerm, IsPermGroup, IsPerm], 
> function(g1,p1,g2,p2)
>   local rc1,rc2,m,inter,p;
>   rc1 := RightCoset(g1,p1);
>   rc2 := RightCoset(g2,p2);
>   inter := Intersection(rc1,rc2);
>   m := lmp(g1,g2,p1,p2);
>   p := GB_SimpleSinglePermSearch(PartitionStack(m),
>          [GB_Con.InCoset(m, g1, p1), GB_Con.InCoset(m, g2, p2)],rec(consolidator := GB_MakeEquitableNone));
>  if inter = [] then
>    if p <> fail then return StringFormatted("Expected nothing, got {}",p); fi;
>  else
>    if not p in inter then return StringFormatted("Expected coset, got {}",p); fi;
>  fi;
>  return true;
> end));
[ true, true, true, true ]
