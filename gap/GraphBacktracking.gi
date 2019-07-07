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
    local f, ret, applyFilter;
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
            Append(state!.graphs, f.graphs);
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
