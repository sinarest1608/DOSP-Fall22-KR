
-module(twitter).
-compile(export_all).

%%% Change the function below to return the name of the node where the
%%% twitter server runs
server_node() ->
    'server@MacBook-Pro-9'.
    % 'server@ssrb-vpn1-4-34'.

%%% This is the server process for the "twitter"
%%% the user list has the format [{ClientPid1, Name1},{ClientPid22, Name2},...]
server(User_List) ->
    receive
        {From, logon, UserName, Password} ->
            New_User_List = server_logon(From, UserName, Password,User_List),
            persistent_term:put(userList, New_User_List),
            io:fwrite("New user List: ~p\n", [New_User_List]),
            
            TempTotalUserList = lists:append(persistent_term:get(totalUserList), [UserName]),
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
            % server_transfer(From, To, Message, User_List),
            % io:format("list is now: ~p~n\n", [User_List]),
            server(User_List);

        % {From, follower, Who} ->
        %     ok
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
    HashString = string:sub_string(Tweet, Tag, Mention-2),
    io:fwrite("HAshString ~p\n", [HashString]),
    TempMap = persistent_term:get(hashTagMap),
    Bool = maps:is_key(HashString, TempMap),
    if Bool ->
        io:fwrite("Key exists\n"),
        TempList = maps:get(HashString, TempMap),
        io:fwrite("TempList ~p\n", [TempList]),
        L = lists:append(TempList, [Tweet]),
        L1 = lists:usort(L),
        T = maps:update(HashString, L1, TempMap),
        io:fwrite("T ~p\n", [T]),
        % T1 = maps:merge(TempMap, T),
        persistent_term:put(hashTagMap, T);
    true ->
        io:fwrite("Key not exists\n"),
        T = #{HashString=>[Tweet]},
        T1 = maps:merge(TempMap, T),
        persistent_term:put(hashTagMap, T1)
    end,
    io:fwrite("HashTag Map: ~p\n", [persistent_term:get(hashTagMap)]).
    
    %TODO: Mention 
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
        T = #{MentionUser=>[Tweet]},
        T1 = maps:merge(TempMap, T),
        persistent_term:put(mentionMap, T1)
    end,
    io:fwrite("Mention Map: ~p\n", [persistent_term:get(mentionMap)]).
        

%%% Start the server
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
    % To query DS from server to client.
    register(get, spawn(twitter, getdata, [])).


%%% Server adds a new user to the user list
server_logon(From, Name, Password,User_List) ->
    %% check if logged on anywhere else
    case lists:keymember(Name, 2, User_List) of
        true ->
            io:fwrite("already exists!"),
            From ! {twitter, stop, user_exists_at_other_node},  %reject logon
            User_List;
        false ->
            io:fwrite("Logged on\n"),

            TempUserMap = persistent_term:get(userMap),
            TempUSerMAp2 = #{Name=>Password},
            TempUSerMap3 = maps:merge(TempUserMap, TempUSerMAp2),


            % UpdatedMap = maps:update(UserName, "", TempUserMap),
            persistent_term:put(userMap, TempUSerMap3),

            % Follow Part
            persistent_term:put(currentUser, Name),
            FollowerMap = #{Name=>[]},
            F = persistent_term:get(followerMap),
            F1 = maps:merge(F, FollowerMap),
            persistent_term:put(followerMap, F1),

            From ! {twitter, logged_on},
            [{From, Name} | User_List]        %add user to the list
    end.

%%% Server deletes a user from the user list
server_logoff(From, User_List) ->
    lists:keydelete(From, 1, User_List).


%%% Server transfers a message between user
server_transfer(From, To, Message, User_List) ->
    %% check that the user is logged on and who he is
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_transfer(From, Name, To, Message, User_List)
    end.
%%% If the user exists, send the message
server_transfer(From, Name, To, Message, User_List) ->
    %% Find the receiver and send the message
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {twitter, receiver_not_found};
        {value, {ToPid, To}} ->
            ToPid ! {tweet_from, Name, Message}, 
            From ! {twitter, sent}
            % From ! twitter
    end.

%%% Server transfers a message between user
server_transfer_retweet(From, To, Message, User_List) ->
    %% check that the user is logged on and who he is
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_transfer_retweet(From, Name, To, Message, User_List)
    end.
%%% If the user exists, send the message
server_transfer_retweet(From, Name, To, Message, User_List) ->
    %% Find the receiver and send the message
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {twitter, receiver_not_found};
        {value, {ToPid, To}} ->
            ToPid ! {retweet_from, Name, Message}, 
            From ! {twitter, sent}
            % From ! twitter
    end.


%%% Server transfers a message between user
server_follow(From, To, User_List) ->
    %% check that the user is logged on and who he is
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {twitter, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_follow(From, Name, To, User_List)
    end.
%%% If the user exists, send the message
server_follow(From, Name, To, User_List) ->
    %% Find the receiver and send the message
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


%%% User Commands

% serverClientHelper() ->

 

getdata()->
    receive
    
    {followers,From, Name}->
        User_List = persistent_term:get(userList),
        io:fwrite("From: ~p\n", [From]),
        io:fwrite("Name: ~p\n", [Name]),
        io:fwrite("User_List: ~p\n", [User_List]),
        F=persistent_term:get(followerMap),
        % case lists:keysearch(Name, 1, User_List) of
        % false ->
        %     io:fwrite("False\n"),
        %     From !  you_are_not_logged_on;
        % {value, {From, Name}} ->
            % io:fwrite("Value: ~p\n", [value]),
            % CurrentUser = Name,
            % io:fwrite("CurrentUser ~p\n", [CurrentUser]),
            % io:fwrite("Name ~p\n", [Name]),
            F1 = maps:get(Name, F),
            io:fwrite("Server found list: ~p for ~p\n", [F1, Name]),
            From ! {followersList, F1};

    {From, search, Query} ->
        TempMap = persistent_term:get(hashTagMap),
        Bool = maps:is_key(Query, TempMap),

        if Bool==true ->
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

    persistent_term:put(userMap, #{UserName=>Password}),
    io:fwrite("User Registered! ~p\n", [UserName]).


    
logon(Name, Password) ->
    % persistent_term:put(followerMap, #{}),
    case whereis(mess_client) of 
        undefined ->
            % persistent_term:put(currentUser, Name),
            % FollowerMap = #{Name=>[]},
            % F = persistent_term:get(followerMap),
            % F1 = maps:merge(F, FollowerMap),
            % persistent_term:put(followerMap, F1),

            persistent_term:put(currentUserClient, Name),
            persistent_term:put(latestTweet, ""),
            register(mess_client, 
                     spawn(twitter, client, [server_node(), Name, Password]));
                    %  registerUser(Name, Password);
                    % twitter ! {self(), logon, Name, Password};
                     
        _ -> already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

follow(User)->
    case whereis(mess_client) of % Test if the client is running
    undefined ->
        not_logged_on;
    _ -> mess_client ! {follow, User},
        ok
end.

retweet()->

    Tweet = persistent_term:get(latestTweet),
    case whereis(mess_client) of % Test if the client is running
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
                        mess_client ! {retweet_to, I,Tweet}
                        end, List)
        
        end
        

        % get ! {followers,self()}
        % receive
        %     {Followers}->
        %         Var = Followers    
        % end,
    end.
tweet(Tweet)->
    persistent_term:put(latestTweet, Tweet),
    case whereis(mess_client) of % Test if the client is running
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
                        mess_client ! {tweet_to, I,Tweet}
                        end, List)
        
        end
        

        % get ! {followers,self()}
        % receive
        %     {Followers}->
        %         Var = Followers    
        % end,
    end.
message(ToName, Message) ->
    case whereis(mess_client) of % Test if the client is running
        undefined ->
            not_logged_on;
        _ -> mess_client ! {tweet_to, ToName, Message},
             ok

        % get ! {followers,self()}
        % receive
        %     {Followers}->
        %         Var = Followers    
        % end,
    end.

searchMention(Query)->
    {twitter, server_node()} ! {self(), searchMention, Query}.
searchHashtag(Query)->
    mess_client ! {searchTag, Query}.
    % {twitter, server_node()} ! {self(), searchTag, Query}.
        % {get, server_node()} ! {self(), search, Query}. 
% follow(User) ->
%     {twitter, server_node()} ! {self(), follower, User}.


%%% The client process which runs on each server node
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

            % io:format("Message from ~p: ~p~n", [FromName, Message]);
        {followersList, F} ->
            io:fwrite("Followers list from server ~p\n", [F]);
        {queryResult, Res} ->
            io:fwrite("Query Result:\n ~p\n", [Res])
    end,
    client(Server_Node).

%%% wait for a response from the server
await_result() ->
    receive
        {twitter, stop, Why} -> % Stop the client 
            io:format("~p~n", [Why]),
            exit(normal);
        {twitter, What} ->  % Normal response
            io:format("~p~n", [What])
    end.