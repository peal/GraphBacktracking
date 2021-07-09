
GB_Con.NormaliserSimple := function(n, group)
    local orbList,getOrbits, orbMap, pointMap, r, invperm,minperm;

    getOrbits := function(pointlist)
        local G,orbs,graph,cols, orb;
        Info(InfoGB, 1, "Normaliser for pointlist", pointlist);
        G := Stabilizer(group, pointlist, OnTuples);

        orbs := Orbits(G, [1..n]);
        
        orbs := Filtered(orbs, o -> Length(o)>1);
        
        if Length(orbs) = 0 then
            return [];
        fi;

        if Length(orbs) = 1 then
            orb := Immutable(Set(orbs[1]));
            return [{x} -> x in orb];
        fi;

        graph := ListWithIdenticalEntries(n, []);
        cols := ListWithIdenticalEntries(n, 0);
        Append(graph, orbs);
        Append(cols, List(orbs, {x} -> Length(x)));
        Info(InfoGB, 2, "Made graph: ", Digraph(graph));
        return [rec( graph := Digraph(graph), vertlabels := cols)];
    end;

    r := rec(
        name := "NormaliserSimple",
        largest_required_point := LargestMovedPoint(group),
        image := {p} -> group^p,
        result := {} -> group,
        check := {p} -> group=group^p,
        refine := rec(
            initialise := function(ps, buildingRBase)
                # Set 'seenDepth to -1 at the start. Note we always start searching at 'seenDepth + 1' which will be 0
                r!.btdata := rec(seenDepth := -1);
                return r!.refine.fixed(ps, buildingRBase);
            end,
            fixed := function(ps, buildingRBase)
                local fixedpoints, result;
                fixedpoints := PS_FixedPoints(ps);
                Assert(2, r!.btdata.seenDepth <= Length(fixedpoints));
                result := Concatenation(List([r!.btdata.seenDepth + 1..Length(fixedpoints)], x -> getOrbits(fixedpoints{[1..x]})));
                r!.btdata.seenDepth := Length(fixedpoints);
                return result;
            end)
        );
        return Objectify(GBRefinerType, r);
    end;

# A refiner based on Leon's Normaliser refiner
GB_Con.NormaliserSimple2 := function(n, group)
    local orbList,getOrbits, orbMap, pointMap, r, invperm,minperm;

    getOrbits := function(pointlist)
        local G,orbs,graph,cols, i, outlist;
        G := group;
        # Stop if the list is empty
        if IsEmpty(pointlist) then
            return [];
        fi;
        pointlist := Reversed(pointlist);
        # if the first point isn't moved, then we would just be repeating earlier work
        if ForAll(GeneratorsOfGroup(G), p -> pointlist[1]^p = pointlist[1]) then
            return [];
        fi;

        outlist := [];
        for i in pointlist do
            if ForAny(GeneratorsOfGroup(G), p -> i^p <> i) then
                G := Stabilizer(G, i);
                orbs := Orbits(G, [1..n]);        
                orbs := Filtered(orbs, o -> Length(o)>1);

                if Length(orbs) > 1 then
                    graph := ListWithIdenticalEntries(n, []);
                    cols := ListWithIdenticalEntries(n, 0);
                    Append(graph, orbs);
                    Append(cols, List(orbs, {x} -> Length(x)));
                    Info(InfoGB, 2, "Made graph: ", Digraph(graph));
                    Add(outlist, rec( graph := Digraph(graph), vertlabels := cols));
                fi;
            fi;
        od;
        return outlist;
    end;

    r := rec(
        name := "NormaliserSimpleLeon",
        largest_required_point := LargestMovedPoint(group),
        image := {p} -> group^p,
        result := {} -> group,
        check := {p} -> group=group^p,
        refine := rec(
            initialise := function(ps, buildingRBase)
                # Set 'seenDepth to -1 at the start. Note we always start searching at 'seenDepth + 1' which will be 0
                r!.btdata := rec(seenDepth := -1);
                return r!.refine.fixed(ps, buildingRBase);
            end,
            fixed := function(ps, buildingRBase)
                local fixedpoints, result;
                fixedpoints := PS_FixedPoints(ps);
                Assert(2, r!.btdata.seenDepth <= Length(fixedpoints));
                result := Concatenation(List([r!.btdata.seenDepth + 1..Length(fixedpoints)], x -> getOrbits(fixedpoints{[1..x]})));
                r!.btdata.seenDepth := Length(fixedpoints);
                return result;
            end)
        );
        return Objectify(GBRefinerType, r);
    end;