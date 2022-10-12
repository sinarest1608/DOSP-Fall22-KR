-module(twoD).

-compile(export_all).


spawn_nodes(0) ->
    io:fwrite("Spawned Nodes, building!!\n"),
    io:format("NodeList ~p ~n", [persistent_term:get(nodeList)]),
    io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
    twoD_network(length(persistent_term:get(nodeList))),
    
    ok;

spawn_nodes(N) ->
    Pid = spawn(gossip, node_work, []),
    TempList = lists:append(persistent_term:get(nodeList), [Pid]),
    persistent_term:put(nodeList, TempList),
    TempMap = maps:merge(persistent_term:get(rumourMap), #{Pid=>0}),
    persistent_term:put(rumourMap, TempMap),
    spawn_nodes(N-1).

twoD_network(0)->
    io:format("2D ~p ~n", [persistent_term:get(twoDNetwork)]);
twoD_network(N) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    if N == 1 ->
        Neighbour1 = lists:nth(N+1, CurrentNodeList),
        Neighbour2 = lists:nth(N+3, CurrentNodeList),
        TempList = [] ++ [Neighbour1, Neighbour2];  
    true ->
        if N == length(CurrentNodeList) ->
            Neighbour1 = lists:nth(N-1, CurrentNodeList),
            
            Neighbour3 = lists:nth(N-3, CurrentNodeList),
            
            TempList = [] ++ [Neighbour1,  Neighbour3]; 
        true -> 
            Neighbour1 = lists:nth(N-1, CurrentNodeList),
            Neighbour2 = lists:nth(N+1, CurrentNodeList),
            Neighbour3 = lists:nth(N-3, CurrentNodeList),
            Neighbour4 = lists:nth(N+3, CurrentNodeList),
            TempList = [] ++ [Neighbour1, Neighbour2, Neighbour3, Neighbour4]
        end
    end,
    TwoDNetworkMap = maps:merge(persistent_term:get(twoDNetwork), #{Ele=>TempList}),
    persistent_term:put(twoDNetwork, TwoDNetworkMap),
twoD_network(N-1).

main()->
    LineNetwork_Map = #{},
    Node_List = [],
    Rumour_Map = #{},
    persistent_term:put(lineNetMap, LineNetwork_Map),
    persistent_term:put(nodeList, Node_List),
    persistent_term:put(rumourMap, Rumour_Map),
    spawn_nodes(10).