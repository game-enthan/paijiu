-- 登录协议
require "proto.pb_10_login_pb"
-- 大厅协议
require "proto.pb_11_hall_pb"
-- 消息协议
require "proto.pb_13_msg_pb"
-- 战绩协议
require "proto.pb_14_record_pb"
-- 商城协议
require "proto.pb_18_mall_pb"
-- 牛牛协议
require "proto.pb_12_room_niuniu_pb"
-- 炸金花协议
require "proto.pb_15_room_zhajinhua_pb"
-- 斗地主协议
require "proto.pb_16_room_doudizhu_pb"
-- 挖坑协议
require "proto.pb_17_room_wakeng_pb"
-- 十点半协议
require "proto.pb_19_room_shidianban_pb"
-- 推对子协议
require "proto.pb_20_room_tuiduizi_pb"
-- 排行榜协议
require "proto.pb_21_activity_pb"
-- 三代协议
require "proto.pb_22_room_sandai_pb"

local ProtoConfig = {
	---------------- 登录模块 S --------------
	[10000] = {profile = pb_10_login_pb, proStruct = nil},
	[10001] = {profile = pb_10_login_pb, proStruct = "pbServerTime"},
	[10002] = {profile = pb_10_login_pb, proStruct = "pbWXLogin"},
	[10003] = {profile = pb_10_login_pb, proStruct = "pbTempAccountLogin"},
	[10004] = {profile = pb_10_login_pb, proStruct = "pbFormalAccountLogin"},
	[10005] = {profile = pb_10_login_pb, proStruct = "pbLoginSuccess"},
	[10006] = {profile = pb_10_login_pb, proStruct = "pbLoginFailed"},
	[10007] = {profile = pb_10_login_pb, proStruct = nil},
	[10008] = {profile = pb_10_login_pb, proStruct = nil},
	[10009] = {profile = pb_10_login_pb, proStruct = "pbPlayerRoomCard"},
	[10010] = {profile = pb_10_login_pb, proStruct = "pbLoginInviteCode"},
	[10011] = {profile = pb_10_login_pb, proStruct = "pbLoginInviteCodeResult"},
	[10012] = {profile = pb_10_login_pb, proStruct = "pbFormalAccountLogin"},
	[10013] = {profile = pb_10_login_pb, proStruct = nil},
	[10014] = {profile = pb_10_login_pb, proStruct = nil},
	---------------- 登录模块 E --------------
	---------------- 大厅模块 S --------------
	[11000] = {profile = pb_11_hall_pb, proStruct = "pbJoinInRoom"},
	[11001] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomBull"},
	[11002] = {profile = pb_11_hall_pb, proStruct = nil},
	[11003] = {profile = pb_11_hall_pb, proStruct = "pbBasePlayer"},
	[11004] = {profile = pb_11_hall_pb, proStruct = "pbBasePlayer"},
	[11005] = {profile = pb_11_hall_pb, proStruct = nil},
	[11006] = {profile = pb_11_hall_pb, proStruct = nil},
	[11007] = {profile = pb_11_hall_pb, proStruct = "pbBasePlayer"},
	[11008] = {profile = pb_11_hall_pb, proStruct = nil},
	[11009] = {profile = pb_11_hall_pb, proStruct = "pbBasePlayer"},
	[11010] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomGoldFlower"},
	[11011] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomDoudizhu"},
	[11012] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomShanxiWakeng"},
	[11013] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomLanzhouWakeng"},
	[11014] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomTenHalf"},
	[11015] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomPushPairs"},
	[11016] = {profile = pb_11_hall_pb, proStruct = "pbNumber"},
	[11017] = {profile = pb_11_hall_pb, proStruct = "pbNumber"},
	[11018] = {profile = pb_11_hall_pb, proStruct = "pbDismissInfo"},
	[11019] = {profile = pb_11_hall_pb, proStruct = "pbCreateRoomSanDai"},
	---------------- 大厅模块 E --------------
	---------------- 消息模块 S --------------
	[13001] = {profile = pb_13_msg_pb, proStruct = "pbError"},
	[13002] = {profile = pb_13_msg_pb, proStruct = "pbMsgChat"},
	[13003] = {profile = pb_13_msg_pb, proStruct = "pbMsgChat"},
	[13004] = {profile = pb_13_msg_pb, proStruct = "pbHdImg"},
	[13005] = {profile = pb_13_msg_pb, proStruct = "pbLoopNotice"},
	[13006] = {profile = pb_13_msg_pb, proStruct = "pbHdNotice"},
	---------------- 消息模块 E --------------
	---------------- 战绩模块 S --------------
	[14001] = {profile = pb_14_record_pb, proStruct = "pbRecordType"},
	[14002] = {profile = pb_14_record_pb, proStruct = "pbRecordList"},
	[14003] = {profile = pb_14_record_pb, proStruct = "pbRecordRecordId"},
	[14004] = {profile = pb_14_record_pb, proStruct = "pbRecordRoundList"},
	[14005] = {profile = pb_14_record_pb, proStruct = "pbRecordRoundId"},
	[14006] = {profile = pb_14_record_pb, proStruct = "pbRecordRoundId"},
	[14007] = {profile = pb_14_record_pb, proStruct = "pbRecordRoundId"},
	---------------- 战绩模块 E --------------
	---------------- 商城模块 S --------------
	[18000] = {profile = pb_18_mall_pb, proStruct = "pbMallType"},
	[18001] = {profile = pb_18_mall_pb, proStruct = "pbMallInfo"},
	[18002] = {profile = pb_18_mall_pb, proStruct = "pbMallPay"},
	[18003] = {profile = pb_18_mall_pb, proStruct = "pbMallPayResult"},
	[18004] = {profile = pb_18_mall_pb, proStruct = "pbMallRecipt"},
	---------------- 商城模块 E --------------
	---------------- 牛牛模块 S --------------
	[12001] = {profile = pb_12_room_niuniu_pb, proStruct = "pbRoomInfoNiuNiu"},
	[12002] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerOnline"},
	[12003] = {profile = pb_12_room_niuniu_pb, proStruct = "pbQiangZhuang"},
	[12004] = {profile = pb_12_room_niuniu_pb, proStruct = "pbQiangZhuangState"},
	[12005] = {profile = pb_12_room_niuniu_pb, proStruct = "pbChipIn"},
	[12006] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerChipIn"},
	[12007] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPokerList"},
	[12008] = {profile = pb_12_room_niuniu_pb, proStruct = "pbAllPlayerPokerList"},
	[12009] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayer"},
	[12010] = {profile = pb_12_room_niuniu_pb, proStruct = "pbRoomState"},
	[12012] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerRoundCalc"},
	[12013] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12014] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12015] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerId"},
	[12016] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerId"},
	[12017] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerId"},
	[12018] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerFinalCalc"},
	[12019] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12020] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12021] = {profile = pb_12_room_niuniu_pb, proStruct = "pbPlayerId"},
	[12022] = {profile = pb_12_room_niuniu_pb, proStruct = "pbNumber"},
	[12023] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12024] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12025] = {profile = pb_12_room_niuniu_pb, proStruct = "pbNumber"},
	[12026] = {profile = pb_12_room_niuniu_pb, proStruct = "pbNumber"},
	[12027] = {profile = pb_12_room_niuniu_pb, proStruct = "pbQiangScore"},
	[12028] = {profile = pb_12_room_niuniu_pb, proStruct = "pbAgentRoomInfoNiuNiu"},
	[12029] = {profile = pb_12_room_niuniu_pb, proStruct = nil},
	[12030] = {profile = pb_12_room_niuniu_pb, proStruct = "pbAgentRoomInfoNiuNiuList"},
	---------------- 牛牛模块 E --------------
	---------------- 炸金花模块 S ------------
	[15001] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaRoomInfo"},
	[15002] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerOnline"},
	[15003] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15004] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerChipIn"},
	[15005] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaNumber"},
	[15006] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerChipIn"},
	[15007] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15008] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15009] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaNumber"},
	[15010] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPokerList"},
	[15011] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15012] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15013] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15014] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerVs"},
	[15015] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15016] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaNumber"},
	[15017] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaNumber"},
	[15018] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaNumber"},
	[15019] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayer"},
	[15020] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaRoomState"},
	[15021] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerRoundCalc"},
	[15022] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15023] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15024] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15025] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerFinalCalc"},
	[15026] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15027] = {profile = pb_15_room_zhajinhua_pb, proStruct = nil},
	[15028] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15029] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbZhajinhuaPlayerId"},
	[15030] = {profile = pb_15_room_zhajinhua_pb, proStruct = "pbpbZhajinhuaPlayerChipInList"},
	---------------- 炸金花模块 E ------------
	---------------- 斗地主模块 S ------------
	[16001] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuRoomInfo"},
	[16002] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerOnline"},
	[16003] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuRoomState"},
	[16004] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPokerList"},
	[16005] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerId"},
	[16006] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuCallDizhu"},
	[16007] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuCallDizhu"},
	[16008] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuCallDizhu"},
	[16009] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPokerList"},
	[16011] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPokerList"},
	[16012] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuDiscardPokerList"},
	[16013] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuNumber"},
	[16015] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerId"},
	[16017] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerRoundCalc"},
	[16018] = {profile = pb_16_room_doudizhu_pb, proStruct = nil},
	[16019] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerId"},
	[16020] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayerFinalCalc"},
	[16021] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuPlayer"},
	[16022] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuNumber"},
	[16023] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuNumber"},
	[16024] = {profile = pb_16_room_doudizhu_pb, proStruct = "pbDoudizhuNumber"},
	---------------- 斗地主模块 E ------------
	---------------- 挖坑模块 S --------------
	[17001] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengRoomInfo"},
	[17002] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerOnline"},
	[17003] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengRoomState"},
	[17004] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPokerList"},
	[17005] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerId"},
	[17006] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengCallDizhu"},
	[17007] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengCallDizhu"},
	[17008] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengCallDizhu"},
	[17009] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPokerList"},
	[17011] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPokerList"},
	[17012] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengDiscardPokerList"},
	[17013] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengNumber"},
	[17015] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerId"},
	[17017] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerRoundCalc"},
	[17018] = {profile = pb_17_room_wakeng_pb, proStruct = nil},
	[17019] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerId"},
	[17020] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayerFinalCalc"},
	[17021] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengPlayer"},
	[17022] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengNumber"},
	[17023] = {profile = pb_17_room_wakeng_pb, proStruct = "pbWakengNumber"},
	---------------- 挖坑模块 E --------------
	--------------- 十点半模块 S -------------
	[19001] = {profile = pb_19_room_shidianban_pb, proStruct = "pbRoomInfoShidianban"},
	[19002] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerOnline"},
	[19003] = {profile = pb_19_room_shidianban_pb, proStruct = "pbChipin"},
	[19004] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerChipin"},
	[19005] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerPokerList"},
	[19006] = {profile = pb_19_room_shidianban_pb, proStruct = "pbAllPlayerPokerList"},
	[19007] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayer"},
	[19008] = {profile = pb_19_room_shidianban_pb, proStruct = "pbRoomState"},
	[19009] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerRoundCalc"},
	[19010] = {profile = pb_19_room_shidianban_pb, proStruct = nil},
	[19011] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerPokerList"},
	[19012] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerId"},
	[19013] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerId"},
	[19014] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerFinalCalc"},
	[19015] = {profile = pb_19_room_shidianban_pb, proStruct = nil},
	[19016] = {profile = pb_19_room_shidianban_pb, proStruct = nil},
	[19017] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerId"},
	[19018] = {profile = pb_19_room_shidianban_pb, proStruct = "pbTakepokerState"},
	[19019] = {profile = pb_19_room_shidianban_pb, proStruct = "pbTakepoker"},
	[19020] = {profile = pb_19_room_shidianban_pb, proStruct = "pbAddchipin"},
	[19021] = {profile = pb_19_room_shidianban_pb, proStruct = "pbPlayerId"},
	--------------- 十点半模块 E -------------
	--------------- 推对子模块 S -------------
	[20001] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbRoomInfoTuiduizi"},
	[20002] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerOnline"},
	[20003] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbChip"},
	[20004] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerChipin"},
	[20005] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayer"},
	[20006] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbRoomState"},
	[20007] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerRoundCalc"},
	[20008] = {profile = pb_20_room_tuiduizi_pb, proStruct = nil},
	[20009] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbMahjongList"},
	[20010] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerId"},
	[20011] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerId"},
	[20012] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerFinalCalc"},
	[20013] = {profile = pb_20_room_tuiduizi_pb, proStruct = nil},
	[20014] = {profile = pb_20_room_tuiduizi_pb, proStruct = nil},
	[20015] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbPlayerId"},
	[20016] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbShaizi"},
	[20017] = {profile = pb_20_room_tuiduizi_pb, proStruct = "pbChipInTime"},
	[20018] = {profile = pb_20_room_tuiduizi_pb, proStruct = nil},
	--------------- 推对子模块 E -------------
	--------------- 排行榜模块 S -------------
	[21001] = {profile = pb_21_activity_pb, proStruct = nil},
	[21002] = {profile = pb_21_activity_pb, proStruct = "pbRank"},
	--------------- 排行榜模块 E -------------
	--------------- 三代模块 S -------------
	[22001] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiRoomInfo"},
	[22002] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerOnline"},
	[22003] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiRoomState"},
	[22004] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPokerList"},
	[22005] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerId"},
	[22006] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPokerList"},
	[22007] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiDiscardPokerList"},
	[22008] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiNumber"},
	[22009] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerId"},
	[22010] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerRoundCalc"},
	[22011] = {profile = pb_22_room_sandai_pb, proStruct = nil},
	[22012] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerId"},
	[22013] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayerFinalCalc"},
	[22014] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiPlayer"},
	[22015] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiNumber"},
	[22016] = {profile = pb_22_room_sandai_pb, proStruct = "pbSandaiNumber"},
	[22017] = {profile = pb_22_room_sandai_pb, proStruct = nil},
	[22018] = {profile = pb_22_room_sandai_pb, proStruct = "pbTipping"},
	--------------- 三代模块 E -------------
}

return ProtoConfig