gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktrack", false);;
gap> lmp := {l...} -> Maximum(1,Maximum(List(l, LargestMovedPoint)));;
gap> List([GB_MakeEquitableNone, GB_MakeEquitableWeak, GB_MakeEquitableStrong, GB_MakeEquitableFull], consol ->
> QC_Check([IsPermGroup, IsPerm, QC_SetOf(IsPosInt), QC_SetOf(IsPosInt)], 
> function(g1,p1, l1, l2)
>   local rc1,m,p, check, ans;
>   rc1 := RightCoset(g1,p1);
>   m := Maximum(Flat([lmp(g1,p1), l1, l2]));
>   p := GB_SimpleSinglePermSearch(PartitionStack(m),
>          [GB_Con.InCoset(g1, p1), BTKit_Con.SetTransporter(l1, l2)],rec(consolidator := consol));
>   check := GB_CheckInitialCoset(PartitionStack(m),
>          [GB_Con.InCoset(g1, p1), BTKit_Con.SetTransporter(l1, l2)]);
>   if p <> fail then
>     if OnSets(l1, p) <> l2 or not (p in rc1) then
>       return StringFormatted("Got false answer: {},{},{},{},{}",g1,p1,l1,l2,p);
>     fi;
>   else
>     ans := First(rc1, p -> OnSets(l1, p) = l2);
>     if ans <> fail then
>       return StringFormatted("Failed to find answer: {},{},{},{},{}",g1,p1,l1,l2,ans);
>     fi;
>   fi;
>   if check.equal = false and p <> fail then
>     return StringFormatted("Failed CheckInitialCoset: {},{},{},{},{},{}",g1,p1,l1,l2,check,p);
>   fi;
>   return true;
> end));
[ true, true, true, true ]
