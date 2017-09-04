-module(room_tianjiu).

-export([init_tianjiu/0,take_tianjiu/1,card_to_players/1,test/0]).
-record(tianjiu,{
	num,			%% 牌的点数
	quantity, 		%% 牌的数量
	property		%% 牌的属性
}).


%%  初始化一副牌,有多种牌型的点数说明:
%% 	1.1,2 为大,3,4为小,5为最小
init_tianjiu()	->
	ListNum2=[2,5,9,11,12],			 %% 每个点2张牌
	ListNum4=[4,7,8,10],			 %% 每个点4张牌
	DianList=lists:seq(2,12),	 		 %% 牌的点数,2 到 12
	Quantitylist=lists:seq(1,5),	 %% 牌的数量,1 到 5
	Fun_number = fun(X) ->
		case lists:member(X,ListNum2) of
			true -> 2;
			_ -> case lists:member(X,ListNum4) of
					true -> 4;
					_	 -> case X of
								3 ->1;
								6 ->5
							end
				end
		end
	end,
	Fun_one = fun(X,AccList) ->
		[#tianjiu{num=X,quantity=Quantity,property=fun_init_property(X,Quantity)} || Quantity <- Quantitylist,Fun_number(X) >= Quantity]++AccList
	end,
	Init_card=lists:foldl(Fun_one,[],DianList),
	put(?INIT_TIANJIU_LIST,Init_card),
	refresh_tianjiu().
fun_init_property(X,Quantity)	->
	case X of
			2	->?DI;
			3	->?DAN;
			4	-> case lists:member(Quantity,[1,2]) of
					true -> ?HE;
					_	-> ?CHANG
					end;
			5	->?ZA;
			6	-> case lists:member(Quantity,[1,2]) of
					true ->?CHANG;
					_     ->case lists:member(Quantity,[3,4]) of
								true ->?DUAN;
								_	->?DAN
							end
					end;
			7	-> case lists:member(Quantity,[1,2]) of
						true ->?DUAN;
						_	->?ZA
					end;
			8	-> case lists:member(Quantity,[1,2]) of
						true ->?REN;
						_ ->?ZA
					end;
			9	-> ?ZA;
			10  -> case lists:member(Quantity,[1,2]) of	
						true ->?CHANG;
						_ -> ?DUAN
					end;
			11  -> ?DUAN;
			12	-> ?TIAN
	end.


%% 洗牌
refresh_tianjiu()	->
	Fun = fun(_, {Init_Tianjiu_List, New_Tianjiu_List}) ->	% 初始牌列表,新麻将牌列表,从旧牌列表取出一章牌,放入新牌列表
        Tianjiu = rand_list(Init_Tianjiu_List),		% 取一张牌
		%io:format("Tianjiu:~p~n",[Tianjiu]),
        %%list:delete(Ele,List)删除列表中第一个符合这个值的值,返回一个列表
        {lists:delete(Tianjiu, Init_Tianjiu_List), [Tianjiu | New_Tianjiu_List]}  % 将这张牌从初始牌列表中删除,将取出的牌放如一个新列表
    end,
    TianjiuList=get(?INIT_TIANJIU_LIST),
    {[],New_Tianjiu_List2} = lists:foldl(Fun,{TianjiuList,[]},TianjiuList),
    put(?INIT_TIANJIU_LIST,New_Tianjiu_List2),
    put(?TIANJIU_LIST,New_Tianjiu_List2) ,get(?TIANJIU_LIST).

%% 给玩家发牌,从庄家开始发牌,再发庄家下一个位置玩家的牌
card_to_oneplayer(Number,SeatId)	->
	PlayerList=get(?PLAYERLIST),
	Player=lists:keyfind(SeatId,#player.seatid,PlayerList),
	%io:format("card_to_oneplayer:~p~n",[Player]),
	Player1=Player#player{cardlist=take_tianjiu(Number)},
	put(?PLAYERLIST,lists:keyreplace(SeatId,#player.seatid,PlayerList,Player1)).
%%  {playerid,cardlist,chipnum,game_type,score_change,seatid}).

%% 将玩家的牌组合形成一个点数列表
dianshu_of_player(Player=#player{playerid=Id,cardlist=CardList}) ->
	PlayerList=get(?PLAYERLIST),
	[Tianjiu1|CardList2]=Player#player.cardlist,
	[Tianjiu2|CardList3]=CardList2,
	[Tianjiu3|CardList4]=CardList3,
	[Tianjiu4|CardList5]=CardList4,
	Dianshu1=dianshu_of_card(Tianjiu1,Tianjiu2),
	Dianshu2=dianshu_of_card(Tianjiu1,Tianjiu3),
	Dianshu3=dianshu_of_card(Tianjiu1,Tianjiu4),
	Dianshu4=dianshu_of_card(Tianjiu2,Tianjiu3),
	Dianshu5=dianshu_of_card(Tianjiu2,Tianjiu4),
	Dianshu6=dianshu_of_card(Tianjiu3,Tianjiu4),
	Dianshulist=[Dianshu1]++[Dianshu2]++[Dianshu3]++[Dianshu4]++[Dianshu5]++[Dianshu6],	
	DapaiXiaopai=lists:keysort(#dianshu.value,get_dapai_xiaopai(Dianshulist)),
	Xiaopai=lists:nth(1,DapaiXiaopai),
	Dapai=lists:nth(2,DapaiXiaopai),
	Player1=Player#player{game_type=#dapaijiu{dapai=
						#dapai{num=Dapai#dianshu.sum,property=Dapai#dianshu.property,value=Dapai#dianshu.value},xiaopai=
						#xiaopai{num=Xiaopai#dianshu.sum,property=Xiaopai#dianshu.property,value=Xiaopai#dianshu.value}}},
	io:format("Xiaopai,Dapai:~p~n",[{Xiaopai,Dapai}]),
	% io:format("Player:~p~n",[Player]),											  
	% io:format("===================================before put Player1:~p~n",[Player1]),
	PlayerList1=lists:keyreplace(Id,#player.playerid,PlayerList,Player1),

	put(?PLAYERLIST,PlayerList1),	
	%io:format("refreshPlayer==================~p~n",[lists:keyfind(Id,#player.playerid,get(?PLAYERLIST))]),										  						
	io:format("....................................................................................~n").

compare_with_zhuangjia() ->
	ZhuangjiaId=get(?ZHUANGJIAID),
	PlayerList=get(?PLAYERLIST),
	% io:format("compare_with_zhuangjia:~p~n",[PlayerList]),
	Zhuangjia=lists:keyfind(ZhuangjiaId,#player.playerid,PlayerList),
	Player1=lists:nth(1,PlayerList),
	Player2=lists:nth(2,PlayerList),
	Player3=lists:nth(3,PlayerList),
	Player4=lists:nth(4,PlayerList),
	% io:format("Player1:~p~n",[Player1]),
	% io:format("Player2:~p~n",[Player2]),
	% io:format("Player3:~p~n",[Player3]),
	% io:format("Player4:~p~n",[Player4]),
	p2p_compare(Zhuangjia,Player1),
	p2p_compare(Zhuangjia,Player2),
	p2p_compare(Zhuangjia,Player3),
	p2p_compare(Zhuangjia,Player4).

p2p_compare(Zhuangjia=#player{playerid=Id1,game_type=#dapaijiu{dapai=#dapai{value=Value1},xiaopai=#xiaopai{value=Value11}}},
			Player=#player{playerid=Id2,game_type=#dapaijiu{dapai=#dapai{value=Value2},xiaopai=#xiaopai{value=Value22}}}) ->
	case Id2 =:= Id1 of 
		true -> skip;
		_ ->
			io:format("~w player compare_with_zhuangjia~n",[Id2]),
			case Value1 >= Value2 of
				true -> case Value11 >= Value22 of
							true -> io:format("~w player lose!",[Id2]);
							_	-> io:format("~w player win and lose!",[Id2])
						end;
				_ -> case Value11 >= Value22 of
						true -> io:format("~w  player win and lose!",[Id2]);
						_ -> io:format("~w player win!",[Id2])
					 end
			end
	end.

%% 得到一个玩家的大牌和小牌
get_dapai_xiaopai(Dianshulist) ->
	Fun=fun(Dianshu=#dianshu{sum=Num,property=Property,value=Value}) ->
		NewDianshu=Dianshu#dianshu{value=(Num+1) * Property}
	end,
	NewDianshuList=lists:map(Fun,Dianshulist),		% 1,6	2,5		3,4	
	List16=[lists:nth(1,NewDianshuList),lists:nth(6,NewDianshuList)],
	List34=[lists:nth(3,NewDianshuList),lists:nth(4,NewDianshuList)],
	List25=[lists:nth(2,NewDianshuList),lists:nth(5,NewDianshuList)],
	% io:format("List16,List34,List25:~p~n",[{List16,List34,List25}]),
	Fun1=fun(Dianshu1=#dianshu{value=Value1},Dianshu2=#dianshu{value=Value2}) ->
		case Value1 >=Value2 of
			true -> Dianshu1;
			_ -> Dianshu2
		end
	end,
	Max16=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List16),
	Max25=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List25),
	Max34=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List34),
%	io:format("Max16,Max34,Max25:~p~n",[{Max16,Max34,Max25}]),
	case Max16#dianshu.value >=Max25#dianshu.value of
		true -> case Max16#dianshu.value >=Max34#dianshu.value of
					true -> List16;
					_ ->List34
			 	end;
		_ 	-> 	case Max25#dianshu.value >= Max34#dianshu.value of
					true -> List25;
					_ ->List34
				end
	end.

dianshu_of_card(Tianjiu1=#tianjiu{num=Number1,property=Property1},Tianjiu2=#tianjiu{num=Number2,property=Property2})	->
	Fun_maxProperty=fun(Pro1,Pro2) ->
		case Pro1 >= Pro2 of
			true ->Pro1;
			_ -> Pro2
		end
	end,
	Fun_Property=fun(Pro1,Pro2) ->
		case Pro1 =:=?TIAN orelse Pro2=:=?TIAN of
			true ->?TIANGANG;
			_ -> case Pro1 =:=?DI orelse Pro2=:=?DI of
					true -> ?DIGANG;
					_ -> Fun_maxProperty(Pro1,Pro2)
				 end
		end
	end,

	case Number1 =:= Number2 andalso Property1 =:= Property2 of 						%% 是否是对子
		true -> Dianshu=#dianshu{sum=Number1,property=duizi_property(Property1)};		%% 是对子
		_	-> case (Number1+Number2) rem 10 of 										%% 不是对子,计算点数
					9 -> case (Property1 =:= Property2) andalso Property1=:=?DAN of 	%% 点数为9的时候,判断是否是皇上
							true -> Dianshu=#dianshu{sum=9,property=?HUANGSHANG}; 		%% 是皇上
							_	-> Dianshu=#dianshu{sum=9,property=Fun_maxProperty(Property1,Property2)} 	%%
						 end;
					0 -> case (Number1 =:= 8 orelse Number2 =:= 8) of 					%% 点数为0的时候,判断是否是天杠,地杠
							true -> Dianshu=#dianshu{sum=0,property=Fun_Property(Property1,Property2)};
							_ ->Dianshu=#dianshu{sum=0,property=Fun_maxProperty(Property1,Property2)}
						 end;
					_ ->Dianshu=#dianshu{sum=(Number1+Number2) rem 10,property=Fun_maxProperty(Property1,Property2)}
				end
	end.

%% 天,地,人,和,长,短,杂,3和6是单的,就不需要判断
duizi_property(Property) ->
	case Property of
		?ZA ->?DUIZA;
		?DUAN ->?DUIDUAN;
		?CHANG ->?DUICHANG;
		?HE ->?DUIHE;
		?REN ->?DUIREN;
		?DI ->?DUIDI;
		?TIAN ->?DUITIAN
	end.

card_to_players(GameType) ->
	Number = case GameType of
		dapaijiu -> 4;
		xiaopaijiu -> 2
	end,
	Zhuangjia_SeatId=get(?ZHUANGJIA_SEATID),
	%io:format("zhuangjia_seatid:~p~n",[Zhuangjia_SeatId]),
	%io:format("Number:~p~n",[Number]),
	card_to_oneplayer(Number,Zhuangjia_SeatId),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+1)),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+2)),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+3)).

next_seat(SeatId) ->
	case SeatId > 4 of
		true -> SeatId rem 4;
		_	-> SeatId
	end.
%%发牌 Num:发牌的张数
take_tianjiu(Num) ->
    TianjiuList = get(?TIANJIU_LIST),
    take_poker(Num, TianjiuList, []).
take_poker(Num, TianjiuList, List4) when Num =< 0 ->
    put(?TIANJIU_LIST, TianjiuList),
    List4;
take_poker(_, TianjiuList = [], List4) ->
    put(?TIANJIU_LIST, TianjiuList),
    List4;
%从麻将牌列表List5中取出前Num张牌将其放入List4中,呈现给玩家
take_poker(Num, [H|List5], List4) ->
    take_poker(Num - 1, List5, [H|List4]).
rand() ->
    rand:uniform().
	
rand_list(List) ->
    Idx = trunc(rand() * 1000000) rem length(List) + 1,  %取第Idx个数
    get_term_from_list(List, Idx).

%%从列表里取第Idx张牌
get_term_from_list([H | _T], 1) ->
    H;
get_term_from_list([_H | T], Idx) ->
    get_term_from_list(T, Idx - 1).


test()	->
	Playerlist=[#player{playerid=1,seatid=1},#player{playerid=2,seatid=2},#player{playerid=3,seatid=3},#player{playerid=4,seatid=4}],
	init_tianjiu(),
	put(?PLAYERLIST,Playerlist),
	%io:format("test...~p~n",[{Playerlist}]),
	put(?ZHUANGJIA_SEATID,3),
	put(?ZHUANGJIAID,1),
	card_to_players(?DAPAIJIU),
	Players=get(?PLAYERLIST),
	Player1=lists:nth(1,Players),
	Player2=lists:nth(2,Players),
	Player3=lists:nth(3,Players),
	Player4=lists:nth(4,Players),
	dianshu_of_player(Player1),
	dianshu_of_player(Player2),
	dianshu_of_player(Player3),
	dianshu_of_player(Player4),
	compare_with_zhuangjia().


