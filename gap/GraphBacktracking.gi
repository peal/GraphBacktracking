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
               graphs := ShallowCopy(state!.graphs));
end);

InstallMethod(RestoreState, [IsGBState, IsObject],
 function(state, saved)
    local c;
    PS_RevertToCellCount(state!.ps, saved.depth);
    for c in [1..Length(saved.refiners)] do
        RestoreState(state!.conlist[c], saved.refiners[c]);
    od;
    state!.graphs := ShallowCopy(saved.graphs);
end);

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
        if IsFunction(f) then
            if not PS_SplitCellsByFunction(state!.ps, tracer, f) then
            #Error("xyz");
                Info(InfoGB, 1, "Trace violation");
                return false;
            fi;
        elif IsBound(f.graphs) then
            for g in f.graphs do
                pos := Position(state!.graphs, g);
                if pos = fail then
                    Add(state!.graphs, g);
                else
                    if not AddEvent(tracer, rec(type := "SkipGraph", pos := pos)) then
                        Info(InfoGB, 1, "Failed graph merge");
                        return false;
                    fi;
                fi;
            od;
        else
            ErrorNoReturn("Invalid filter?");
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
    {ps, conlist, conf} -> Objectify(GBStateType, rec(ps := ps, conlist := conlist, graphs := [],
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
