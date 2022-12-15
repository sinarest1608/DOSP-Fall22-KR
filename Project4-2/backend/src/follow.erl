-module(follow).
-behavior(cowboy_handler).

-export([init/2]).
-compile(export_all).
-import(twitter, [getdata/0, follow/2, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0, ]).

follow(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
	{_, CurrentUser} = lists:keyfind(<<"currentUser">>, 1, InputParams),
	{_, FollowUser} = lists:keyfind(<<"followUser">>, 1, InputParams),
    FunctionResponse = twitter:follow(CurrentUser, FollowUser),
	if FunctionResponse ->

		Req = cowboy_req:reply(200,
			#{<<"content-type">> => <<"text/plain">>},
			<<"User Followed!">>,
			Req0)
	true ->
		Req = cowboy_req:reply(404,
			#{<<"content-type">> => <<"text/plain">>},
			<<"User not Found">>,
			Req0),	
	{ok, Req, State}.