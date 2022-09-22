-module(master).

-export([runner/0, spawn_actor/2, message_actor/2, send_from_master/0, hash_work/2]).

spawn_actor(0, Master_Node) ->
    ok;
spawn_actor(Number, Master_Node) ->
    spawn(master, message_actor, [1, Master_Node]),

    spawn_actor(Number - 1, Master_Node).

message_actor(0, Master_Node) ->
    ok;
message_actor(N, Master_Node) ->
    {master_ID, Master_Node} ! {spawned, self()},
    % io:fwrite("Sent spawn msg to master\n"),
    receive
        {Do_hash, PID} ->
            % io:fwrite("REceived do_hash from master\n"),
            hash_work(4, Master_Node)
    end,
    message_actor(N - 1, Master_Node).

send_from_master() ->
    receive
        {Spawned, ActorID} ->
            % io:fwrite("received spawn msg\n"),
            ActorID ! {do_hash, self()};
        {String, CoinMined, ActorID} ->
            io:fwrite("Coin Found "),
            io:fwrite("~p", [String]),
            io:fwrite(" "),
            io:fwrite("~p", [CoinMined]),
            io:fwrite(" "),
            io:fwrite("~p", [ActorID]),
            io:fwrite("\n")
    end,
    send_from_master().

hash_work(Zeros_required, Master_Node) ->
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
           {master_ID,  Master_Node} ! {Str, Crypt, self()};
       true ->
           hash_work(Zeros_required, Master_Node)
    end.

    
% master_loop(0, MiD) ->
%     ok;
% master_loop(N, MiD) ->
%     hash_work(3, MiD),
%     master_loop(N-1, MiD).


runner() ->
    statistics(runtime),
    statistics(wall_clock),
    % Master_ID = spawn(master, , []),
    
    register(master_ID, spawn(master, send_from_master, [])).
    

    
    % master_loop(100, master_ID).
    % spawn_actor(10).
    
