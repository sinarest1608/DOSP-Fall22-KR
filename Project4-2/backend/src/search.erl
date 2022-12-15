-module(search).
-behavior(cowboy_handler).

-export([init/2]).
-compile(export_all).
-import(twitter, [getdata/0, searchTweetTag/2, searchTweetMention/2, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0, ]).

search(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
	{_, Query} = lists:keyfind(<<"query">>, 1, InputParams),
	if string:str(Query, "#") ->
		FunctionResponse = twitter:searchTweetTag(Tweet)
	true ->
		FunctionResponse = twitter:searchTweetMention(Tweet)
end,
	if FunctionResponse ->

		Req = cowboy_req:reply(200,
			#{<<"content-type">> => <<"text/plain">>},
			<<"Found">>,
			Req0)
	true ->
		Req = cowboy_req:reply(404,
			#{<<"content-type">> => <<"text/plain">>},
			<<"No Tweets Found">>,
			Req0)
end,
	{ok, Req, State}.