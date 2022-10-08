-module(test).

-export([start/0, master/1, for/4, gossip/0, random_loop/2,send_self/0]).

start() ->
    Node_list = [],
    Node_map = #{},
    Rumour_map = #{},
    persistent_term:put(map, Node_map),
    persistent_term:put(list, Node_list),
    persistent_term:put(rmap, Rumour_map),
    register(sid,spawn(gos,send_self,[])),
    register(mid, spawn(gos, master, [10])).



master(Num) ->
    Node_list = persistent_term:get(list),
    Node_map = persistent_term:get(map),
    Rumour_map = persistent_term:get(map),
    for(Num, Node_list, Node_map, Rumour_map),
    receive
        {_Pid, Msg} ->
            if
                Msg == finished ->
                    L = persistent_term:get(list),
                    M = persistent_term:get(map),
                    List_size = length(L),
                    [Head | Tail] = L,
                    Head ! {self(), "FTW", initial};
                    
                true ->
                    ok
            end
    end.


send_self() ->
    receive
        {From,Msg}->
           
            From ! {self()}
    end,
    send_self().
    


for(0, Node_list, Node_map, Rumour_map) ->
    persistent_term:put(map, Node_map),
    persistent_term:put(list, Node_list),
    persistent_term:put(rmap, Rumour_map),
    mid ! {self(), finished},
    ok;
for(N, Node_list, Node_map, Rumour_map) ->
    Pid = spawn(gos, gossip, []),
    L = [Pid],
    M = #{Pid => 0},
    R = #{Pid => false},
    New_list = L ++ Node_list,
    New_map = maps:merge(M, Node_map),
    RNew_map = maps:merge(R, Rumour_map),
    persistent_term:put(map, New_map),
    persistent_term:put(rmap, RNew_map),
    persistent_term:put(list, New_list),

    for(N - 1, New_list, New_map, RNew_map).

random_loop(Node_id, Node_list) ->
    Random_node = lists:nth(rand:uniform(length(Node_list)), Node_list),
    if
        Random_node == Node_id ->
            random_loop(Node_id, Node_list);
        true ->
            % receive
            %     {From, Msg} ->
            %         io:fwrite("~p~n", [Msg]),
            %         From ! {Random_node, rumor_received}
            % end
            Random_node
    end.

gossip() ->
    RMap = persistent_term:get(rmap),
    % io:fwrite("~p~n", [RMap]),
    Bool = maps:find(self(), RMap),
    
    if
        Bool == {ok,true} ->
            LL = persistent_term:get(list),
            Rand = random_loop(self(), LL),
            Rand ! {self(), "rumour"};
        true ->
            ok
    end,
   
   sid ! {self(),"self"},
    receive
        {_Mid, _Msg, initial} ->
            Map = persistent_term:get(map),
            {ok, Val} = maps:find(self(), Map),
            %  io:fwrite("fjfkejhfefhekjfhef ~p\n",[Val]),
            NVal = Val + 1,
            M = maps:update(self(), NVal, Map),
            persistent_term:put(map, M),

            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R);

            
            
        {Id, Msg} ->
            Map = persistent_term:get(map),
            {ok, Val} = maps:find(self(), Map),
            
            NVal = Val + 1,
            M = maps:update(self(), NVal, Map),
            persistent_term:put(map, M),

            RMap2 = persistent_term:get(rmap),
            R = maps:update(self(), true, RMap2),
            persistent_term:put(rmap, R),

            io:fwrite("received from ~p ~p\n", [Id, self()]),
            io:fwrite("~p\n",[M]),

            if
                NVal < 10 ->
                    gossip();
                true ->
                    % List = persistent_term:get(list),
                    % Ran = random_loop(self(), List),
                    % Ran ! {self(), "rumour"},
                 
                    
            end;
        {_Pid} ->
            gossip()
    end,
    gossip().