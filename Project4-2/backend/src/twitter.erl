-module(twitter).

-compile(export_all).

server_node() ->
    'server@MacBook-Pro-9'.

server(User_List) ->
    receive
        {From, logon, UserName, Password} ->
            New_User_List = server_logon(From, UserName, Password, User_List),
            persistent_term:put(userList, New_User_List),
            io:fwrite("New user List: ~p\n", [New_User_List]),

            TempTotalUserList =
                lists:append(
                    persistent_term:get(totalUserList), [UserName]),
            persistent_term:put(totalUserList, TempTotalUserList),
            V = persistent_term:get(totalUserList),
            io:fwrite("Total user: ~p\n", [V]),

            server(New_User_List);
        {From, logoff} ->
            New_User_List = server_logoff(From, User_List),
            server(New_User_List);
        {From, tweet_to, To, Message} ->
            checkHashTags(Message),
            checkUsers(Message),
            server_transfer(From, To, Message, User_List),
            io:format("list is now: ~p~n\n", [User_List]),
            server(User_List);
        {From, retweet_to, To, Message} ->
            checkHashTags(Message),
            checkUsers(Message),
            server_transfer_retweet(From, To, Message, User_List),
            io:format("list is now: ~p~n\n", [User_List]),
            server(User_List);
        {From, follow, To} ->
            server_follow(From, To, User_List),
            server(User_List);
        {From, searchMention, Mention} ->
            searchTweetMention(Mention, From),
            server(User_List);
        {From, searchTag, Tag} ->
            searchTweetTag(Tag, From),
            server(User_List)
    end.

searchTweetMention(Mention, From) ->
    TempMap = persistent_term:get(mentionMap),
    Bool = maps:is_key(Mention, TempMap),

    if Bool ->
           Res = maps:get(Mention, TempMap),
           From ! {queryResult, Res},
           io:fwrite("Query Result:\n ~p\n", [Res]);
       true ->
           From ! {queryResult, "Not Found"},
           io:fwrite("No Tweets Found!\n")
    end.

searchTweetTag(Tag, From) ->
    TempMap = persistent_term:get(hashTagMap),
    Bool = maps:is_key(Tag, TempMap),

    if Bool ->
           Res = maps:get(Tag, TempMap),
           From ! {queryResult, Res},
           io:fwrite("Query Result:\n ~p\n", [Res]);
       true ->
           From ! {queryResult, "Not Found"},
           io:fwrite("No Tweets Found!\n")
    end.

checkHashTags(Tweet) ->
    Tag = string:str(Tweet, "#"),
    Mention = string:str(Tweet, "@"),
    HashString = string:sub_string(Tweet, Tag, Mention - 2),

    TempMap = persistent_term:get(hashTagMap),
    Bool = maps:is_key(HashString, TempMap),
    if Bool ->
           TempList = maps:get(HashString, TempMap),

           L = lists:append(TempList, [Tweet]),
           L1 = lists:usort(L),
           T = maps:update(HashString, L1, TempMap),

           persistent_term:put(hashTagMap, T);
       true ->
           T = #{HashString => [Tweet]},
           T1 = maps:merge(TempMap, T),
           persistent_term:put(hashTagMap, T1)
    end.

checkUsers(Tweet) ->
    Mention = string:str(Tweet, "@"),
    MentionUser = string:sub_string(Tweet, Mention),
    TempMap = persistent_term:get(mentionMap),
    Bool = maps:is_key(MentionUser, TempMap),
    if Bool ->
           TempList = maps:get(MentionUser, TempMap),
           L = lists:append(TempList, [Tweet]),
           L1 = lists:usort(L),
           T = maps:update(MentionUser, L1, TempMap),
           persistent_term:put(mentionMap, T);
       true ->
           T = #{MentionUser => [Tweet]},
           T1 = maps:merge(TempMap, T),
           persistent_term:put(mentionMap, T1)
    end.

start_server() ->
    UserMap = #{},
    persistent_term:put(userMap, UserMap),
    TotalUserList = [],
    persistent_term:put(totalUserList, TotalUserList),
    HashTagMap = #{},
    persistent_term:put(hashTagMap, HashTagMap),
    MentionMap = #{},
    persistent_term:put(mentionMap, MentionMap),
    FollowersMap = #{},
    persistent_term:put(followersMap, FollowersMap),
    persistent_term:put(followerMap, #{}),
    register(twitter, spawn(twitter, server, [[]])),
    register(get, spawn(twitter, getdata, [])).

server_logon(From, Name, Password, User_List) ->
    case lists:keymember(Name, 2, User_List) of
        true ->
            io:fwrite("already exists!"),
            From ! {twitter, stop, user_exists_at_other_node},
            User_List;
        false ->
            io:fwrite("Logged on\n"),

            TempUserMap = persistent_term:get(userMap),
            TempUSerMAp2 = #{Name => Password},
            TempUSerMap3 = maps:merge(TempUserMap, TempUSerMAp2),
            persistent_term:put(userMap, TempUSerMap3),
            persistent_term:put(currentUser, Name),
            FollowerMap = #{Name => []},
            F = persistent_term:get(followerMap),
            F1 = maps:merge(F, FollowerMap),
            persistent_term:put(followerMap, F1),

            From ! {twitter, logged_on},
            [{From, Name} | User_List]
    end.

server_logoff(From, User_List) ->
    lists:keydelete(From, 1, User_List).

server_transfer(From, To, Message, User_List) ->
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_transfer(From, Name, To, Message, User_List)
    end.

server_transfer(From, Name, To, Message, User_List) ->
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {twitter, receiver_not_found};
        {value, {ToPid, To}} ->
            ToPid ! {tweet_from, Name, Message},
            From ! {twitter, sent}
    end.

server_transfer_retweet(From, To, Message, User_List) ->
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_transfer_retweet(From, Name, To, Message, User_List)
    end.

server_transfer_retweet(From, Name, To, Message, User_List) ->
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {twitter, receiver_not_found};
        {value, {ToPid, To}} ->
            ToPid ! {retweet_from, Name, Message},
            From ! {twitter, sent}
    end.

server_follow(From, To, User_List) ->
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_follow(From, Name, To, User_List)
    end.

server_follow(From, Name, To, User_List) ->
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {twitter, receiver_not_found};
        {value, {ToPid, To}} ->
            T = persistent_term:get(followerMap),
            L = maps:get(To, T),
            L1 = lists:append(L, [Name]),
            T1 = maps:update(To, L1, T),
            persistent_term:put(followerMap, T1),
            io:fwrite("Followers Map: ~p\n", [T1]),

            ToPid ! {follow_from, T1},
            From ! {twitter, sent}
    end.

getdata() ->
    receive
        {followers, From, Name} ->
            User_List = persistent_term:get(userList),
            io:fwrite("From: ~p\n", [From]),
            io:fwrite("Name: ~p\n", [Name]),
            io:fwrite("User_List: ~p\n", [User_List]),
            F = persistent_term:get(followerMap),
            F1 = maps:get(Name, F),
            io:fwrite("Server found list: ~p for ~p\n", [F1, Name]),
            From ! {followersList, F1};
        {From, search, Query} ->
            TempMap = persistent_term:get(hashTagMap),
            Bool = maps:is_key(Query, TempMap),
            if Bool == true ->
                   Res = maps:get(Query, TempMap),
                   From ! {queryResult, Res},
                   io:fwrite("Query Result:\n ~p\n", [Res]);
               true ->
                   From ! {queryResult, "Not Found"},
                   io:fwrite("No Tweets Found!\n")
            end
    end,
    getdata().

registerUser(UserName, Password) ->
    persistent_term:put(userMap, #{UserName => Password}),
    io:fwrite("User Registered! ~p\n", [UserName]).

logon(Name, Password) ->
    case whereis(mess_client) of
        undefined ->
            persistent_term:put(currentUserClient, Name),
            persistent_term:put(latestTweet, ""),
            register(mess_client, spawn(twitter, client, [server_node(), Name, Password]));
        _ ->
            already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

follow(User) ->
    case whereis(mess_client) of
        undefined ->
            not_logged_on;
        _ ->
            mess_client ! {follow, User},
            ok
    end.

retweet() ->
    Tweet = persistent_term:get(latestTweet),
    case whereis(mess_client) of
        undefined ->
            not_logged_on;
        _ ->
            CurrName = persistent_term:get(currentUserClient),
            {get, server_node()} ! {followers, self(), CurrName},
            receive
                {followersList, List} ->
                    io:fwrite("F List from server ~p\n", [List]),
                    lists:foreach(fun(I) ->
                                     io:fwrite("element: ~p~n", [I]),
                                     mess_client ! {retweet_to, I, Tweet}
                                  end,
                                  List)
            end
    end.

tweet(Tweet) ->
    persistent_term:put(latestTweet, Tweet),
    case whereis(mess_client) of
        undefined ->
            not_logged_on;
        _ ->
            CurrName = persistent_term:get(currentUserClient),
            {get, server_node()} ! {followers, self(), CurrName},
            receive
                {followersList, List} ->
                    io:fwrite("F List from server ~p\n", [List]),
                    lists:foreach(fun(I) ->
                                     io:fwrite("element: ~p~n", [I]),
                                     mess_client ! {tweet_to, I, Tweet}
                                  end,
                                  List)
            end
    end.

message(ToName, Message) ->
    case whereis(mess_client) of
        undefined ->
            not_logged_on;
        _ ->
            mess_client ! {tweet_to, ToName, Message},
            ok
    end.

searchMention(Query) ->
    {twitter, server_node()} ! {self(), searchMention, Query}.

searchHashtag(Query) ->
    mess_client ! {searchTag, Query}.

client(Server_Node, Name, Pass) ->
    {twitter, Server_Node} ! {self(), logon, Name, Pass},
    await_result(),
    client(Server_Node).

client(Server_Node) ->
    receive
        you_are_not_logged_on ->
            io:fwrite("Err");
        logoff ->
            {twitter, Server_Node} ! {self(), logoff},
            exit(normal);
        {searchTag, Tag} ->
            {twitter, Server_Node} ! {self(), searchTag, Tag},
            await_result();
        {tweet_to, ToName, Message} ->
            {twitter, Server_Node} ! {self(), tweet_to, ToName, Message},
            await_result();
        {retweet_to, ToName, Message} ->
            {twitter, Server_Node} ! {self(), retweet_to, ToName, Message},
            await_result();
        {follow, ToName} ->
            {twitter, Server_Node} ! {self(), follow, ToName},
            await_result();
        {tweet_from, FromName, Message} ->
            io:format("~p Tweeted: ~p~n", [FromName, Message]);
        {retweet_from, FromName, Message} ->
            io:format("~p Re-Tweeted: ~p~n", [FromName, Message]);
        {follow_from, T1} ->
            io:fwrite("A User Followed You!");
        {followersList, F} ->
            io:fwrite("Followers list from server ~p\n", [F]);
        {queryResult, Res} ->
            io:fwrite("Query Result:\n ~p\n", [Res])
    end,
    client(Server_Node).

await_result() ->
    receive
        {twitter, stop, Why} ->
            io:format("~p~n", [Why]),
            exit(normal);
        {twitter, What} ->
            io:format("~p~n", [What])
    end.


    for_reg(0)->
        ok;
    for_reg(N)->
        registerUser(N,"1"),
        for_reg(N-1).
     
    for_log(0,Max)->
        io:fwrite("\n"),
        ok;
    for_log(N,Max)->
     
        logonSimulator(N,N,Max),
        for_log(N-1,Max).
     
    for_follow(0,Max)->
        io:fwrite("\n"),
        ok;
    for_follow(N,Max)->
        User1 = rand:uniform(N),
        User2 = getRandom(User1, Max),
        persistent_term:put(user, User1),
     
        followSimulator(User1, User2),
        tweetSimulator(User2,"Hello",1000),
     
        for_follow(N-1, Max).
     
    for_off(0)->
        {_, Time1} = statistics(runtime),
        {_, Time2} = statistics(wall_clock),
        U1 = Time1 * 1000,
        U2 = Time2 * 1000,
        io:format("Code time=~p (~p)~n", [U2, U1]),
        ok;
    for_off(N)->
        logoffSimulator(N,N),
        for_off(N-1).
     
    logoffSimulator(N,N)->
        {fetch, server_node()} ! {user_list, self()},
     
        receive 
            {Dat}->
                Userdata=Dat 
        end,
        maps:remove(N, Userdata),
        io:fwrite("@~p has logged off\n",[N]),
        X=maps:size(Userdata),
        if 
            X==0 ->
                exit(bas);
            true ->
                ok
        end.
     
    getRandom(User1, N) ->
        User2 = rand:uniform(N),
        if 
            User1==User2 ->
                getRandom(User1, N);
            true ->
                User2
        end.
     
    tweetSimulator(User,Message,0)->
        FollwersMap = persistent_term:get(folSimulator),
        {fetch, server_node()} ! {tweetmap, self()},
        receive 
            {Tweetmp, Alt}->
                Tweet = Tweetmp,
                Alltweets = Alt 
        end,
     
        Tweetsmap=persistent_term:get(tweetsSimulator),
     
        Newalltweets=lists:append(Alltweets, [Message]),
     
        List = maps:get(User, FollwersMap),
     
        Tweetlist = maps:get(User, Tweetsmap),
     
        Tweetlist2 = lists:append(Tweetlist, [Message]),
     
        Tweetmp1 = maps:update(User, Tweetlist2, Tweetsmap),
     
        {twitter, server_node()} ! {tweetupd, Tweetmp1, Newalltweets},
     
        lists:foreach(
            fun(Elem) ->
                io:fwrite("To @~p From: @~p Tweet: ~p~n", [Elem, User, Message])
            
            end,
            List
        );
     
    tweetSimulator(User, Message,N)->
        FollwersMap = persistent_term:get(folSimulator),
     
        {fetch, server_node()} ! {tweetmap, self()},
        receive 
            {Tweetmp, Alt}->
                Tweet = Tweetmp,
                Alltweets = Alt 
        end,
     
        Tweetsmap=persistent_term:get(tweetsSimulator),
     
        Newalltweets=lists:append(Alltweets, [Message]),
     
        List = maps:get(User, FollwersMap),
     
        Tweetlist = maps:get(User, Tweetsmap),
     
        Tweetlist2 = lists:append(Tweetlist, [Message]),
     
        Tweetmp1 = maps:update(User, Tweetlist2, Tweetsmap),
     
        {twitter, server_node()} ! {tweetupd, Tweetmp1, Newalltweets},
     
        lists:foreach(
            fun(Elem) ->
                io:fwrite("To @~p From: @~p Tweet: ~p~n", [Elem, User, Message])
            
            end,
            List
        ),
        tweetSimulator(User,Message,N-1).
     
    logonSimulator(Name, _Password, Max)->
            io:fwrite("@~p has logged on\n", [Name]),
            if 
                Name==Max ->
                    {fetch, server_node()} ! {followmap, self()},
                    receive 
                        {Fol} ->
                            FollowersMap = Fol 
     
                    end,
                    {fetch, server_node()} ! {tweetmap, self()},
                    receive 
                        {Tweet, All} ->
                            TweetsMap = Tweet 
                    end, 
                    {fetch, server_node()} ! {lstmsg, self()},
                    receive 
                        {Last} ->
                            LastMap=Last 
                    end; 
                true ->
                    FollowersMap = persistent_term:get(folSimulator),
                    TweetsMap = persistent_term:get(tweetsSimulator),
                    LastMap = persistent_term:get(lastSimulator)
            end,
     
            FollowersMap2= #{Name => []},
            FollowersMap3=maps:merge(FollowersMap2, FollowersMap),
     
            persistent_term:put(folSimulator, FollowersMap3),
     
     
            Temp_tweet = #{Name => []},
     
            NewTweetmp=maps:merge(TweetsMap, Temp_tweet),
     
            persistent_term:put(tweetsSimulator, NewTweetmp),
     
            Temp_lsttweet = #{Name => ""},
     
            NewLastTweetmp = maps:merge(LastMap, Temp_lsttweet),
     
            persistent_term:put(lastSimulator, NewLastTweetmp).
     
    followSimulator(User1, User2)->
        FollowersMap = persistent_term:get(folSimulator),
     
        List = maps:get(User2, FollowersMap),
        List2 = lists:append(List, [User1]),
        FollowersMap2 = maps:update(User2, List2, FollowersMap),
        FollowersMap3 = maps:merge(FollowersMap, FollowersMap2),
     
        persistent_term:put(folSimulator, FollowersMap3).
     
     
    simulator(N) ->
        statistics(runtime),
        statistics(wall_clock),
        for_reg(N),
        for_log(N,N),
        Half = N-49,
        for_follow(Half, N),
     
        for_off(N).