-module(chord).
-compile(export_all).


master(Nodes) ->
    
    receive
        {N} ->
            io:fwrite("Nodes Completed");
        {Msg,Jh} ->
                Map = persistent_term:get(nodeList),
                N = length(maps:to_list(Map)),
                Nodelist = persistent_term:get(nodeList),
                First = element(1,maps:get(1,Nodelist)),
                Last =  element(1,maps:get(N,Nodelist)),
                Next =  element(1,maps:get(2,Nodelist)),

                Temp = #{First=>{Last,Next}},
    
    
                SucPred = persistent_term:get(adjNeighMap),
                Newmp = maps:merge(SucPred,Temp),
                persistent_term:put(adjNeighMap,Newmp),
                io:fwrite("Network, 3 nodes at a time (Previous - Current - Next): ~n"),
                calculateNext(N-2,N);
        {done,_K,_EW}->
            Map = persistent_term:get(nodeList),
            NMap = persistent_term:get(adjNeighMap),
            io:fwrite("~p",[NMap]),
            L = length(maps:to_list(Map)),
            initfinger(L-1,L);
        {F,FG,FH,FH}->
            Fin = persistent_term:get(fingerTable),
            io:fwrite("~p",[Fin])


    end,
    master(Nodes).



loopNode(_, 0,_) ->
    mid ! {"done","gh"},
    ok;
loopNode(I, NumNodes,Prev) ->
    K = [3,6,7,11],
    Ran = lists:nth(rand:uniform(length(K)), K),
    L = #{},
   
    Pid = spawn(chord, nodeWork, [L]),
    Map = persistent_term:get(nodeList),
    Nodenum = Prev +Ran,
    M=persistent_term:get(m),
    Max = math:pow(2,M),
    if Nodenum > Max ->
        loopNode(I,0,Prev);
    true->
        Map2 = #{I => {Nodenum,Pid}},
        Map3 = maps:merge(Map, Map2),
        persistent_term:put(nodeList, Map3),
        io:fwrite("Node ID: ~p~n", [Nodenum]),


        Pid ! {new_node},
        loopNode(I + 1, NumNodes-1,Nodenum)

    end.
   

% calculateHop(DestinationNode) ->



node_work(Table) ->
    % io:fwrite("Hello"),
    Table,
    receive
        {SelfID, _, _} ->
           
           
            
            ListRem = persistent_term:get(nodeList),
            NewListRem = lists:delete(SelfID, ListRem),
            T = persistent_term:put(nodeList, NewListRem),
            T,
            {_, Time1} = statistics(runtime),
            {_, Time2} = statistics(wall_clock),
            U1 = Time1 * 1000,
            U2 = Time2 * 1000,
            io:format("Code time=~p (~p) microseconds~n", [U1, U2])
  
    end,
    node_work(Table).

nodeWork(Table) ->
    receive
        {initial} ->
            NodeId = persistent_term:get(nodeId);
            % NewTab=initFingerTable(self(),Table),
            % io:fwrite("~p",[NewTab]);
        {new_node} ->
            NodeId = persistent_term:get(nodeId)
            
    end,
nodeWork(Table).

calculateNext(0,Numnodes)->
     Nodelist = persistent_term:get(nodeList),
                First = element(1,maps:get(1,Nodelist)),
                Last =  element(1,maps:get(Numnodes,Nodelist)),
                Behind_last =  element(1,maps:get(Numnodes-1,Nodelist)),

                Temp = #{Last=>{Behind_last,First}},
    
    
                SucPred = persistent_term:get(adjNeighMap),
                Newmp = maps:merge(SucPred,Temp),
                persistent_term:put(adjNeighMap,Newmp),
    

    mid ! {done,"D","sd"};


calculateNext(I,Numnodes) ->
   Nodelist = persistent_term:get(nodeList),

    Pred = element(1,maps:get(Numnodes -I-1,Nodelist)),
    Suc = element(1,maps:get(Numnodes-I+1,Nodelist)),
    Curr =  element(1,maps:get(Numnodes-I,Nodelist)),

    io:fwrite("~p - ~p - ~p\n",[Pred,Curr,Suc]),
    Temp = #{Curr=>{Pred,Suc}},
    
    
    SucPred = persistent_term:get(adjNeighMap),
    Newmp = maps:merge(SucPred,Temp),
    persistent_term:put(adjNeighMap,Newmp),

    calculateNext(I-1,Numnodes).


startFirstNode(NodeId,Table) ->
    M = persistent_term:get(m),
    firstLoop(M, M,Table,NodeId).

firstLoop(0, M,NewTable,_) ->
    NewTable;
firstLoop(I, M,Table,NodeId) ->
    %  io:fwrite("here"),
    % Finger = persistent_term:get(finger),
    % NodeId = persistent_term:get(nodeId),
    X = math:fmod((1 + trunc(math:pow(2, M-I))), trunc(math:pow(2, I))),
      Finger2 = #{M-I =>{ X,NodeId}},
    NewTable = maps:merge(Table,Finger2),

    io:fwrite("~p",[NewTable]),

    firstLoop(I - 1, M,NewTable,NodeId).



initfinger(0,_)->
    mid ! {"dff","fdf","dfdf","f"};

initfinger(I,N)->
 
    M=persistent_term:get(m),

    Finger = persistent_term:get(fingerTable),
    Index = N-I,
    Check=Index,
    Emptymp=#{},
    Filled_table=createTable(M,M,Index,Emptymp,Check),
    Temp = #{Index=>Filled_table},
    NewTemp = maps:merge(Temp,Finger),
    io:fwrite("~p\n",[NewTemp]),
    persistent_term:put(fingerTable,NewTemp),


initfinger(I-1,N).


createTable(0,_,_,NewTemp,_)->
    NewTemp;

createTable(I,M,Index,Map,Check)->
   
    Nodelist = persistent_term:get(nodeList),
    Ele = element(1,maps:get(Check,Nodelist)),
    SucPred = persistent_term:get(adjNeighMap),
    X =math:fmod((Index + trunc(math:pow(2, M-I))), trunc(math:pow(2, M))),
    SucPred = persistent_term:get(adjNeighMap),
    Succ = element(2,maps:get(Ele,SucPred)),
    % io:fwrite("~p-~p-~p",[Index,X,Succ]),
    if X < Succ orelse X == Succ -> 
        Temp = #{X=>Succ},
        NewTemp = maps:merge(Temp,Map),
        createTable(I-1,M,Index,NewTemp,Check);
    true ->
        createTable(I,M,Index,Map,Check+1)
    end.

runner(Nodes, Requests) ->
    Temp = 0,
    N = 0,
    % while(Temp, NumNodes, N),
    Nodelist = #{},
    AdjacentNeighbourMap = #{},
    FingerTable=#{}, 
    persistent_term:put(adjNeighMap, AdjacentNeighbourMap),
    persistent_term:put(nodeList, Nodelist),
    persistent_term:put(requests, Requests),
    persistent_term:put(fingerTable, FingerTable),
    persistent_term:put(successor, 0),
    persistent_term:put(predecessor, 0),
    persistent_term:put(nodeId, 0),
    register(mid, spawn(chord, master, [Nodes])),
    Map = #{-1 => mid},
    persistent_term:put(map, Map),
    M = 6,
    % M = math:log2(Nodes),
    persistent_term:put(m, M),
    Integer = integer_to_list(0),
    Str = string:concat("node", Integer),
    OneHashed = io_lib:format("~64.16.0b", [
        binary:decode_unsigned(
            crypto:hash(
                sha,
                Str
            )
        )
    ]),
    % FirstHash = OneHashed,
    persistent_term:put(firstNode, OneHashed),
    
    L = #{}, 
    Pid = spawn(chord, nodeWork, [L]),
    InitMap = #{1 => {1,Pid}},
    NodeMap = persistent_term:get(nodeList),
    
    FinalMap = maps:merge(NodeMap, InitMap),


    persistent_term:put(nodeList, FinalMap),
    io:fwrite("Initial Node hashed: ~p~n", [OneHashed]),
    Pid ! {initial},
   
    loopNode(2, Nodes-1,1).

