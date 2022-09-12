-module(get_hash).

-export([main/0]).

main() ->
    for(10).

for(-1) ->
    ok;
for(N) ->
    
    hash_work(),
    for(N-1).


hash_work() ->

    UFID = "sinha.kshitij",
    Random = binary_to_list(base64:encode(crypto:strong_rand_bytes(10))),
    % io:fwrite("~p", [Random]),
    % io:fwrite("~p", [UFID ++ Random]),
    % io:write(base64:encode(crypto:strong_rand_bytes(10))).
    Crypt = io_lib:format("~64.16.0b",[binary:decode_unsigned(crypto:hash(sha256, UFID ++ Random))]),
    % io:fwrite("~p", [Crypt]),
    Crypt_leading = string:sub_string(Crypt, 1, 3),
    if(Crypt_leading == "000") ->
        io:fwrite("~p", [Random]),
        io:fwrite("~p\t", " "),
        io:fwrite("~p", [UFID ++ Random]),
        io:fwrite("~p\t", " "),
        io:fwrite("~p", [Crypt]),
        io:fwrite("~p\n", " ");
       
    true ->
        hash_work()
    end.


    % io:fwrite("~p", [Crypt]).
    % input := ufid ++ randString.
    % io:write(input).

