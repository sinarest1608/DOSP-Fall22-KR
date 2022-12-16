-module(retweet).
-behavior(cowboy_handler).

-export([retweets/2]).
-compile(export_all).
-import(twitter, [getdata/0, retweet/1, server/1, searchTweetMention/2, searchTweetTag/2, checkHashTags/1, checkUsers/1, start_server/0 ]).

retweets(Req0, State) ->
    InputParams = cowboy_req:parse_qs(Req0),
	{_, Tweet} = lists:keyfind(<<"retweet">>, 1, InputParams),
    FunctionResponse = twitter:retweet(Tweet),
	if FunctionResponse ->

		Req = cowboy_req:reply(200,
			#{<<"content-type">> => <<"text/plain">>},
			<<"ReTweet is Live!">>,
			Req0);
	true ->
		Req = cowboy_req:reply(404,
			#{<<"content-type">> => <<"text/plain">>},
			<<"Error ReTweeting!">>,
			Req0)
end,
	{ok, Req, State}.