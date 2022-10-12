-module(gossip).
-import(top,[create_neighbors/3,setup2d/3,setup3d/3,assign/3,random_loop/3]).
-compile(export_all).

start(Num, Top, Algo) ->

    if
        Top == twod ->
            PlaneSize = Num,
            RowSize = trunc(math:sqrt(PlaneSize)),
            persistent_term:put(plane, PlaneSize),
            persistent_term:put(row, RowSize);
        Top == threed ->
            PlaneSize = 25,
            RowSize = 5,
            persistent_term:put(plane, PlaneSize),
            persistent_term:put(row, RowSize);
        true ->
            ok
    end,
    Node_list = [],
    Neighbor_Map = #{},
    Node_map = #{},
    Rumour_map = #{},
    Fin_List = [],
    Weights_map = #{},
    Index_map = #{},
    Int =0,
    SelfInt = 0,
    persistent_term:put(en,Int),
    
    persistent_term:put(map, Node_map),
    persistent_term:put(list, Node_list),
    persistent_term:put(rmap, Rumour_map),
    persistent_term:put(fin, Fin_List),
    persistent_term:put(neighbor, Neighbor_Map),
    persistent_term:put(weights, Weights_map),
    persistent_term:put(index, Index_map),
    register(sid, spawn(gossip, send_self, [])),
    register(mid, spawn(gossip, master, [Num, Top, Algo, Num])),
    % Full - 10,
    % Line - 10,
    % 2D - 9,
    % 3D - 8 (if you want it quicker)
    register(lastid, spawn(gossip, last, [Num])).

master(Num, Top, Algo, Threshold) ->
    Node_list = persistent_term:get(list),
    Node_map = persistent_term:get(map),
    Rumour_map = persistent_term:get(map),
    Weights_map = persistent_term:get(weights),
    Neighbor_map = persistent_term:get(neighbor),
    Index_map = persistent_term:get(index),
   
    for(
        Num,
        Node_list,
        Node_map,
        Rumour_map,
        Weights_map,
        Neighbor_map,
        Index_map,
        Algo,
        Threshold,
        1,
        Top
    ),
    if
        Top == full ->
            receive
                {_Pid, Msg} ->
                    if
                        Msg == finished ->
                            io:format("Wieghts: ~p~n", [persistent_term:get(weights)]),
                            L = persistent_term:get(list),
                            [Head | _Tail] = L,
                             statistics(runtime),
                                statistics(wall_clock),
                            Head ! {self(), initial};
                        true ->
                            ok
                    end
            end;
        Top == line ->
            receive
                {_Pid, Msg} ->
                    if
                        Msg == finished ->
                            NL = persistent_term:get(list),
                            NM = persistent_term:get(neighbor),
                            create_neighbors(NL, NM, 1),
                            receive
                                {_Message} ->
                                    NM2 = persistent_term:get(neighbor),
                                    io:format("Neighbors: ~p~n", [NM2]),
                                    L = persistent_term:get(list),
                                    [Head | _Tail] = L,
                                     statistics(runtime),
                                     statistics(wall_clock),
                                    Head ! {self(), initial}
                            end;
                        true ->
                            ok
                    end
            end;
        Top == twod ->
            receive
                {_Pid, Msg} ->
                    if
                        Msg == finished ->
                            setup2d(Num, 1, Threshold),
                            receive
                                {_Message} ->
                                    NM2 = persistent_term:get(neighbor),
                                    io:format("Neighbors: ~p~n", [NM2]),
                                    L = persistent_term:get(list),
                                    [Head | _Tail] = L,
                                     statistics(runtime),
                                    statistics(wall_clock),
                                    Head ! {self(), initial}
                            end;
                        true ->
                            ok
                    end
            end;
        Top == threed ->
            receive
                {_Pid, Msg} ->
                    if
                        Msg == finished ->
                            setup2d(Num, 1, Threshold),
                            receive
                                {_Message} ->
                                    setup3d(Num, 1, Threshold),
                                    receive
                                        {_Msg} ->
                                            % assign(Num, 1, Threshold),
                                            % receive
                                            %     {_Msg2} ->
                                                    NM2 = persistent_term:get(neighbor),
                                                    io:format("Neighbors: ~p~n", [NM2]),
                                                    L = persistent_term:get(list),
                                                    [Head | _Tail] = L,
                                                     statistics(runtime),
                                                        statistics(wall_clock),
                                                    Head ! {self(), initial}
                                            % end
                                    end
                            end;
                        true ->
                            ok
                    end
            end;
        true ->
            ok
    end.

for(0,Node_list,Node_map,Rumour_map,Weights_map,Neighbor_map,Index_map,Algo,Threshold, Index,Top
) ->
    persistent_term:put(map, Node_map),
    persistent_term:put(list, Node_list),
    persistent_term:put(rmap, Rumour_map),
    persistent_term:put(weights, Weights_map),
    persistent_term:put(neighbor, Neighbor_map),
    persistent_term:put(index, Index_map),
    mid ! {self(), finished},
    ok;
for(
    N,
    Node_list,
    Node_map,
    Rumour_map,
    Weights_map,
    Neighbor_map,
    Index_map,
    Algo,
    Threshold,
    Index,
    Top
) ->
    Pid = spawn(gossip, Algo, [Top, Threshold]),
    L = [Pid],
    M = #{Pid => 0},
    R = #{Pid => false},
    W = #{Pid => {Index, 1}},
    NM = #{Pid => []},
    I = #{Pid => Index},
    New_list = L ++ Node_list,
    New_map = maps:merge(M, Node_map),
    RNew_map = maps:merge(R, Rumour_map),
    WNew_map = maps:merge(W, Weights_map),
    NNew_map = maps:merge(NM, Neighbor_map),
    INew_map = maps:merge(I, Index_map),
    persistent_term:put(map, New_map),
    persistent_term:put(rmap, RNew_map),
    persistent_term:put(list, New_list),
    persistent_term:put(weights, WNew_map),
    persistent_term:put(index, INew_map),
    persistent_term:put(neighbor, WNew_map),

    for(
        N - 1,
        New_list,
        New_map,
        RNew_map,
        WNew_map,
        NNew_map,
        INew_map,
        Algo,
        Threshold,
        Index + 1,
        Top
    ).



last(Num) ->
    Int = persistent_term:get(en),
    if Int ==Num ->
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
    receive
        {khatam} ->
            Mega_map = persistent_term:get(map),
            Nint = Int+1,
            persistent_term:put(en,Nint)
            % io:format("Map: ~p~n", [Mega_map])
    end,
    last(Num).

gossip(Top, Threshold) ->
    %Checks if finished_list has all the 10 elements
   
    
    Fin_List = persistent_term:get(fin),
    L1 = persistent_term:get(list),
    RMap = persistent_term:get(rmap),
    io:fwrite("~p~n", [Fin_List]),
    Bool = maps:find(self(), RMap),
    Check = lists:member(self(), Fin_List),
    if
        Bool == {ok, true} ->
            % io:fwrite("~p",[Check]),
            if
                Check == false ->
                    LL = persistent_term:get(list),
                    Rand = random_loop(self(), LL, Top),
                    Rand ! {self(), "rumour"};
                true ->
                    ok
            end;
        true ->
            ok
    end,
  

         
   
    receive
        {_Mid, _Msg, initial} ->
            Map = persistent_term:get(map),
            {ok, Val} = maps:find(self(), Map),
            NVal = Val + 1,
            M = maps:update(self(), NVal, Map),
            persistent_term:put(map, M),

            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R);
        {_Id, _Msg} ->
            Map = persistent_term:get(map),
            {ok, Val} = maps:find(self(), Map),

            NVal = Val + 1,
            M = maps:update(self(), NVal, Map),
            persistent_term:put(map, M),

            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R),

            % io:fwrite("received from ~p ~p\n", [_Id, self()]),
            % io:fwrite("~p\n", [M]),

            if
                NVal < 10 ->
                    gossip(Top, Threshold);
                NVal == 10 ->
                    F_List = persistent_term:get(fin),
                    Boolean = lists:member(self(), F_List),
                    if
                        Boolean == false ->
                            FL = [self()],
                            F = F_List ++ FL,
                            persistent_term:put(fin, F);
                        true ->
                            ok
                    end;
                true ->
                    ok
            end

            % if Top == full andalso NVal ==10 ->
                
            %     L2 = lists:delete(self(),L1),
            %     persistent_term:put(list,L2);
            % true ->
            %     ok
            % end;
        % {_Pid} ->
          

      after 1 ->
        % sid ! {self(), "self"}

            F_List = persistent_term:get(fin),
            X = length(F_List),
            if
                Top == line orelse Top == twod orelse Top == threed ->
                    Neighbor = persistent_term:get(neighbor),
                    Is_key = maps:is_key(self(), Neighbor),

                    Finlen = length(F_List),

                    if
                        Is_key == true ->
                            if
                                Finlen =/= 0 ->
                                    N_list = maps:get(self(), Neighbor),
                                    Y = length(N_list),
                                     converge(N_list, self(), Y);
                                % io:fwrite("~p\n",[K]);
                                true ->
                                    d
                            end;
                        true ->
                            ok
                    end;
                true ->
                    ok
            end,
            if
                X == Threshold->
                    io:format("Finished List: ~p~n", [F_List]),
                    % Mega_map = persistent_term:get(map),
                    % io:format("Map: ~p~n", [Mega_map]),
                    lastid ! {khatam},
                    exit("bas");
                true ->
                    gossip(Top, Threshold)
            end
      
           

    
    end,
    gossip(Top, Threshold).







% _____________________________________
% _____________________________________
% _____________________________________
% _____________________________________
% _____________________________________




push_sum(Top, Threshold) ->
    Fin_List = persistent_term:get(fin),

    RMap = persistent_term:get(rmap),
    io:fwrite("~p~n", [Fin_List]),
    Bool = maps:find(self(), RMap),
    Check = lists:member(self(), Fin_List),
    if
        Bool == {ok, true} ->
            % io:fwrite("~p",[Check]),
            if
                Check == false ->
                    LL = persistent_term:get(list),
                    Weights_map = persistent_term:get(weights),
                    {Sum, Weight} = maps:get(self(), Weights_map),
                    Rand = random_loop(self(), LL, Top),
                    Rand ! {self(), Sum, Weight};
                true ->
                    ok
            end;
        true ->
            ok
    end,

    % sid ! {self(), "self"},
    receive
        {Id, initial} ->
            Weights_map3 = persistent_term:get(weights),
            {S2, W2} = maps:get(self(), Weights_map3),
            NewS = S2 / 2,
            NewW = W2 / 2,
            Weights_map2 = maps:update(self(), {NewS, NewW}, Weights_map3),
            persistent_term:put(weights, Weights_map2),
            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R),

            Random_node = random_loop(self(), persistent_term:get(list), Top),
            Random_node ! {self(), NewS, NewW};
        {_Pid, S, W} ->
            Weights_map3 = persistent_term:get(weights),
            {Pid_Sum, Pid_Weight} = maps:get(self(), Weights_map3),
            % io:fwrite("sum: ~p~n, Weight: ~p~n", [Pid_Sum, Pid_Weight]),
            NewSum = Pid_Sum + S,
            NewWeight = Pid_Weight + W,

            if
                W /= 0.0 ->
                    Change = abs(NewSum / NewWeight - S / W),
                    Delta = math:pow(10, -10),
                    if
                        Change < Delta ->
                            Node_map = persistent_term:get(map),
                            TermRound = maps:get(self(), Node_map),
                            Node_map2 = maps:update(self(), TermRound + 1, Node_map),
                            persistent_term:put(map, Node_map2);
                        true ->
                            Node_map = persistent_term:get(map),
                            Node_map2 = maps:update(self(), 0, Node_map),
                            persistent_term:put(map, Node_map2)
                    end,
                    Node_map3 = persistent_term:get(map),
                    TermRound2 = maps:get(self(), Node_map3),
                    if
                        TermRound2 == 3 ->
                            Fin_List = persistent_term:get(fin),
                            Fin_List2 = lists:append(Fin_List, [self()]),
                            persistent_term:put(fin, Fin_List2);
                        true ->
                            ok
                    end;
                true ->
                    ok
            end,
            Weights_map2 = maps:update(self(), {NewSum, NewWeight}, Weights_map3),
            persistent_term:put(weights, Weights_map2),
            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R),

            Random_node = random_loop(self(), persistent_term:get(list), Top),
            Random_node ! {self(), NewSum / 2, NewWeight / 2};
        {_Pid} ->
            F_List = persistent_term:get(fin),
            X = length(F_List),
            if
                Top == line orelse Top == twod orelse Top == threed ->
                    Neighbor = persistent_term:get(neighbor),
                    Is_key = maps:is_key(self(), Neighbor),

                    Finlen = length(F_List),

                    if
                        Is_key == true ->
                            if
                                Finlen =/= 0 ->
                                    N_list = maps:get(self(), Neighbor),
                                    Y = length(N_list),
                                    K = converge(N_list, self(), Y);
                                % io:fwrite("~p\n",[K]);
                                true ->
                                    d
                            end;
                        true ->
                            ok
                    end;
                true ->
                    ok
            end,
            if
                X == Threshold ->
                    io:format("Finished List: ~p~n", [F_List]),
                    % Mega_map = persistent_term:get(map),
                    % io:format("Map: ~p~n", [Mega_map]),
                    lastid ! {khatam},
                    exit(bas);
                true ->
                    gossip(Top, Threshold)
            end,
            Finished_List = persistent_term:get(fin),
            X = length(Finished_List),
            if
                X == Threshold ->
                    lastid ! {khatam},
                    exit(bas);
                true ->
                    push_sum(Top, Threshold)
            end
    end,
    push_sum(Top, Threshold).

converge(_, Node_id, 0) ->
    % F_List = persistent_term:get(fin),
    % Boolean = lists:member(Node_id, F_List),
    % if
    %     Boolean == false ->
            % FL = [Node_id],
            % F = F_List ++ FL,
            % persistent_term:put(fin, F);
            Map = persistent_term:get(map),
            {ok, Val} = maps:find(self(), Map),

            NVal = Val + 1,
            if
            NVal == 10 ->
                    F_List = persistent_term:get(fin),
                    Boolean = lists:member(self(), F_List),
                    if
                        Boolean == false ->
                            FL = [self()],
                            F = F_List ++ FL,
                            persistent_term:put(fin, F);
                        true ->
                            ok
                    end;
            true ->
                ok
            end,
            M = maps:update(self(), NVal, Map),
            persistent_term:put(map, M),
            io:fwrite("~p",[M]),

            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R);



    %     true ->
    %         ok
    % end;



converge(N_list, Node_id, Len) ->
    F_list = persistent_term:get(fin),
    [Head | Tail] = N_list,

    Chk = lists:member(Head, F_list),
    % io:fwrite("~p\n", [Chk]),
    if
        Chk == true ->
            converge(Tail, Node_id, Len - 1);
        true ->
            f
    end.