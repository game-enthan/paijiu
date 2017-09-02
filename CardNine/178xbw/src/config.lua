GL_VIEW_NAME = "棋牌室"

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- open ldb
ENABLE_ERROR = false

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- set FPS
FPS = 1 / 60

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1280,
    height = 720,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1280 / 720 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}

_G.printR = print

-- _G.print = function()
-- end

-- if ENABLE_LDB then
--     require("lib/ldb")
--     db = ldb.ldb_open
-- end
-- 测试服IP/PORT
G_T_HOST = "127.0.0.1"
G_T_PORT = 9000
G_TEST = true

-- 服务器列表
G_SERVER_CNF = {}

-- 服务器IP/PORT
G_HOST = ""
G_PORT = 0
-- server url config
SERVER_CNF = {
    [1] = "https://dl.szmia.com/178/qw.txt",
    [2] = "https://dl.szmia.com/178/as.txt",
    [3] = "https://dl.szmia.com/178/zx.txt",
    [4] = "https://dl.szmia.com/178/er.txt",
    [5] = "https://dl.szmia.com/178/df.txt",
    [6] = "https://dl.szmia.com/178/cv.txt",
    [7] = "https://dl.szmia.com/178/b90n.txt",
    [8] = "https://dl.szmia.com/178/u7ui.txt",
    [9] = "https://dl.szmia.com/178/xfid.txt",
    [10] = "https://dl.szmia.com/178/iii3.txt",
    [11] = "https://dl.szmia.com/178/ppik.txt",
    [12] = "https://dl.szmia.com/178/ddxi.txt",
}

G_WX_CODE = ""
-- 掌支付appid
G_ZZF_ANDROID_APP_ID = 3206
G_ZZF_APPLE_APP_ID  = 3207
G_ZZF_WRAP_APP_ID = 3412
-- 游戏连接
GAME_URL = "http://www.nnnnnnnnnn168.com/178/178.htm?uid=%s&v=%s"
-- 审核标记(当前是审核包，以前端为准)
LOCAL_REVIEWING_FLAG = false
-- 心跳包发送间隔
HEART_BEAT_INTERVAL = 3
-- 检测断线时间间隔
CHECK_CON_INTERVAL = 1
-- 断线时间
DISCONNECT_TIME = 3