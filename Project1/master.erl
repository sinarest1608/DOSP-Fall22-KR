-module(master).

-export([runner/0, spawn_actor/2, message_actor/3, send_from_master/0, hash_work/4, hash_loop/3]).

spawn_actor(0, _) ->     
    
    ok;
spawn_actor(Number, Master_Node) ->
    statistics(runtime),
    statistics(wall_clock),
    spawn(master, message_actor, [1, Master_Node, Number]),

    spawn_actor(Number - 1, Master_Node).


hash_loop(0, _, _) ->
    ok;

hash_loop(K, Master_Node, ActorNumber) ->
    hash_work(4, Master_Node, ActorNumber, K),
    hash_loop(K-1, Master_Node, ActorNumber).

message_actor(0, _, _) ->
    

    ok;
message_actor(N, Master_Node, ActorNumber) ->
    {master_ID, Master_Node} ! {spawned, self()},
    % io:fwrite("Sent spawn msg to master\n"),
    receive
        {Do_hash, PID} ->
            
            hash_loop(1000, Master_Node, ActorNumber) % Work Units!!%
            
    end,
    message_actor(N - 1, Master_Node, ActorNumber-1).

send_from_master() ->
    receive
        {Spawned, ActorID} ->
            % io:fwrite("received spawn msg\n"),
            ActorID ! {do_hash, self()};
        {String, CoinMined, ActorID} ->
            io:fwrite("Coin Found by Worker"),
            io:fwrite("~p", [String]),
            io:fwrite(" "),
            io:fwrite("~p", [CoinMined]),
            io:fwrite(" "),
            io:fwrite("~p", [ActorID]),
            io:fwrite("\n")
    
    end,
    send_from_master().

hash_work(Zeros_required, Master_Node, ActorNumber, WorkUnits) ->
    %TODO: Add Master Msg send
    UFID = "sinha.kshitij",

    Random =
        binary_to_list(base64:encode(
                           crypto:strong_rand_bytes(10))),
    RandomStr = binary_to_list(re:replace(Random, "\\W", "", [global, {return, binary}])),
    % io:fwrite("~p", [Random]),
    % io:fwrite("~p", [UFID ++ Random]),
    % io:write(base64:encode(crypto:strong_rand_bytes(10))).
    Crypt =
        io_lib:format("~64.16.0b",
                      [binary:decode_unsigned(
                           crypto:hash(sha256, UFID ++ RandomStr))]),
    % io:fwrite("~p", [Crypt]),
    Crypt_leading = string:sub_string(Crypt, 1, Zeros_required),
    ZeroList = lists:duplicate(Zeros_required, "0"),
    ZeroVar = string:join(ZeroList, ""),
    if Crypt_leading == ZeroVar ->
           % io:fwrite("~p", [RandomStr]),
           % % io:fwrite("~p\t", " "),
           % io:fwrite("~p", [UFID ++ RandomStr]),
           % % io:fwrite("~p\t", " "),
           % io:fwrite("~p", [Crypt]),
           % io:fwrite("~p\n", [""]);
           Str = UFID ++ RandomStr,
           {master_ID,  Master_Node} ! {Str, Crypt, self()},
           if (ActorNumber-1 == 0) and (WorkUnits-1 == 0) ->
            {_, Time1} = statistics(runtime),
            {_, Time2} = statistics(wall_clock),
            U1 = Time1 * 1000,
            U2 = Time2 * 1000,
            io:format("Code time=~p (~p) microseconds~n",
            [U1,U2]);

    true ->
        ok
    end;
       true ->
           hash_work(Zeros_required, Master_Node, ActorNumber, WorkUnits)
    % end,
    

end.
    

    
% master_loop(0, MiD) ->
%     ok;
% master_loop(N, MiD) ->
%     hash_work(3, MiD),
%     master_loop(N-1, MiD).


runner() ->
    
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(master, send_from_master, [])).
    

    
    % master_loop(100, master_ID).
    % spawn_actor(10).
    
