#
# BacktrackKit: An Extensible, easy to understand backtracking framework
#
# Implementations
#

GB_Stats := fail;
GB_ResetStats := function()
    GB_Stats := rec( nodes := 0 );
end;
GB_ResetStats();

GB_Stats_AddNode := function()
    GB_Stats.nodes := GB_Stats.nodes + 1;
end;

GB_SaveState := function(state)
    return rec(depth := PS_Cells(state.ps),
               conState := BTKit_SaveConstraintState(state.conlist),
               graphs := ShallowCopy(state.graphs));
end;

GB_RestoreState := function(state, saved)
    PS_RevertToCellCount(state.ps, saved.depth);
    BTKit_RestoreConstraintState(state.conlist, saved.conState);
    state.graphs := ShallowCopy(saved.graphs);
end;

GB_ApplyFilters := function(state, tracer, filters)
    local f, ret;
    if filters = fail then
        Info(InfoGB, 1, "Failed filter");
        return false;
    fi;
    for f in filters do
        if IsBound(f.partition) then
            if not PS_SplitCellsByFunction(state.ps, tracer, f.partition) then
                Info(InfoGB, 1, "Trace violation");
                return false;
            fi;
        elif IsBound(f.graphs) then
            Append(state.graphs, f.graphs);
        else
            ErrorNoReturn("Invalid filter?");
        fi;
    od;
    return true;
end;

InitialiseConstraints := function(state)
    local c, filters, tracer;
    tracer := RecordingTracer();
    for c in state.conlist do
        if IsBound(c.refine.initialise) then
            filters := c.refine.initialise(state);
            if not GB_ApplyFilters(state, tracer, filters) then
                return false;
            fi;
        fi;
    od;
    GB_MakeEquitableStrong(state.ps, tracer, state.graphs);
    return true;
end;

GB_RefineConstraints := function(state, tracer, rbase)
    local c, filters, cellCount;
    cellCount := -1;
    while cellCount <> PS_Cells(state.ps) do
        cellCount := PS_Cells(state.ps);
        for c in state.conlist do
            if IsBound(c.refine.changed) then
                filters := c.refine.changed(state, rbase);
                if not GB_ApplyFilters(state, tracer, filters) then
                    return false;
                fi;
            fi;
        od;
        GB_MakeEquitableStrong(state.ps, tracer, state.graphs);
    od;
    return true;
end;


InstallGlobalFunction( GB_BuildRBase,
    function(state, branchselector)
        local ps_depth, rbase, tracelist, tracer, branchinfo, saved, branchCell, branchPos;
        Info(InfoGB, 1, "Building RBase");
        rbase := rec(branches := []);
        ps_depth := PS_Cells(state.ps);

        # Make a copy we can keep
        state := StructuralCopy(state);

        saved := GB_SaveState(state);

        while PS_Cells(state.ps) <> PS_Points(state.ps) do
            branchCell := branchselector(state.ps);
            branchPos := Minimum(PS_CellSlice(state.ps, branchCell));
            tracer := RecordingTracer();
            Add(rbase.branches, rec(cell := branchCell,
                                pos := branchPos, tracer := tracer));
            PS_SplitCellByFunction(state.ps, tracer, branchCell, {x} -> (x = branchPos));
            GB_RefineConstraints(state, tracer, fail);
            Info(InfoGB, 2, "RBase level:", PS_AsPartition(state.ps));
        od;
        
        rbase.ps := Immutable(state.ps);
        rbase.graphs := Immutable(state.graphs);
        rbase.depth := Length(rbase.branches);

        GB_RestoreState(state, saved);
        return rbase;
    end);

GB_GetCandidateSolution := function(ps, rbase)
    local perm, list1, list2, n, c, i;
    n := PS_Points(ps);
    list1 := List([1..n], {x} -> PS_CellSlice(rbase.ps, x)[1]);
    # At this point the partition stack should be fixed
    list2 := List([1..n], {x} -> PS_CellSlice(ps, x)[1]);
    perm := [];
    for i in [1..n] do
        perm[list1[i]] := list2[i];
    od;
    return PermList(perm);
end;

GB_CheckSolution := function(perm, conlist)
    local c;
    for c in conlist do
        if not c.check(perm) then
            return false;
        fi;
    od;
    return true;
end;

InstallGlobalFunction( GB_Backtrack,
    function(state, rbase, depth, perms, parent_special)
    local p, isSol, branchInfo, vals, special, tracer, found, saved, v;

    Info(InfoGB, 2, "Partition: ", PS_AsPartition(state.ps));
    GB_Stats_AddNode();

    if depth > Length(rbase.branches) then
        if not PS_Fixed(state.ps) then
            return false;
        fi;
        p := GB_GetCandidateSolution(state.ps, rbase);
        isSol := GB_CheckSolution(p, state.conlist);
        Info(InfoGB, 2, "Maybe solution? ", p, " : ", isSol);
        if isSol then
            perms[1] := ClosureGroup(perms[1], p);
            Add(perms[2], p);
        fi;
        return isSol;
    fi;

    branchInfo := rbase.branches[depth];
    vals := Set(PS_CellSlice(state.ps, branchInfo.cell));
    Info(InfoGB, 1,
         StringFormatted("Branching at depth {}: {}", depth, branchInfo));

    special := parent_special;
    Info(InfoGB, 2, StringFormatted(
         "Searching: {}; parent_special: {}", vals, parent_special));

    for v in vals do
        Info(InfoGB, 2, StringFormatted("Branch: {}", v));
        tracer := FollowingTracer(rbase.branches[depth].tracer);
        found := false;
        saved := GB_SaveState(state);
        if PS_SplitCellByFunction(state.ps, tracer, branchInfo.cell, {x} -> x = v)
           and GB_RefineConstraints(state, tracer, rbase.ps)
           and GB_Backtrack(state, rbase, depth + 1, perms, special)
           then
            found := true;
        fi;
        GB_RestoreState(state, saved);

        if found and not parent_special then
            return true;
        fi;
        special := false;
    od;
    return false;
end);

InstallGlobalFunction( GB_SimpleSearch,
    function(ps, conlist)
        local rbase, perms, state;
        state := rec(ps := ps, conlist := conlist, graphs := []);
        if not InitialiseConstraints(state) then
            return fail;
        fi;
        rbase := GB_BuildRBase(state, BranchSelector_MinSizeCell);
        perms := [ Group(()), [] ];
        GB_Backtrack(state, rbase, 1, perms, true);
        return perms[1];
end);
