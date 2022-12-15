-module(backend_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
        {'_', [{"/", backend_handler, []}, 
                {"/signin", signin, []}, 
                {"/signup", register, []}, 
                {"/tweet", tweet, []}, 
                {"/search", search, []}, 
                {"/follow", follow, []},
                {"/retweet", retweet, []}
            ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 5000}],
        #{env => #{dispatch => Dispatch}}
    ),
	backend_sup:start_link().

stop(_State) ->
	ok.
