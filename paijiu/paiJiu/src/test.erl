-module(test).

-export([test/1,test1/0,test2/0,test3/0,test4/3,list_length/1,testMap/0,testMax/0,testforeach/1]).

-record(person,{name,age}).
test(X)	->
	ListNum2=[2,5,9,11,12],			 %% 每个点2张牌
	ListNum4=[4,7,8,10],	
	case lists:member(X,ListNum2) of
			true -> 2;
			_ -> case lists:member(X,ListNum4) of
					true -> 4;
					_	 -> case X of
								3 ->1;
								6 ->5
							end
				end
		end.	 
test1()	->
	List1=[#person{age=1},#person{age=2},#person{age=4},#person{age=5}],
	put(list1,List1),
	Number = case 2 of
		1 ->1;
		_ ->3
	end,
	Person=lists:keyfind(1,#person.age,List1),
	Person1=Person#person{name="xiaohong"},
	io:format("Person1:~p~n",[Person1]),
	List2=lists:keyreplace(1,#person.age,List1,Person1),
	io:format("....~p~n",[List2]).
	
test2()	->	
	Fun=fun(GameType) ->
			case GameType of
				dapaijiu ->1;
				_ 	->2
			end
	end,
	Fun(xiaopaijiu).

test3()	->
	Fun=fun(Person=#person{name=Name}) ->
		case Name of	
			"xiaoming" ->
				Person=Person#person{age=11};
			_	->
				Person=Person#person{age=33}
		end
	end,
	Person1=#person{name="xiaoming"},
	Person2=#person{name="xiaozhang"},
	Fun(Person1),
	Fun(Person2).

	% N,M,	I
	% 从n个数里取m个数:
	% 		从n-1个数里取m-1个数
	% 		I<m
	% 		如果m==0,则是一个组合

test4(M,List1,NewList) when M=:=0->	
	io:format("NewList:~p~n",[NewList]),
	NewList;
test4(M,[H|List1],NewList) ->
	io:format("M=~p~n",[{M,NewList}]),
	test4(M-1,List1,[H|NewList]).

list_length([]) ->
	Fun=fun(X,I) ->
		I+1
	end,
	lists:foldl(Fun,0,[]).
testMap() ->
	Persons=[#person{age=11},#person{age=23},#person{age=22},#person{age=34}],
	Fun=fun(Person=#person{name=Name}) ->
		Person1=Person#person{name="xinmingzi"}
	end,
	List1=lists:map(Fun,Persons),
	io:format("New:~p~n",[Persons]),
	io:format("List1:~p~n",[List1]).

% testkeySort()->
% 	Persons=[#person{age=11},#person{age=23},#person{age=22},#person{age=34}],
% 	lists:

testMax()->
	Persons=[#person{age=11},#person{age=23},#person{age=22},#person{age=34}],
	Fun=fun(Person1=#person{age=Age1},Person2=#person{age=Age2}) ->
		case Age1 >= Age2 of
			true ->Person1;
			_ ->Person2
		end
	end,
	lists:foldl(Fun,Person=#person{age=0},Persons).

testforeach(A) ->
	Fun=fun({X,B})	->
			case X >=B of
				true -> 1;
				_	->3
			end
	end,
	lists:foldl(Fun,3,A).

从n个数里取m个数:	
	1.转化为从n-1个数里取m-1个数
get_m_from_n(_,[],NewList) ->
	NewList;

get_m_from_n(M,[H|List],NewList) ->
	Fun=fun(X,NewList) ->
		[X|NewList]
	end,
	lists:foldl(fun,[])