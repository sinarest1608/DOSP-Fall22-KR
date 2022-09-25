-module(master).

-export([runner/0, spawn_actor/2, message_actor/3, send_from_master/1, hash_work/4, hash_loop/4]).

spawn_actor(0, _) ->     
    ok;

spawn_actor(Number, Master_Node) ->
    statistics(runtime),
    statistics(wall_clock),
    
    spawn(master, message_actor, [1, Master_Node, Number]),
    spawn_actor(Number - 1, Master_Node).


hash_loop(0, _, _, _) ->
    ok;

hash_loop(K, Master_Node, ActorNumber, Zeroes) ->
    hash_work(Zeroes, Master_Node, ActorNumber, K),
    hash_loop(K-1, Master_Node, ActorNumber, Zeroes).

message_actor(0, _, _) ->
    ok;
message_actor(N, Master_Node, ActorNumber) ->
    {master_ID, Master_Node} ! {spawned, self()},
    receive
        {Do_hash, PID, Zeroes} ->
            
            hash_loop(10000, Master_Node, ActorNumber, Zeroes) % Work Units!!%
            
    end,
    message_actor(N - 1, Master_Node, ActorNumber-1).

send_from_master(Zeroes) ->
    
    receive
        {Spawned, ActorID} ->
            ActorID ! {do_hash, self(), Zeroes};
        {String, CoinMined, ActorID} ->
            io:fwrite("Coin Found by Worker"),
            io:fwrite("~p", [String]),
            io:fwrite(" "),
            io:fwrite("~p", [CoinMined]),
            io:fwrite(" "),
            io:fwrite("~p", [ActorID]),
            io:fwrite("\n")
    
    end,
    send_from_master(Zeroes).

hash_work(Zeros_required, Master_Node, ActorNumber, WorkUnits) ->
    UFID = "sinha.kshitij",

    Random =
        binary_to_list(base64:encode(
                           crypto:strong_rand_bytes(10))),
    RandomStr = binary_to_list(re:replace(Random, "\\W", "", [global, {return, binary}])),
    Crypt =
        io_lib:format("~64.16.0b",
                      [binary:decode_unsigned(
                           crypto:hash(sha256, UFID ++ RandomStr))]),
    Crypt_leading = string:sub_string(Crypt, 1, Zeros_required),
    ZeroList = lists:duplicate(Zeros_required, "0"),
    ZeroVar = string:join(ZeroList, ""),
    if Crypt_leading == ZeroVar ->
           Str = UFID ++ RandomStr,

        % if(Master_Node == "Master")->
        %     io:fwrite("Coin Found by MAster"),
        %     io:fwrite("~p", [Str]),
        %     io:fwrite(" "),
        %     io:fwrite("~p", [Crypt]),
        %     io:fwrite(" ");
        % true ->
            {master_ID,  Master_Node} ! {Str, Crypt, self()},
            if ((ActorNumber-1 == 0) and (WorkUnits-1 == 0)) ->
             {_, Time1} = statistics(runtime),
             {_, Time2} = statistics(wall_clock),
             U1 = Time1 * 1000,
             U2 = Time2 * 1000,
             io:format("Code time=~p (~p) microseconds~n",[U1,U2]) ;

        % end;
           

    true ->
        ok
    end;
       true ->
           hash_work(Zeros_required, Master_Node, ActorNumber, WorkUnits)

end.
    

    
master_loop(_, 0, _) ->
    ok;
master_loop(Zeroes, WorkUnit, MiD) ->
    hash_work(Zeroes, MiD, 10, WorkUnit),
    master_loop(Zeroes, WorkUnit-1, MiD).


runner() ->
    
    {ok, Z} = io:read("Enter Number of Zeros "),
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(master, send_from_master, [Z])).
    
    
    
