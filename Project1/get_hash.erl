-module(get_hash).

-export([main/0]).

main() ->
    % hash_work(3).
    for(30, 4).

for(-1, Zeros_required) ->
    ok;
for(N, Zeros_required) ->
    
    hash_work(Zeros_required),
    for(N-1, Zeros_required).


hash_work(Zeros_required) ->

    UFID = "sinha.kshitij",
    Random = binary_to_list(base64:encode(crypto:strong_rand_bytes(10))),
    % io:fwrite("~p", [Random]),
    % io:fwrite("~p", [UFID ++ Random]),
    % io:write(base64:encode(crypto:strong_rand_bytes(10))).
    Crypt = io_lib:format("~64.16.0b",[binary:decode_unsigned(crypto:hash(sha256, UFID ++ Random))]),
    % io:fwrite("~p", [Crypt]),
    Crypt_leading = string:sub_string(Crypt, 1, Zeros_required),
    ZeroList = lists:duplicate(Zeros_required,"0"),
    ZeroVar = string:join(ZeroList, ""),
    if(Crypt_leading == ZeroVar) ->
        io:fwrite("~p", [Random]),
        % io:fwrite("~p\t", " "),
        io:fwrite("~p", [UFID ++ Random]),
        % io:fwrite("~p\t", " "),
        io:fwrite("~p", [Crypt]),
        io:fwrite("~p\n", [""]);
       
    true ->
        hash_work(Zeros_required)
    end.


    % io:fwrite("~p", [Crypt]).
    % input := ufid ++ randString.
    % io:write(input).

