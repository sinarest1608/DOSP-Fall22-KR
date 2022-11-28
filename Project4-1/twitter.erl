
-module(twitter).
-compile(export_all).

%%% Change the function below to return the name of the node where the
%%% twitter server runs
server_node() ->
    % 'twitter@MacBook-Pro-9.local'.
    'server@ssrb-vpn1-4-34'.

%%% This is the server process for the "twitter"
%%% the user list has the format [{ClientPid1, Name1},{ClientPid22, Name2},...]
server(User_List) ->
    receive
        {From, logon, UserName, Password} ->
            New_User_List = server_logon(From, UserName, Password,User_List),
            io:fwrite("New user List: ~p\n", [New_User_List]),
            
            TempTotalUserList = lists:append(persistent_term:get(totalUserList), [UserName]),
            persistent_term:put(totalUserList, TempTotalUserList),
            V = persistent_term:get(totalUserList),
            io:fwrite("Total user: ~p\n", [V]),

            server(New_User_List);
        {From, logoff} ->
            New_User_List = server_logoff(From, User_List),
            server(New_User_List);
        {From, message_to, To, Message} ->
            server_transfer(From, To, Message, User_List),
            io:format("list is now: ~p~n\n", [User_List]),
            server(User_List)
    end.

%%% Start the server
start_server() ->
    UserMap = #{},
    persistent_term:put(userMap, UserMap),
    TotalUserList = [],
    persistent_term:put(totalUserList, TotalUserList),
    register(twitter, spawn(twitter, server, [[]])).
    
% register(get, spawn(twitter, getdata, [[]])).


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
            ToPid ! {message_from, Name, Message}, 
            From ! {twitter, sent} 
    end.


%%% User Commands

% serverClientHelper() ->

 

% getdata()->
%     receive
%     {followers,From }->
%         F=persistent_term:get(followers),
%         From ! {F}
% end.



registerUser(UserName, Password) ->
    TempUserMap = persistent_term:get(userMap),
    UpdatedMap = maps:update(UserName, Password, TempUserMap),
    persistent_term:put(userMap, UpdatedMap),
    TempTotalUserList = lists:append(persistent_term:get(totalUserList), [UserName]),
    persistent_term:put(totalUserList, TempTotalUserList),
    io:fwrite("~p", [TempTotalUserList]).


    
logon(Name, Password) ->
    case whereis(mess_client) of 
        undefined ->
            register(mess_client, 
                     spawn(twitter, client, [server_node(), Name, Password]));
                    %  registerUser(Name, Password);
                    % twitter ! {self(), logon, Name, Password};
                     
        _ -> already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

message(ToName, Message) ->
    case whereis(mess_client) of % Test if the client is running
        undefined ->
            not_logged_on;
        _ -> mess_client ! {message_to, ToName, Message},
             ok

        % get ! {followers,self()}
        % receive
        %     {Followers}->
        %         Var = Followers    
        % end,
end.


%%% The client process which runs on each server node
client(Server_Node, Name, Pass) ->
    {twitter, Server_Node} ! {self(), logon, Name, Pass},
    await_result(),
    client(Server_Node).

client(Server_Node) ->
    receive
        logoff ->
            {twitter, Server_Node} ! {self(), logoff},
            exit(normal);
        {message_to, ToName, Message} ->
            {twitter, Server_Node} ! {self(), message_to, ToName, Message},
            await_result();
        {message_from, FromName, Message} ->
            io:format("Message from ~p: ~p~n", [FromName, Message])
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