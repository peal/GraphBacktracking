
GB_Con.NormaliserSimple := function(n, group)
    local orbList,getOrbits, orbMap, pointMap, r, invperm,minperm;

    getOrbits := function(pointlist)
        local G,orbs,graph,cols, orb;

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
        return rec( graph := Digraph(graph), vertlabels := cols);
    end;

    r := rec(
        name := "NormaliserSimple",
        image := {p} -> group^p,
        result := {} -> group,
        check := {p} -> group=group^p,
        refine := rec(
            initialise := function(ps, buildingRBase)
                return r!.refine.changed(ps, buildingRBase);
            end,
            changed := function(ps, buildingRBase)
                local fixedpoints;
                fixedpoints := PS_FixedPoints(ps);
                return getOrbits(fixedpoints);
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
        pointlist := Reversed(pointlist);
        outlist := [];
        for i in pointlist do
            if ForAny(GeneratorsOfGroup(G), p -> i^p <> p) then
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
        name := "NormaliserSimple",
        image := {p} -> group^p,
        result := {} -> group,
        check := {p} -> group=group^p,
        refine := rec(
            initialise := function(ps, buildingRBase)
                return r!.refine.changed(ps, buildingRBase);
            end,
            changed := function(ps, buildingRBase)
                local fixedpoints;
                fixedpoints := PS_FixedPoints(ps);
                return getOrbits(fixedpoints);
            end)
        );
        return Objectify(GBRefinerType, r);
    end;