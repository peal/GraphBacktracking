GB_Con := rec();


GB_Con.TupleStab := function(n, fixpoints)
    local fixlist, i, filters, r;
    fixlist := [1..n]*0;
    for i in [1..Length(fixpoints)] do
        fixlist[fixpoints[i]] := i;
    od;
    filters := [rec(partition := {i} -> fixlist[i])];

    r := rec(
        name := "TupleStab",
        check := {p} -> OnTuples(fixpoints, p) = fixpoints,
        refine := rec(
            initialise := function(state)
                return filters;
            end)
        );
    return r;
end;

GB_Con.SetStab := function(n, fixedset)
    local fixlist, i, filters, r;
    fixlist := BlistList([1..n], fixedset);
    filters := [rec(partition := {i} -> fixlist[i])];

    r := rec(
        name := "SetStab",
        check := {p} -> OnSets(fixedset, p) = fixedset,
        refine := rec(
            initialise := function(state)
                return filters;
            end)
        );
    return r;
end;

GB_Con.InGroup := function(n, group)
    local orbList,fillOrbits, fillOrbitals, orbMap, orbitalMap, pointMap, r;
    fillOrbits := function(pointlist)
        local orbs, array, i, j;
        if IsBound(pointMap[pointlist]) then
            return pointMap[pointlist];
        fi;

        orbs := Orbits(Stabilizer(group, pointlist, OnTuples), [1..n]);
        orbMap[pointlist] := Set(orbs, Set);
        array := [];
        for i in [1..Length(orbs)] do
            for j in orbs[i] do
                array[j] := i;
            od;
        od;
        pointMap[pointlist] := array;
        return array;
    end;

    fillOrbitals := function(pointlist)
        local orbs, array, i, j;
        if IsBound(orbitalMap[pointlist]) then
            return orbitalMap[pointlist];
        fi;

        orbs := OrbitalGraphs(Stabilizer(group, pointlist, OnTuples));
        orbitalMap[pointlist] := orbs;
        return orbs;
    end;

    orbMap := HashMap();
    pointMap := HashMap();
    orbitalMap := HashMap();

    r := rec(
        name := "InGroup",
        check := {p} -> p in group,
        refine := rec(
            initialise := function(state)
                local fixedpoints, mapval, points, graphs;
                fixedpoints := PS_FixedPoints(state.ps);
                points := fillOrbits(fixedpoints);
                graphs := fillOrbitals(fixedpoints);
                return [rec(partition := {x} -> points[x]), rec(graphs := graphs)];
            end,

            changed := function(state, rbase)
                local fixedpoints, points, graphs, fixedps, fixedrbase, p;
                if rbase = fail then
                    fixedpoints := PS_FixedPoints(state.ps);
                    fillOrbits(fixedpoints);
                    points := fillOrbits(fixedpoints);
                    graphs := fillOrbitals(fixedpoints);
                    return [rec(partition := {x} -> points[x]), rec(graphs := graphs)];
                else
                    fixedps := PS_FixedPoints(state.ps);
                    fixedrbase := PS_FixedPoints(rbase);
                    fixedrbase := fixedrbase{[1..Length(fixedps)]};
                    p := RepresentativeAction(group, fixedps, fixedrbase, OnTuples);
                    Info(InfoGB, 1,"Find mapping",fixedps,fixedrbase,p);
                    if p = fail then
                        return fail;
                    fi;
                    points := pointMap[fixedrbase];
                    graphs := orbitalMap[fixedrbase];
                    return [rec(partition := {x} -> points[x^p]), rec(graphs := List(graphs, {g} -> OnDigraphs(g, p)))];
                fi;
            end)
        );
        return r;
    end;
