-module(master).


-export([runner/0]).

runner() ->
    Master_ID = spawn(master, get_hash:main(), []).
    


