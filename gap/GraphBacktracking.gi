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

GB_ApplyFilters := function(state, tracer, filters)
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
end;

InitialiseConstraints := function(state, tracer, rbase)
    local c, filters;
    for c in state!.conlist do
        if IsBound(c!.refine.initialise) then
            filters := c!.refine.initialise(state!.ps, rbase);
            if not GB_ApplyFilters(state, tracer, filters) then
                return false;
            fi;
        fi;
    od;
    GB_MakeEquitableStrong(state!.ps, tracer, state!.graphs);
    return true;
end;

GB_RefineConstraints := function(state, tracer, rbase)
    local c, filters, cellCount;
    cellCount := -1;
    while cellCount <> PS_Cells(state!.ps) do
        cellCount := PS_Cells(state!.ps);
        for c in state!.conlist do
            if IsBound(c!.refine.changed) then
                filters := c!.refine.changed(state!.ps, rbase);
                if not GB_ApplyFilters(state, tracer, filters) then
                    return false;
                fi;
            fi;
        od;
        GB_MakeEquitableStrong(state!.ps, tracer, state!.graphs);
    od;
    return true;
end;

GB_FirstFixedPoint := function(state, tracer, rbase)
    return InitialiseConstraints(state, tracer, rbase) and
           GB_RefineConstraints(state, tracer, rbase);
end;

InstallGlobalFunction( GB_BuildRBase,
    function(state, branchselector)
        local rbase, tracer, saved, branchCell, branchPos;
        saved  := SaveState(state);

        Info(InfoBTKit, 1, "Building RBase");
        Info(InfoBTKit, 2, "RBase level: ", PS_AsPartition(state!.ps));
        tracer := RecordingTracer();
        rbase  := rec(branches := [],
                      root := rec(tracer := tracer)
                     );

        # Initialise the constraints, and use them to refine the initial
        # partition stack as far as possible, to reach a stable point:
        # this is essentially reaching the root node of the search tree.
        # Record the trace into rbase.root.tracer.
        GB_FirstFixedPoint(state, tracer, true);

        # Continue building the RBase until a discrete partition is reached.
        while PS_Cells(state!.ps) <> PS_Points(state!.ps) do

            # Split off the min value of the cell chosen by the branch selector.
            # Use the constraints to refine until the next stable point.
            # Record the trace into a new tracer.
            branchCell := branchselector(state!.ps);
            branchPos := Minimum(PS_CellSlice(state!.ps, branchCell));
            tracer := RecordingTracer();
            # Record the info from this step of construction in rbase.branches.
            Add(rbase.branches, rec(cell   := branchCell,
                                    pos    := branchPos,
                                    tracer := tracer
                                   ));
            PS_SplitCellByFunction(state!.ps, tracer, branchCell, {x} -> (x = branchPos));
            GB_RefineConstraints(state, tracer, true);
            Info(InfoBTKit, 2, "RBase level: ", PS_AsPartition(state!.ps));
        od;

        # When the RBase has been built, save a copy of the corresponding
        # partition stack, and the length of the RBase in search tree.
        rbase.ps := Immutable(state!.ps);
        rbase.depth := Length(rbase.branches);
        Info(InfoBTKit, 1, "RBase built");

        RestoreState(state, saved);
        return rbase;
    end);


InstallGlobalFunction( GB_Backtrack,
    function(state, rbase, depth, subgroup, parent_special, find_single)
    local p, found, isSol, saved, vals, branchInfo, v, tracer, special;

    Info(InfoBTKit, 2, "Partition: ", PS_AsPartition(state!.ps));
    BTKit_Stats_AddNode();

    if depth > Length(rbase.branches) then
        # The current state is as long as the RBase. Therefore no further search
        # will be done here, as the state must always match the RBase.
        # - If the partition state is not discrete, there are no solutions here.
        # - If the partition state is discrete, then this defines a candidate
        #   solution. Construct the candidate, and check it.
        if not PS_Fixed(state!.ps) then
            return false;
        fi;
        p := BTKit_GetCandidateSolution(state!.ps, rbase);
        isSol := BTKit_CheckSolution(p, state!.conlist);
        Info(InfoBTKit, 2, "Maybe solution? ", p, " : ", isSol);
        if isSol then
            subgroup[1] := ClosureGroup(subgroup[1], p);
            Add(subgroup[2], p);
        fi;
        return isSol;
    fi;

    # The current state of search is not yet as long as the RBase, and so we
    # attempt to branch. We consult the RBase to guide this process.

    branchInfo := rbase.branches[depth];
    if PS_Cells(state!.ps) < branchInfo.cell then
        # The current state is inconsistent with the RBase: the RBase branched
        # here on the cell with index <branchInfo.cell>, but the current state
        # has no such cell.
        return false;
    fi;

    # <vals> is the cell of the current state with index <branchInfo.cell>. We
    # branch by splitting the search space up into those permutations that map
    # <branchInfo.branchPos> to <v>, for each <v> in <vals>.
    vals := Set(PS_CellSlice(state!.ps, branchInfo.cell));
    Info(InfoBTKit, 1,
         StringFormatted("Branching at depth {}: {}", depth, branchInfo));
    Print("\>");
    # A node is special if its parent is special, and it is the first one
    # amongst its siblings. If we find a solution at some node, we immediately
    # return to the deepest special node above that node.
    special := parent_special;
    Info(InfoBTKit, 2, StringFormatted(
         "Searching: {}; parent_special: {}", vals, parent_special));

    for v in vals do
        Info(InfoBTKit, 2, StringFormatted("Branch: {}", v));
        tracer := FollowingTracer(rbase.branches[depth].tracer);
        found := false;

        # Split off point <v>, and then continue the backtrack search.
        saved := SaveState(state);
        if PS_SplitCellByFunction(state!.ps, tracer, branchInfo.cell, {x} -> x = v)
           and GB_RefineConstraints(state, tracer, false)
           and GB_Backtrack(state, rbase, depth + 1, subgroup, special, find_single)
           then
            found := true;
        fi;
        RestoreState(state, saved);

        # If this gave a solution, we return to the deepest special node above.
        # here. If the current node is special, then we are already here, and we
        # should just continue; if the parent node is special, then...
        if found and (find_single or not parent_special) then
            Print("\<");
            return true;
        fi;
        special := false;
    od;
    Print("\<");
    return false;
end);

InstallGlobalFunction( GB_SimpleSearch,
    function(ps, conlist)
        local rbase, perms, state, saved, tracer;
        state := Objectify(GBStateType, rec(ps := ps, conlist := conlist, graphs := []));
        saved := SaveState(state);
        rbase := GB_BuildRBase(state, BranchSelector_MinSizeCell);
        BTKit_FinaliseRBaseForConstraints(state, rbase);
        perms := [ Group(()), [] ];

        tracer := FollowingTracer(rbase.root.tracer);
        if GB_FirstFixedPoint(state, tracer, false) then
            GB_Backtrack(state, rbase, 1, perms, true, false);
        fi;
        RestoreState(state, saved);
        return perms[1];
end);

InstallGlobalFunction( GB_SimpleSinglePermSearch,
    function(ps, conlist)
        local rbase, perms, state;
        state := Objectify(GBStateType, rec(ps := ps, conlist := conlist, graphs := []));
        if not InitialiseConstraints(state) then
            return fail;
        fi;
        rbase := GB_BuildRBase(state, BranchSelector_MinSizeCell);
        perms := [ Group(()), [] ];
        GB_Backtrack(state, rbase, 1, perms, true);

        if Length(perms[2])>0 then
            return perms[2][1];
        else
            return fail;
        fi;
end);
