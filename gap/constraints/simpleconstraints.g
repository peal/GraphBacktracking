GB_Con := rec();


# Import BacktrackKit constraints

DeclareRepresentation("IsGBRefiner", IsRefiner, ["name", "check", "refine"]);
BindGlobal("GBRefinerType", NewType(BacktrackableStateFamily,
                                       IsGBRefiner));

InstallMethod(SaveState, [IsGBRefiner],
    function(con)
        if IsBound(con!.btdata) then
            return StructuralCopy(con!.btdata);
        else
            return fail;
        fi;
    end);

InstallMethod(RestoreState, [IsGBRefiner, IsObject],
    function(con, state)
        if state <> fail then
            con!.btdata := StructuralCopy(state);
        fi;
    end);

GB_Con.InGroup := function(n, group)
    local orbList,fillOrbits, fillOrbitals, orbMap, orbitalMap, pointMap, r;
fillOrbits := function(pointlist)
        local orbs, array, i, j;
        # caching
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

        orbs := _GB.getOrbitalList(Stabilizer(group, pointlist, OnTuples), n);
        orbitalMap[pointlist] := orbs;
        return orbs;
    end;

    orbMap := HashMap();
    pointMap := HashMap();
    orbitalMap := HashMap();

    r := rec(
        name := "InGroup-GB",
        check := {p} -> p in group,
        refine := rec(
            rBaseFinished := function(getRBase)
                r!.RBase := getRBase;
            end,

            initialise := function(ps, buildingRBase)
                local fixedpoints, mapval, points, graphs;
                fixedpoints := PS_FixedPoints(ps);
                points := fillOrbits(fixedpoints);
                graphs := fillOrbitals(fixedpoints);
                return [{x} -> points[x], rec(graphs := graphs)];
            end,

            changed := function(ps, buildingRBase)
                local fixedpoints, points, fixedps, fixedrbase, p, graphs;
                if buildingRBase then
                    fixedpoints := PS_FixedPoints(ps);
                    points := fillOrbits(fixedpoints);
                    graphs := fillOrbitals(fixedpoints);
                    return [{x} -> points[x], rec(graphs := graphs)];
                else
                    fixedps := PS_FixedPoints(ps);
                    fixedrbase := PS_FixedPoints(r!.RBase);
                    fixedrbase := fixedrbase{[1..Length(fixedps)]};
                    p := RepresentativeAction(group, fixedps, fixedrbase, OnTuples);
                    Info(InfoGB, 1, "Find mapping (InGroup):\n"
                         , "    fixed points:   ", fixedps, "\n"
                         , "    fixed by rbase: ", fixedrbase, "\n"
                         , "    map:            ", p);

                    if p = fail then
                        return fail;
                    fi;
                    points := pointMap[fixedrbase];
                    graphs := orbitalMap[fixedrbase];
                    return [{x} -> points[x^p], rec(graphs := List(graphs, {g} -> OnDigraphs(g, p^-1)))];
                fi;
            end)
        );
        return Objectify(GBRefinerType, r);
    end;
