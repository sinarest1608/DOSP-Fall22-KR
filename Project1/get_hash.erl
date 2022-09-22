-module(get_hash).

% -export([main/2, hash_work/1]).
-export([ hash_work/2]).

% main(LoopCount, Zeros_required) ->
%     % hash_work(3).
%     for(LoopCount, Zeros_required).

% for(0, Zeros_required) ->
%     Zeros_required,
%     ok;
% for(N, Zeros_required) ->
    
%     hash_work(Zeros_required),
%     for(N-1, Zeros_required).


hash_work(Zeros_required, MasterId) ->
    %TODO: Add Master Msg send
    UFID = "sinha.kshitij",
    
    Random = binary_to_list((base64:encode(crypto:strong_rand_bytes(10)))),
    RandomStr = binary_to_list(re:replace(Random, "\\W", "", [global, {return, binary}])),
    % io:fwrite("~p", [Random]),
    % io:fwrite("~p", [UFID ++ Random]),
    % io:write(base64:encode(crypto:strong_rand_bytes(10))).
    Crypt = io_lib:format("~64.16.0b",[binary:decode_unsigned(crypto:hash(sha256, UFID ++ RandomStr))]),
    % io:fwrite("~p", [Crypt]),
    Crypt_leading = string:sub_string(Crypt, 1, Zeros_required),
    ZeroList = lists:duplicate(Zeros_required,"0"),
    ZeroVar = string:join(ZeroList, ""),
    if(Crypt_leading == ZeroVar) ->
        % io:fwrite("~p", [RandomStr]),
        % % io:fwrite("~p\t", " "),
        % io:fwrite("~p", [UFID ++ RandomStr]),
        % % io:fwrite("~p\t", " "),
        % io:fwrite("~p", [Crypt]),
        % io:fwrite("~p\n", [""]);
        MasterId ! {UFID++RandomStr, Crypt, self()};
       
    true ->
        hash_work(Zeros_required, MasterId)
    end.


    % io:fwrite("~p", [Crypt]).
    % input := ufid ++ randString.
    % io:write(input).

