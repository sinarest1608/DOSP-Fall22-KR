-module(gossip).

-compile(export_all).

spawn_nodes(0, Topology, Algo) ->
    io:fwrite("Spawned Nodes, building!!\n"),
    % io:format("NodeList ~p ~n", [persistent_term:get(nodeList)]),
    % io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
    % io:format("T ~p ~n", [Topology]),
    % full_network(length(persistent_term:get(nodeList))),
    % line_network(length(persistent_term:get(nodeList))),
    if Topology == full ->
           full_network(length(persistent_term:get(nodeList)), Algo);
       true ->
           if Topology == line ->
                  line_network(length(persistent_term:get(nodeList)), Algo);
              true ->
                  if Topology == twoD ->
                         twoD_network(length(persistent_term:get(nodeList)), Algo);
                     true ->
                         if Topology == threeDImp ->
                                threeD_network(length(persistent_term:get(nodeList)), Algo);
                            true ->
                                ok
                         end
                  end
           end
    end,
    ok;
spawn_nodes(N, Topology, Algo) ->
    Pid = spawn(gossip, node_work, [Topology]),
    TempList =
        lists:append(
            persistent_term:get(nodeList), [Pid]),
    persistent_term:put(nodeList, TempList),
    TempMap =
        maps:merge(
            persistent_term:get(rumourMap), #{Pid => 0}),
    persistent_term:put(rumourMap, TempMap),
    spawn_nodes(N - 1, Topology, Algo).

master_init(Mid, Topology, Algo, N) ->
    % io:format("~p ~n", [Mid]),
    % !! initialise map, list of nodes according to the topology
    Node_List = [], % Store the nodes spawned
    Rumour_Map = #{},
    FullNetwork_Map = #{},
    LineNetwork_Map = #{},
    TwoDNetwork_Map = #{},
    WeightMap = #{},
    persistent_term:put(nodeList, Node_List),
    persistent_term:put(rumourMap, Rumour_Map),
    persistent_term:put(fullNetMap, FullNetwork_Map),
    persistent_term:put(lineNetMap, LineNetwork_Map),
    persistent_term:put(twoDNetwork, TwoDNetwork_Map),
    persistent_term:put(weightMap, WeightMap),
    io:fwrite("Initialised Everything, Spawning!"),

    spawn_nodes(N,
                Topology, Algo).    % io:format("~p ~n ~p ~n ~p ~n", [persistent_term:get(nodeList), persistent_term:get(rumourMap), persistent_term:get(fullNetMap)]).

full_network(0, Algo) ->
    io:fwrite("Full Network Done! "),
    % io:fwrite("Starting Gossip \n"),
    % io:format("~p ~n", [persistent_term:get(fullNetMap)]),
    L = persistent_term:get(nodeList),
    statistics(runtime),
    statistics(wall_clock),
    if Algo == gossip ->
        start_gossip(L);
    true ->
        start_push_sum(full, L)
    end;
full_network(N, Algo) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    TempList = lists:delete(Ele, CurrentNodeList),
    FullNetworkMap =
        maps:merge(
            persistent_term:get(fullNetMap), #{Ele => TempList}),
    persistent_term:put(fullNetMap, FullNetworkMap),
    full_network(N - 1, Algo).

twoD_network(0, Algo) ->
    io:format("2D ~p ~n", [persistent_term:get(twoDNetwork)]),
    statistics(runtime),
    statistics(wall_clock),
    if Algo == gossip ->
        start_gossip(persistent_term:get(nodeList));
    true ->
        start_push_sum(twoD,persistent_term:get(nodeList))
    end;
twoD_network(N, Algo) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    if N == 1 ->
           Neighbour1 = lists:nth(N + 1, CurrentNodeList),
           Neighbour2 = lists:nth(N + 3, CurrentNodeList),
           TempList = [] ++ [Neighbour1, Neighbour2];
       true ->
           if N == length(CurrentNodeList) ->
                  Neighbour1 = lists:nth(N - 1, CurrentNodeList),

                  Neighbour3 = lists:nth(N - 3, CurrentNodeList),

                  TempList = [] ++ [Neighbour1, Neighbour3];
              true ->
                  Neighbour1 = lists:nth(N - 1, CurrentNodeList),
                  Neighbour2 = lists:nth(N + 1, CurrentNodeList),
                  Neighbour3 = lists:nth(N - 3, CurrentNodeList),
                  Neighbour4 = lists:nth(N + 3, CurrentNodeList),
                  TempList = [] ++ [Neighbour1, Neighbour2, Neighbour3, Neighbour4]
           end
    end,
    TwoDNetworkMap =
        maps:merge(
            persistent_term:get(twoDNetwork), #{Ele => TempList}),
    persistent_term:put(twoDNetwork, TwoDNetworkMap),
    twoD_network(N - 1, Algo).


threeD_network(N, Algo) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    if N == 1 ->
            Neighbour1 = lists:nth(N + 1, CurrentNodeList),
            Neighbour2 = lists:nth(N + 3, CurrentNodeList),
            TempList = [] ++ [Neighbour1, Neighbour2];
        true ->
            if N == length(CurrentNodeList) ->
                    Neighbour1 = lists:nth(N - 1, CurrentNodeList),

                    Neighbour3 = lists:nth(N - 3, CurrentNodeList),

                    TempList = [] ++ [Neighbour1, Neighbour3];
                true ->
                    Neighbour1 = lists:nth(N - 1, CurrentNodeList),
                    Neighbour2 = lists:nth(N + 1, CurrentNodeList),
                    Neighbour3 = lists:nth(N - 3, CurrentNodeList),
                    Neighbour4 = lists:nth(N + 3, CurrentNodeList),
                    TempList = [] ++ [Neighbour1, Neighbour2, Neighbour3, Neighbour4]
            end
    end,
    TwoDNetworkMap =
        maps:merge(
            persistent_term:get(twoDNetwork), #{Ele => TempList}),
    persistent_term:put(twoDNetwork, TwoDNetworkMap),
    threeD_network(N - 1, Algo).
    
    
    
line_network(0, Algo) ->
    io:fwrite("Line Network Done! "),
    
    statistics(runtime),
    statistics(wall_clock),
    if Algo == gossip ->
        start_gossip(persistent_term:get(nodeList));
    true ->
        start_push_sum(line, persistent_term:get(nodeList))
    end;
    
% io:format("Line ~p ~n", [persistent_term:get(lineNetMap)]);
line_network(N, Algo) ->
    CurrentNodeList = persistent_term:get(nodeList),
    Ele = lists:nth(N, CurrentNodeList),
    if N == 1 ->
           Neighbour1 = lists:nth(N + 1, CurrentNodeList),
           TempList = [] ++ [Neighbour1];
       true ->
           if N == length(CurrentNodeList) ->
                  Neighbour1 = lists:nth(N - 1, CurrentNodeList),
                  TempList = [] ++ [Neighbour1];
              true ->
                  Neighbour1 = lists:nth(N - 1, CurrentNodeList),
                  Neighbour2 = lists:nth(N + 1, CurrentNodeList),
                  TempList = [] ++ [Neighbour1, Neighbour2]
           end
    end,
    LL = persistent_term:get(lineNetMap),
    LineNetworkMap = maps:merge(LL, #{Ele => TempList}),
    persistent_term:put(lineNetMap, LineNetworkMap),
    line_network(N - 1, Algo).

node_work(Topology) ->
    % io:fwrite("Hello"),
    receive
        {LiarID, Rumour, SelfID} ->
            % Check If rumour count <= 10
            % TempNet = #{},
            % io:format("Gossip Received ~p  by ~p  form ~p ~n", [Rumour, SelfID, LiarID]),
            TempRMap = persistent_term:get(rumourMap),
            TempVal = maps:get(SelfID, TempRMap),
            if TempVal < 10 ->
                   UpdatedMap = maps:update(SelfID, TempVal + 1, TempRMap),
                   persistent_term:put(rumourMap, UpdatedMap),
                   if Topology == full ->
                          TempNet = persistent_term:get(fullNetMap),
                          TList = maps:get(SelfID, TempNet),
                          % io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
                          start_gossip(TList);
                      true ->
                          if Topology == line ->
                                 TempNet = persistent_term:get(lineNetMap),
                                 TList = maps:get(SelfID, TempNet),
                                 % io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
                                 start_gossip(TList);
                             true ->
                                 ok
                          end
                   end;
               % TempNet = persistent_term:get(lineNetMap),
               % TList = maps:get(SelfID, TempNet),
               % io:format("RumourMap ~p ~n", [persistent_term:get(rumourMap)]),
               % start_gossip(TList);
               true ->
                   ListRem = persistent_term:get(nodeList),
                   NewListRem = lists:delete(SelfID, ListRem),
                   T = persistent_term:put(nodeList, NewListRem),
                   % io:format("List After delete ~p ~n", [NewListRem]),
                   if NewListRem == [] ->
                          {_, Time1} = statistics(runtime),
                          {_, Time2} = statistics(wall_clock),
                          U1 = Time1 * 1000,
                          U2 = Time2 * 1000,
                          io:format("Code time=~p (~p) microseconds~n", [U1, U2]);
                      true ->
                          ok
                   end,
                   start_gossip(NewListRem),
                   ok
            end
    end,
    node_work(Topology).

start_push_sum(Top, NList) ->
    receive
        {LiarID, start} ->
            WeightMap = persistent_term:get(weightMap),
            {S2, W2} = maps:get(self(), WeightMap),
            S1 = S2 / 2,
            W1 = W2 / 2,
            RandomNode =
                lists:nth(
                    rand:uniform(length(NList)), NList),
            RandomNode ! {self(), S1, W1};
        {_Pid, S, W} ->
            WMap = persistent_term:get(weights),
            {Sum, Weight} = maps:get(self(), WMap),
            UpdatedSum = Sum + S,
            UpdatedWeight = Weight + W,
            if W /= 0.0 ->
                   Difference = abs(UpdatedSum / UpdatedWeight - S / W),
                   Delta = math:pow(10, -10),
                   if Difference < Delta ->
                          NMap =
                              maps:update(self(),
                                          maps:get(self(), persistent_term:get(rumourMap)) + 1,
                                          persistent_term:get(map)),
                          persistent_term:put(rumourMap, NMap);
                      true ->
                          NMap = maps:update(self(), 0, persistent_term:get(map)),
                          persistent_term:put(rumourMap, NMap)
                   end,
                   Num = maps:get(self(), persistent_term:get(map)),
                   if Num == 3 ->
                          persistent_term:put(fin, persistent_term:get(last));
                      true ->
                          ok
                   end;
               true ->
                   ok
            end,
            RandomNode =
                lists:nth(
                    rand:uniform(length(NList)), NList),
            RandomNode ! {self(), UpdatedSum / 2, UpdatedWeight / 2},
            WeightMapUpdated =
                maps:update(self(), {UpdatedSum, UpdatedWeight}, persistent_term:get(rumourMap)),
            persistent_term:put(weights, WeightMapUpdated),
            RumourMapTemp = persistent_term:get(rumourMap),
            R = maps:update(self(), true, RumourMapTemp),
            persistent_term:put(rumourMap, R)
    end,
    start_push_sum(Top, NList).

start_gossip(L) ->
    % TempList = persistent_term:get(nodeList),
    % io:fwrite("In Gossip"),
    if L == [] ->
           % io:format("Empty List ~p ~n", [L]),
           ok;
       % NList = persistent_term:get(nodeList);
       true ->
           NList = L,
           % io:format(" List ~p ~n", [NList]),
           % io:format("In Gossip, List ~p ~n By ~p ~n", [NList, self()]),
           RandomNode =
               lists:nth(
                   rand:uniform(length(NList)), NList),

           RandomNode ! {self(), "Rumour", RandomNode},
           TMap = persistent_term:get(fullNetMap)        % Neighbours = maps:get(RandomNode, TMap)
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
    {ok, N} = io:read(""),
    {ok, T} = io:read(""),
    {ok, A} = io:read(""),
    register(master_ID, spawn(gossip, master_init, [self(), T, A, N])).
