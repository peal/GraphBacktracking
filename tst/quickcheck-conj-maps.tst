# Conjugacy refiners for transformations and partial permutations: the stabiliser
# (under conjugation, OnPoints) found by the refiner must equal GAP's Stabilizer.
gap> LoadPackage("quickcheck", false);;
gap> LoadPackage("graphbacktracking", false);;

# Transformations (randomised, using QuickCheck's IsTransformation generator).
gap> QC_CheckEqual([IsPermGroup, IsTransformation],
>   {g, t} -> Stabilizer(g, t, OnPoints),
>   function(g, t)
>     local m;
>     m := Maximum(LargestMovedPoint(g), DegreeOfTransformation(t), 2);
>     return GB_SimpleSearch(PartitionStack(m),
>              [GB_Con.InGroup(g), GB_Con.TransformationConjugacy(t, t)]);
>   end);
true

# Partial permutations (no QuickCheck generator, so a fixed sample). Covers a
# fixed point in the domain (a loop), a 2-cycle, and points outside the domain.
gap> ForAll(Cartesian(
>      [SymmetricGroup(4), Group((1, 2, 3, 4)), Group([(1, 2), (3, 4)])],
>      [PartialPerm([1, 2], [2, 3]), PartialPerm([1, 3], [3, 1]),
>       PartialPerm([2], [2]), PartialPerm([1, 2, 3], [2, 3, 4])]),
>    function(gp)
>      local g, p, m;
>      g := gp[1]; p := gp[2];
>      m := Maximum(LargestMovedPoint(g), DegreeOfPartialPerm(p),
>                   CodegreeOfPartialPerm(p), 2);
>      return GB_SimpleSearch(PartitionStack(m),
>               [GB_Con.InGroup(g), GB_Con.PartialPermConjugacy(p, p)])
>           = Stabilizer(g, p, OnPoints);
>    end);
true

# Partial permutations (randomised, using QuickCheck's IsPartialPerm generator).
gap> QC_CheckEqual([IsPermGroup, IsPartialPerm],
>   {g, p} -> Stabilizer(g, p, OnPoints),
>   function(g, p)
>     local m;
>     m := Maximum(LargestMovedPoint(g), DegreeOfPartialPerm(p),
>                  CodegreeOfPartialPerm(p), 2);
>     return GB_SimpleSearch(PartitionStack(m),
>              [GB_Con.InGroup(g), GB_Con.PartialPermConjugacy(p, p)]);
>   end);
true

# Transporter form: a found conjugator must actually map the map to its conjugate.
gap> QC_Check([IsPermGroup, IsTransformation],
>   function(g, t)
>     local m, p, conj;
>     m := Maximum(LargestMovedPoint(g), DegreeOfTransformation(t), 2);
>     p := Random(g);
>     conj := GB_SimpleSinglePermSearch(PartitionStack(m),
>               [GB_Con.InGroup(g), GB_Con.TransformationConjugacy(t, t ^ p)]);
>     if conj = fail or t ^ conj <> t ^ p then
>       return StringFormatted("expected {}^{} = {}, got conjugator {}",
>                              t, p, t ^ p, conj);
>     fi;
>     return true;
>   end);
true

# Transporter form for partial permutations: a found conjugator must actually map
# p to its g-conjugate p ^ c.
gap> QC_Check([IsPermGroup, IsPartialPerm],
>   function(g, p)
>     local m, c, conj;
>     m := Maximum(LargestMovedPoint(g), DegreeOfPartialPerm(p),
>                  CodegreeOfPartialPerm(p), 2);
>     c := Random(g);
>     conj := GB_SimpleSinglePermSearch(PartitionStack(m),
>               [GB_Con.InGroup(g), GB_Con.PartialPermConjugacy(p, p ^ c)]);
>     if conj = fail or p ^ conj <> p ^ c then
>       return StringFormatted("expected {}^{} = {}, got conjugator {}",
>                              p, c, p ^ c, conj);
>     fi;
>     return true;
>   end);
true
