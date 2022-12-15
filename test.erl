-module(test).

-compile(export_all).


run() ->
    
    Tweet = "@user hello #world",
    Tag = string:str(Tweet, "#"),
    HashString = string:sub_string(Tweet, Tag),

    io:fwrite("~p ~p",[S, HashString]).