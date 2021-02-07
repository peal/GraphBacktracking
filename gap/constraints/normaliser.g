
GB_Con.NormaliserSimple := function(n, group)
    local orbList,getOrbits, orbMap, pointMap, r, invperm,minperm;

    getOrbits := function(pointlist)
        local G,orbs,graph,cols;

        G := Stabilizer(group, pointlist, OnTuples);

        orbs := Orbits(G, [1..n]);
        
        orbs := Filtered(orbs, o -> Length(o)>1);
        
        graph := ListWithIdenticalEntries(n, []);
        cols := ListWithIdenticalEntries(n, 0);
        Append(graph, orbs);
        Append(cols, List(orbs, {x} -> Length(x)));
        return rec( graph := Digraph(graph), vertlabels := {x} -> cols[x]);
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