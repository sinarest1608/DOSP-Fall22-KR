-module(register).
-behavior(cowboy_handler).

-export([register/2]).
-compile(export_all).
-import(twitter, [getdata/0, registerUser/2, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0 ]).

register(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
    {_, UserName} = lists:keyfind(<<"username">>, 1, InputParams),
    {_, Password} = lists:keyfind(<<"password">>, 1, InputParams),
    {_, Name} = lists:keyfind(<<"displayName">>, 1, InputParams),
    FunctionResponse = twitter:registerUser(UserName, Password, Name),
	Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Registered!">>,
        Req0),
	{ok, Req, State}.
