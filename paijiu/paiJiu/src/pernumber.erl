-module(pernumber).
-export([isperfect/1]).
% for i=== 1 

% 	num%i==0 ->list
% 	sum(list) ==num.

% 1. find 真约数
% 2. 求和
% 3. 比较
% lists:sum(lists:filter(IsYueShu,lists:seq(1,Num))) =:= Num
% lists:seq(1,Num);
% 函数式编程思维:不要去想迭代,只想结果,要什么,造什么
% 函数式编程中的基本构造单元:1.筛选(filter,partitions);2.映射(map,);3折叠
isperfect(Num) ->
	IsYueShu=fun(X) ->
		Num rem X =:=0
	end,
	lists:sum(lists:filter(IsYueShu,lists:seq(1,Num div 2 +1))) =:= Num.		% div 整数除,  /: 浮点数除
	


