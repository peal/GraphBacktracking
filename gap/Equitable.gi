_GB.OutNeighboursSafe := function(graph, v)
    if v > DigraphNrVertices(graph) then
        return [];
    else
        return OutNeighboursOfVertex(graph, v);
    fi;
end;

InstallMethod(GB_MakeEquitableWeak, [IsPartitionStack, IsTracer, IsList],
    function(ps, tracer, graphlist)
        local graph, cellcount, hm, v;
        cellcount := -1;
        while cellcount <> PS_Cells(ps) do
            cellcount := PS_Cells(ps);
            for graph in graphlist do
                #Print(graph,"\n");
                hm := [];
                for v in [1..PS_Points(ps)] do
                    hm[v] := List(_GB.OutNeighboursSafe(graph, v), {x} -> PS_CellOfPoint(ps, x));
                    # We negate to distinguish in and out neighbours ---------v
                    Append(hm[v], List(_GB.OutNeighboursSafe(graph, v), {x} -> -PS_CellOfPoint(ps, x)));
                    #Print(v,":",hm[v],"\n");
                    Sort(hm[v]);
                od;
                #Print(hm,"\n");
                if not PS_SplitCellsByFunction(ps, tracer, {x} -> hm[x]) then
                    Info(InfoGB, 2, "EquitableWeak trace violation");
                    return false;
                fi;
            od;
            #Print(hm,"\n");
        od;
        return true;
end);

InstallMethod(GB_MakeEquitableStrong, [IsPartitionStack, IsTracer, IsList],
    function(ps, tracer, graphlist)
        local graph, gnum, cellcount, hm, v, n, hmsetset;
        cellcount := -1;
        while cellcount <> PS_Cells(ps) do
            cellcount := PS_Cells(ps);
            hm := List([1..PS_Points(ps)], {x} -> HashMap());
            for gnum in [1..Length(graphlist)] do
                graph := graphlist[gnum];
                for v in [1..PS_Points(ps)] do
                    for n in _GB.OutNeighboursSafe(graph, v) do
                        if not IsBound(hm[v][n]) then
                            hm[v][n] := [];
                        fi;
                        Add(hm[v][n], [gnum, PS_CellOfPoint(ps, n), true]);
                    od;
                    for n in _GB.OutNeighboursSafe(graph, v) do
                        if not IsBound(hm[v][n]) then
                            hm[v][n] := [];
                        fi;
                        Add(hm[v][n], [gnum, PS_CellOfPoint(ps, n), false]);
                    od;
                od;
            od;
            hmsetset := List([1..PS_Points(ps)], {x} -> SortedList(List(Values(hm[x]), SortedList)) );
            if not PS_SplitCellsByFunction(ps, tracer, {x} -> hmsetset[x]) then
                Info(InfoGB, 2, "EquitableStrong trace violation");
                return false;
            fi;
            #Print(hm,"\n");
        od;
        return true;
end);
