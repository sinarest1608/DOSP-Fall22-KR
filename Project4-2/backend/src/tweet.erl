-module(tweet).
-behavior(cowboy_handler).

-export([init/2]).
-compile(export_all).
-import(twitter, [getdata/0, tweet/1, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0, ]).

tweet(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
    
	{_, Tweet} = lists:keyfind(<<"tweet">>, 1, InputParams),
    FunctionResponse = twitter:tweet(Tweet),
	if FunctionResponse ->
		Req = cowboy_req:reply(200,
			#{<<"content-type">> => <<"text/plain">>},
			<<"ReTweet is Live!">>,
			Req0)
	true ->
		Req = cowboy_req:reply(404,
			#{<<"content-type">> => <<"text/plain">>},
			<<"Error Tweeting!">>,
			Req0),	
	{ok, Req, State}.