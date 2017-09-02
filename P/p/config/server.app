%% 应用程序信息文件
{application, server, [
        {description, "server"}
        ,{vsn, "0.1"}
        ,{modules, [server]}
        ,{registered, []}
        ,{applications, [kernel, stdlib, sasl]}
        ,{mod, {server_app, []}}
        ,{env, []}
]}.
