# Slightly cleverer refiner -- the function 'initialise' is called
# once at the start of search. It should return a function
GB_Con.PermConjugacy := function(permL, permR)
    local permToGraph;

    permToGraph := function(p)
        local graph,c,i;
        graph := List([1..LargestMovedPoint(p)], {x} -> []);
        for c in Cycles(p, [1..LargestMovedPoint(p)]) do
            # Skip fixed points
            if Length(c) > 1 then
                for i in [1..Length(c)-1] do
                    Add(graph[c[i]], c[i+1]);
                od;
                Add(graph[c[Length(c)]], c[1]);
            fi;
        od;
        return Digraph(graph);
    end;

    return Objectify(GBRefinerType,rec(
        name := "GB_PermConjugacy",
        largest_required_point := Maximum(LargestMovedPoint(permL), LargestMovedPoint(permR)),
        image := {p} -> permL^p,
        result := {} -> permR,
        refine := rec(
            initialise := function(ps, buildingRbase)
                if buildingRbase then
                    return rec(graph := permToGraph(permL));
                else
                    return rec(graph := permToGraph(permR));
                fi;
            end)
    ));
end;