-module(gossip).

-compile(export_all).
 


spawn_nodes(0) ->
    io:fwrite("Spawned Nodes, building!!\n"),
    io:format("NodeList ~p ~n", [persistent_term:get(nodeList)]),
    io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
    % full_network(length(persistent_term:get(nodeList))),
    full_network(length(persistent_term:get(nodeList))),
    ok;

spawn_nodes(N) ->
    Pid = spawn(gossip, node_work, []),
    TempList = lists:append(persistent_term:get(nodeList), [Pid]),
    persistent_term:put(nodeList, TempList),
    TempMap = maps:merge(persistent_term:get(rumourMap), #{Pid=>0}),
    persistent_term:put(rumourMap, TempMap),
    spawn_nodes(N-1).


master_init(Mid) ->
    io:format("~p ~n", [Mid]),
    % !! initialise map, list of nodes according to the topology
    Node_List = [], % Store the nodes spawned
    Rumour_Map = #{},
    FullNetwork_Map = #{},
    persistent_term:put(nodeList, Node_List),
    persistent_term:put(rumourMap, Rumour_Map),
    persistent_term:put(fullNetMap, FullNetwork_Map),
    io:fwrite("Initialised Everything, Spawning!"),

    spawn_nodes(1000).
    % io:format("~p ~n ~p ~n ~p ~n", [persistent_term:get(nodeList), persistent_term:get(rumourMap), persistent_term:get(fullNetMap)]).


full_network(0)->
    io:fwrite("Full Network Done! "),
    io:fwrite("Starting Gossip \n"),
    io:format("~p ~n", [persistent_term:get(fullNetMap)]),
    L = persistent_term:get(nodeList),
    statistics(runtime),
    statistics(wall_clock),
    start_gossip(L);
    
full_network(N)->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    TempList = lists:delete(Ele, CurrentNodeList),
    FullNetworkMap = maps:merge(persistent_term:get(fullNetMap), #{Ele=>TempList}),
    persistent_term:put(fullNetMap, FullNetworkMap),
    full_network(N-1).

line_network(0)->
    io:fwrite("Line Network Done! "),
    io:fwrite("Starting Gossip \n"),
    start_gossip(persistent_term:get(nodeList));
    % io:format("Line ~p ~n", [persistent_term:get(lineNetMap)]);
line_network(N) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    if N == 1 ->
        Neighbour1 = lists:nth(N+1, CurrentNodeList),
        TempList = [] ++ [Neighbour1];  
    true ->
        if N == length(CurrentNodeList) ->
            Neighbour1 = lists:nth(N-1, CurrentNodeList),
            TempList = [] ++ [Neighbour1]; 
        true -> 
            Neighbour1 = lists:nth(N-1, CurrentNodeList),
            Neighbour2 = lists:nth(N+1, CurrentNodeList),
            TempList = [] ++ [Neighbour1, Neighbour2]
        end
    end,
    LineNetworkMap = maps:merge(persistent_term:get(lineNetMap), #{Ele=>TempList}),
    persistent_term:put(lineNetMap, LineNetworkMap),
    line_network(N-1).

node_work()->
    % io:fwrite("Hello"),
    receive
        {LiarID, Rumour, SelfID} ->

            % Check If rumour count <= 10

            io:format("Gossip Received ~p  by ~p  form ~p ~n", [Rumour, SelfID, LiarID]),
            TempRMap = persistent_term:get(rumourMap),
            TempVal = maps:get(SelfID, TempRMap),
            if TempVal < 10 ->
                UpdatedMap = maps:update(SelfID, TempVal+1, TempRMap),
                persistent_term:put(rumourMap, UpdatedMap),
                TempFullNet = persistent_term:get(fullNetMap),
                TList = maps:get(SelfID, TempFullNet),
                io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
                start_gossip(TList);
            true ->
                ListRem = persistent_term:get(nodeList),
                NewListRem = lists:delete(SelfID, ListRem),
                T = persistent_term:put(nodeList, NewListRem),
                io:format("List After delete ~p ~n", [NewListRem]),
                if NewListRem == [] ->
                    {_, Time1} = statistics(runtime),
                    {_, Time2} = statistics(wall_clock),
                    U1 = Time1 * 1000,
                    U2 = Time2 * 1000,
                    io:format(
                        "Code time=~p (~p) microseconds~n",
                        [U1, U2]
                    );
                true ->
                    ok
                end,
                start_gossip(NewListRem),
                ok
            end
    end,
    node_work().
    

% start_gossip(_)->
%     ok;
start_gossip(L)->
    % TempList = persistent_term:get(nodeList),
    % io:fwrite("In Gossip"),
    if L == [] ->
        % io:format("Empty List ~p ~n", [L]),
        ok;
        % NList = persistent_term:get(nodeList); 
    true ->
        NList = L,
        io:format(" List ~p ~n", [NList]),
        % io:format("In Gossip, List ~p ~n By ~p ~n", [NList, self()]),
        RandomNode = lists:nth(rand:uniform(length(NList)), NList),
        
        RandomNode ! {self(), "Rumour", RandomNode},
        TMap = persistent_term:get(fullNetMap),
        Neighbours = maps:get(RandomNode, TMap)
        % start_gossip(Neighbours)
        
    end.
    % start_gossip([]).
    % io:format("In Gossip, List ~p ~n By ~p ~n", [NList, self()]),
    % RandomNode = lists:nth(rand:uniform(length(NList)), NList),
    
    % RandomNode ! {self(), "Rumour", RandomNode},
    % TMap = persistent_term:get(fullNetMap),
    % Neighbours = maps:get(RandomNode, TMap),

    % start_gossip(N-1, NList).
    

    % receive
    %     {LiarID, Rumour, SelfID} ->

    %         % Check If rumour count <= 10

    %         io:format("Gossip Received ~p  by ~p  form ~p ~n", [Rumour, SelfID, LiarID]),
    %         TempRMap = persistent_term:get(rumourMap),
    %         TempVal = maps:get(SelfID, TempRMap),
    %         if TempVal < 10 ->
    %             UpdatedMap = maps:update(SelfID, TempVal+1, TempRMap),
    %             persistent_term:put(rumourMap, UpdatedMap),
    %             TempFullNet = persistent_term:get(fullNetMap),
    %             TList = maps:get(SelfID, TempFullNet),
    %             io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
    %             start_gossip(TList);
    %         true ->
    %             ok
    %         end
    % end,
    % start_gossip(L).

    
    


runner() ->
    % {ok, Z} = io:read("Enter Number of Zeros "), !!! To pass number of nodes !!!
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(gossip, master_init, [self()])).
    
    

