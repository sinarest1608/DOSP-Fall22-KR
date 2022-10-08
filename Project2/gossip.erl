-module(gossip).

-compile(export_all).



spawn_nodes(0) ->
    io:fwrite("Spawned Nodes, building!!\n"),
    full_network(length(persistent_term:get(nodeList))),
    io:fwrite("Starting Gossip \n"),
    start_gossip(10, persistent_term:get(nodeList)),
    ok;

spawn_nodes(N) ->
    Pid = spawn(gossip, node_work, []),
    TempList = lists:append(persistent_term:get(nodeList), [Pid]),
    persistent_term:put(nodeList, TempList),
    TempMap = maps:merge(persistent_term:get(rumourMap), #{Pid=>0}),
    persistent_term:put(rumourMap, TempMap),
    spawn_nodes(N-1).


master_init() ->
    % !! initialise map, list of nodes according to the topology
    Node_List = [], % Store the nodes spawned
    Rumour_Map = #{},
    FullNetwork_Map = #{},
    persistent_term:put(nodeList, Node_List),
    persistent_term:put(rumourMap, Rumour_Map),
    persistent_term:put(fullNetMap, FullNetwork_Map),
    io:fwrite("Initialised Everything, Spawning!"),

    spawn_nodes(10).
    % io:format("~p ~n ~p ~n ~p ~n", [persistent_term:get(nodeList), persistent_term:get(rumourMap), persistent_term:get(fullNetMap)]).


full_network(0)->
    % io:format("~p ~n", [persistent_term:get(fullNetMap)]),
    io:fwrite("Full Network Done! ");
full_network(N)->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    TempList = lists:delete(Ele, CurrentNodeList),
    FullNetworkMap = maps:merge(persistent_term:get(fullNetMap), #{Ele=>TempList}),
    persistent_term:put(fullNetMap, FullNetworkMap),
    full_network(N-1).

node_work()->
    receive
        {LiarID, Rumour, SelfID} ->
            io:format("Gossip Received ~p ~n", [Rumour]),
            TempRMap = persistent:get(rumourMap),
            TempVal = maps:get(SelfID, TempRMap),
            maps:put(SelfID, TempVal+1, TempRMap),
            start_gossip(5, maps:get(SelfID, persistent_term:get(fullNetMap)))
    end,
    io:fwrite("Hello").

start_gossip(0, _)->
    ok;
start_gossip(N, NList)->
    % TempList = persistent_term:get(nodeList),
    RandomNode = lists:nth(rand:uniform(length(NList)), NList),
    RandomNode ! {self(), "Rumour", RandomNode},

    % Neighbours = maps:get(RandomNode, persistent_term:get(fullNetMap)),

    start_gossip(N-1, NList).



runner() ->
    % {ok, Z} = io:read("Enter Number of Zeros "), !!! To pass number of nodes !!!
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(gossip, master_init, [])).

