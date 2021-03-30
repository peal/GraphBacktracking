#
# GraphBacktracking
#
# Implementations
#


DeclareRepresentation("IsGBState", IsBacktrackableState and IsBTKitState, []);
BindGlobal("GBStateType", NewType(BacktrackableStateFamily,
                                       IsGBState));

InstallMethod(SaveState, [IsGBState],
 function(state)
    return rec(depth := PS_Cells(state!.ps),
               refiners := List(state!.conlist, SaveState),
               graphs := ShallowCopy(state!.graphs),
               raw_graphs := ShallowCopy(state!.raw_graphs));
end);

InstallMethod(RestoreState, [IsGBState, IsObject],
 function(state, saved)
    local c;
    PS_RevertToCellCount(state!.ps, saved.depth);
    for c in [1..Length(saved.refiners)] do
        RestoreState(state!.conlist[c], saved.refiners[c]);
    od;
    state!.graphs := ShallowCopy(saved.graphs);
    state!.raw_graphs := ShallowCopy(saved.raw_graphs);
end);

_GB.ShiftGraph := function(ps, f, state, tracer)
    local extra_pnts, old_max, vert_map, new_graph, new_cell, shift_size;

    extra_pnts := DigraphNrVertices(f.graph) - PS_Points(ps);
    if not AddEvent(tracer, rec(type := "NewVertices", pos := extra_pnts)) then
        Info(InfoGB, 1, "number of extra vertices not consistent");
        return false;
    fi;

    old_max := PS_ExtendedPoints(ps);
    shift_size := old_max - PS_Points(ps);
    new_cell := PS_Extend(ps, extra_pnts);

    if IsBound(f.vertlabels) then
        # Split the new cells by vertex colour (only worry about the new vertices here)
        if not PS_SplitCellByFunction(state!.ps, tracer, new_cell, {x} -> f.vertlabels[x-shift_size]) then
            return false;
        fi;
    fi;

    vert_map := Concatenation([1..PS_Points(ps)], [old_max+1..old_max+extra_pnts]);

    new_graph := List(DigraphEdges(f.graph), {x} -> [vert_map[x[1]], vert_map[x[2]]]);

    return DigraphByEdges(new_graph);
end;

InstallMethod(ApplyFilters, [IsGBState, IsTracer, IsObject],
  function(state, tracer, filters)
    local f, ret, applyFilter, g, pos;
    if filters = fail then
        Info(InfoGB, 1, "Failed filter");
        return false;
    fi;

    if not IsList(filters) then 
        filters := [filters];
    fi;

    for f in filters do
        Assert(2, IsFunction(f) or IsSubset(["graph", "vertlabels"], RecNames(f)));
        if IsFunction(f) then
            if not PS_SplitCellsByFunction(state!.ps, tracer, f) then
                Info(InfoGB, 1, "Trace violation");
                return false;
            fi;
        else
            if IsBound(f.vertlabels) then
                # Note that this only covers the 'basic' vertices, any extended ones
                # are handled later in 'ShiftGraph'
                if not PS_SplitCellsByFunction(state!.ps, tracer, {x} -> f.vertlabels[x]) then
                    Info(InfoGB, 1, "Trace violation (vertex colouring)");
                    return false;
                fi;
            fi;
            if IsBound(f.graph) then
                # TODO (maybe) -- this skipping of merged graphs ignores
                # vertex colourings.
                pos := Position(state!.raw_graphs, f.graph);
                if pos = fail then
                    Add(state!.raw_graphs, f.graph);
                    if PS_Points(state!.ps) < DigraphNrVertices(f.graph) then
                        g := _GB.ShiftGraph(state!.ps, f, state, tracer);
                        if g = false then
                            # Refining extra colours of new graph failed
                            return false;
                        fi;
                    else
                        g := f.graph;
                    fi;
                    Add(state!.graphs, g);
                else
                    if not AddEvent(tracer, rec(type := "SkipGraph", pos := pos)) then
                        Info(InfoGB, 1, "Failed graph merge");
                        return false;
                    fi;
                fi;
            fi;
        fi;
    od;
    return true;
end);




_GB.DefaultConfig :=
    rec(cellSelector := BranchSelector_MinSizeCell, consolidator := GB_MakeEquitableStrong);

InstallMethod(ConsolidateState, [IsGBState, IsTracer], 
    function(state, tracer)
        return state!.config.consolidator(state!.ps, tracer, state!.graphs);
    end);

_GB.BuildProblem :=
    {ps, conlist, conf} -> Objectify(GBStateType, rec(ps := ps, conlist := conlist, graphs := [], raw_graphs := [],
                            config := _BTKit.FillConfig(conf, _GB.DefaultConfig)));

InstallGlobalFunction( GB_SimpleSearch,
    {ps, conlist, conf...} -> _BTKit.SimpleSearch(_GB.BuildProblem(ps, conlist, conf)));

InstallGlobalFunction( GB_SimpleSinglePermSearch,
  function(ps, conlist, conf...)
    local ret;
    ret := _BTKit.SimpleSinglePermSearch(_GB.BuildProblem(ps, conlist, conf), true);
    if IsEmpty(ret) then
        return fail;
    else
        return ret[1];
    fi;
end);

InstallGlobalFunction( GB_SimpleAllPermSearch,
    {ps, conlist, conf...} -> _BTKit.SimpleSinglePermSearch(_GB.BuildProblem(ps, conlist, conf), false));

#! Build the initial graph stack, and return the automorphisms
#! of this graph stack. second argument is if this is the solution
#! (if not it will be a super-group of the solutions).
InstallGlobalFunction( GB_CheckInitialGroup,
    function(ps, conlist)
        local state, tracer, sols, saved, gens, ret;
        state := _GB.BuildProblem(ps, conlist,[]);
        tracer := RecordingTracer();
        saved := SaveState(state);
        InitialiseConstraints(state, tracer, true);

        sols := _GB.AutoAndCanonical(state!.ps, state!.graphs);
        gens := GeneratorsOfGroup(sols.grp);
        gens := List(gens, x -> PermList(ListPerm(x, PS_Points(state!.ps))));
        
        ret := ForAll(gens, p -> BTKit_CheckSolution(p, state!.conlist));

        RestoreState(state, saved);
        return rec(gens := gens, answer := ret);
end);


InstallGlobalFunction( GB_CheckInitialCoset,
    function(ps, conlist)
        local state, tracer, rbase, sols1, sols2, saved, autgraph1, autgraph2;
        state := _GB.BuildProblem(ps, conlist,[]);
        tracer := RecordingTracer();
        saved := SaveState(state);
        InitialiseConstraints(state, tracer, true);

        sols1 := _GB.AutoAndCanonical(state!.ps, state!.graphs);

        RestoreState(state, saved);

        rbase := BuildRBase(state, state!.config.cellSelector);
        FinaliseRBaseForConstraints(state, rbase);

        tracer := RecordingTracer();
        saved := SaveState(state);
        InitialiseConstraints(state, tracer, false);

        sols2 := _GB.AutoAndCanonical(state!.ps, state!.graphs);

        RestoreState(state, saved);

        autgraph1 := [OnDigraphs(sols1.graph[1], sols1.canonicalperm), List(sols1.graph[2], x -> OnSets(x, sols1.canonicalperm))];
        autgraph2 := [OnDigraphs(sols2.graph[1], sols2.canonicalperm), List(sols2.graph[2], x -> OnSets(x, sols2.canonicalperm))];
        return rec(graph1 := autgraph1, graph2 := autgraph2, equal := autgraph1 = autgraph2);
end);
