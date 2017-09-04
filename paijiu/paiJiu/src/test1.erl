-module(test1).
-export([perms/1,test/1]).

perms([]) -> [[]];  


perms(L) -> [[H|T] || H <-L, T <- perms(L -- [H])].  


test(X) ->
    if 
        X=:=5 andalso 5>=X->
        
            5;
        X=:=6 andalso 6>=X->
            6;
        true ->
            7
    end.
test1(X) ->
    case X >= 7 of
        true ->
            X;
        _ -> 100
    end.
