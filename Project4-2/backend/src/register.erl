-module(backend_handler).
-behavior(cowboy_handler).

-export([init/2]).
-compile(export_all).
-import(twitter, [getdata/0, registerUser/2, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0, ]).

init(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
    {_, UserName} = lists:keyfind(<<"name">>, 1, InputParams),
    FunctionResponse = twitter:registerUser(UserName, 123),
	Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Hello Erlang!">>,
        Req0),
	{ok, Req, State}.
