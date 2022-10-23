-module(chord).
-compile(export_all).


master(NumNodes) ->
    Count = 0,
    receive
        {N} ->
            io:fwrite("Node completed work");
        {Msg,Jh} ->
                Map = persistent_term:get(node),
                io:fwrite("~p",[Map]),
                N = length(maps:to_list(Map)),
                io:fwrite("likh - ~p",[N]),
                Nodelist = persistent_term:get(node),
                First = element(1,maps:get(1,Nodelist)),
                Last =  element(1,maps:get(N,Nodelist)),
                Next =  element(1,maps:get(2,Nodelist)),

                Temp = #{First=>{Last,Next}},
    
    
                SucPred = persistent_term:get(sucpred),
                Newmp = maps:merge(SucPred,Temp),
                persistent_term:put(sucpred,Newmp),

                find_successor(N-2,N);
        {done,_K,_EW}->
            Map = persistent_term:get(node),
            Sucpred = persistent_term:get(sucpred),
            io:fwrite("~p",[Sucpred]),
            L = length(maps:to_list(Map)),
            initfinger(L-1,L);
        {F,FG,FH,FH}->
            Fin = persistent_term:get(finger),
            io:fwrite("~p",[Fin])


    end,
    master(NumNodes).


for(_, 0,_) ->
    mid ! {"done","gh"},
    ok;
for(I, NumNodes,Prev) ->
    K = [3,6,7,11],
    Ran = lists:nth(rand:uniform(length(K)), K),
    L = #{},
   
    Pid = spawn(chord, nodeWork, [L]),
    Map = persistent_term:get(node),
    NodeCount = Prev +Ran,
    M=persistent_term:get(m),
    Max = math:pow(2,M),
    if NodeCount > Max ->
        for(I,0,Prev);
    true->
        Map_2 = #{I => {NodeCount,Pid}},
        Map_3 = maps:merge(Map, Map_2),
        persistent_term:put(node, Map_3),
        io:fwrite("New node created with id: ~p~n", [NodeCount]),
        %  F1 = persistent_term:get(finger),
        % F2 = #{I => #{}},
        % NewF = maps:merge(F1,F2),
        % persistent_term:put(finger,NewF ),


        Pid ! {new_node},
        for(I + 1, NumNodes-1,NodeCount)

    end.
   




start(NumNodes, NumReqs) ->
    Temp = 0,
    N = 0,
    % while(Temp, NumNodes, N),
    Nodelist = #{},
    Sp = #{},
    Finger=#{},
    persistent_term:put(sucpred, Sp),
    persistent_term:put(node, Nodelist),
    persistent_term:put(reqs, NumReqs),
    persistent_term:put(finger, Finger),
    persistent_term:put(successor, 0),
    persistent_term:put(predecessor, 0),
    persistent_term:put(nodeId, 0),
    register(mid, spawn(chord, master, [NumNodes])),
    Map = #{-1 => mid},
    persistent_term:put(map, Map),
    M = 6,
    persistent_term:put(m, M),
    Integer = integer_to_list(0),
    Str = string:concat("node", Integer),
    Name = io_lib:format("~64.16.0b", [
        binary:decode_unsigned(
            crypto:hash(
                sha256,
                Str
            )
        )
    ]),
    FirstHash = Name,
    persistent_term:put(first, FirstHash),
    L = #{}, %initilise with M number of Empty tuples.
    Pid = spawn(chord, nodeWork, [L]),
    Map_2 = persistent_term:get(node),
    Map_3 = #{1 => {1,Pid}},
    New_Map = maps:merge(Map_2, Map_3),



    % F1 = persistent_term:get(finger),
    % F2 = #{1 => #{}},
    % NewF = maps:merge(F1,F2),
    % persistent_term:put(finger,NewF ),

    persistent_term:put(node, New_Map),
    io:fwrite("First node created with id: ~p~n", [Name]),
    Pid ! {initial},
   
    for(2, NumNodes-1,1).





% while(Temp, NumNodes, M) ->
%     X = trunc(NumNodes * 10),
%     Temp2 = trunc(math:pow(2, M)),
%     M2 = M + 1,
%     if
%         Temp < X ->
%             while(Temp2, NumNodes, M2);
%         true ->
%             ok
%     end,
%     ok.


%---------------------------Spawn remaining actors----------------------------------------


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

find_successor(0,Numnodes)->
     Nodelist = persistent_term:get(node),
                First = element(1,maps:get(1,Nodelist)),
                Last =  element(1,maps:get(Numnodes,Nodelist)),
                Behind_last =  element(1,maps:get(Numnodes-1,Nodelist)),

                Temp = #{Last=>{Behind_last,First}},
    
    
                SucPred = persistent_term:get(sucpred),
                Newmp = maps:merge(SucPred,Temp),
                persistent_term:put(sucpred,Newmp),
    

    mid ! {done,"D","sd"};


find_successor(I,Numnodes) ->
   Nodelist = persistent_term:get(node),

    Pred = element(1,maps:get(Numnodes -I-1,Nodelist)),
    Suc = element(1,maps:get(Numnodes-I+1,Nodelist)),
    Curr =  element(1,maps:get(Numnodes-I,Nodelist)),
    io:fwrite("~p - ~p - ~p\n",[Pred,Curr,Suc]),
    Temp = #{Curr=>{Pred,Suc}},
    
    
    SucPred = persistent_term:get(sucpred),
    Newmp = maps:merge(SucPred,Temp),
    persistent_term:put(sucpred,Newmp),

    find_successor(I-1,Numnodes).








%-------------------------------------------Initial Table-------------------------------------
% initFingerTable(NodeId,Table) ->
%     M = persistent_term:get(m),
%     Tab = fingerLoop(M, M,Table,NodeId),
%     persistent_term:put(predecessor, NodeId),
%     Tab.

% fingerLoop(0, M, NewTable,_) ->
%     NodeId = persistent_term:get(nodeId),
%     persistent_term:put(predecessor, NodeId),

%     NewTable;
% fingerLoop(I, M,Table,NodeId) ->
   
%     X =math:fmod((0 + trunc(math:pow(2, M-I))), trunc(math:pow(2, M))),
%     Finger2 = #{M-I =>{ X,NodeId}},
%     NewTable = maps:merge(Table, Finger2),
    
%     fingerLoop(I - 1, M,NewTable,NodeId).
%----------------------------------------------------------------------------------------------- 
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

%--------------------------------------------------------------------------------------------------

initfinger(0,_)->
    mid ! {"dff","fdf","dfdf","f"};

initfinger(I,N)->
 
    M=persistent_term:get(m),

    Finger = persistent_term:get(finger),
    Index = N-I,
    Check=Index,
    Emptymp=#{},
    Filled_table=buildtable(M,M,Index,Emptymp,Check),
    Temp = #{Index=>Filled_table},
    NewTemp = maps:merge(Temp,Finger),
    io:fwrite("~p\n",[NewTemp]),
    persistent_term:put(finger,NewTemp),


initfinger(I-1,N).


buildtable(0,_,_,NewTemp,_)->
    NewTemp;

buildtable(I,M,Index,Map,Check)->
   
    Nodelist = persistent_term:get(node),
    Ele = element(1,maps:get(Check,Nodelist)),
    SucPred = persistent_term:get(sucpred),
    X =math:fmod((Index + trunc(math:pow(2, M-I))), trunc(math:pow(2, M))),
    SucPred = persistent_term:get(sucpred),
    Succ = element(2,maps:get(Ele,SucPred)),
    % io:fwrite("~p-~p-~p",[Index,X,Succ]),
    if X < Succ orelse X == Succ -> 
        Temp = #{X=>Succ},
        NewTemp = maps:merge(Temp,Map),
        buildtable(I-1,M,Index,NewTemp,Check);
    true ->
        buildtable(I,M,Index,Map,Check+1)
    end.











% join(FirstHash) ->
%     Found = exists(FirstHash),
%     if
%         Found == true ->
%             initFingerTable_join(FirstHash),
%             update_nodes();
%         true ->
%             M = persistent_term:get(m),
%             forUpdate(0, M)
%     end.

% initFingerTable_join(FirstHash) ->
    

% exists(FirstHash) ->
%     NodeId = persistent_term:get(nodeId),
%     if
%         FirstHash == NodeId ->
%             true;
%         true ->
%             false
%     end.



% initFingerTable(N,Pid,Table,PList)->
%     N_future = find_successor(Pid),
    
%     Tup = maps:get(0,Table),
%     X = element(1,Tup),
%     TempTup = {X,N_future},
%     NewTable  = maps:update(0,TempTup,Table),

%     %add Plist[2] (successor) = N_future. Plist is the list of provate variables. 

%     M_future = find_predecessor(N_future),
%      %add Plist[3] (predecessor) = M_future. Plist is the list of provate variables. 
%      N_future ! {set_predecessor,self()},
%         M = persistent_term:get(m),
%      {PListv1, Tablev1}= forinitfinger(PList,NewTable,M-2,M-2),


% forinitfinger(PList,NewTable,_,0)->
%     {PList,NewTable};

% forinitfinger(PList,NewTable,M,I) ->

%     % Id  = NodeId (PList[4] = NodeId)
%     Id  =NodeId + Math:pow(2,M-I+1),
%     Finger_i = NodeId + Math:pow(2,M-I),
%     Actor_finger_i_node = element(2,maps:get(M-I,NewTable))
%     Bool = isWithinRangeFirstOpen(NodeId,)
%     if Bool =true ->
%         %finger(i+1)(1) = finger(i)(1);
    
%     true->
%         %  var o_actor = getActorRef(n)
%         %           var o_future = o_actor ? Find_Sucessor(finger(i+1)(0));
%         %           finger(i+1)(1) =  Await.result(o_future,timeout.duration).asInstanceOf[Int]

% forinintfinger(PList,NewTable,M,I-1).


% find_successor(Pid)->
%     sds.