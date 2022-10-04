-module(gossip).

-export([runner/0, master_init/0, spawn_nodes/1, node_work/0]).

node_work()->
    io:fwrite("Hello").

spawn_nodes(0) ->
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
    persistent_term:put(nodeList, Node_List),
    persistent_term:put(rumourMap, Rumour_Map),
    io:fwrite("Initialised Everything, Spawning!"),

    spawn_nodes(10),
    io:format("~p ~n ~p ~n", [persistent_term:get(nodeList), persistent_term:get(rumourMap)]).


full_network(0)->
    io:fwrite("Full Network Done!");
full_network(N)->
    FullNetworkMap = #{},
    CurrentNodeList = persistent_term:get(nodeList),
    Function = fun(Elem) -> 
    



runner() ->
    % {ok, Z} = io:read("Enter Number of Zeros "), !!! To pass number of nodes !!!
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(gossip, master_init, [])).

