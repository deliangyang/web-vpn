local url = require("url")

-- 规则前缀
rule_prefix = {
    [[src=\\?]],
    "src \"?:",
    [[src",]],
    "link\":",
    "action=",
    [[href=\\]],
    "href[=:]",
    "import \\(",
    "url\":",
    "url[,(:]",
    "post\\(",
    "get\\(",
    "window.open\\(",
    "push\\(",
    "Path\":",
    "path[:=]",
    "href\",",
    "href,",
    [[img',\s*?]],
    "window.location = ",
    'https?'
}

local regexp_url = [[(]] .. table.concat(rule_prefix, "|") .. [[)]] .. [[([\"'\s]*?)]] .. [[([^"'\s\r\n\t,;<>)]+)]]

local chunk, eof = ngx.arg[1], ngx.arg[2]
local buffered = ngx.ctx.buffered
if not buffered then
    buffered = {}
    ngx.ctx.buffered = buffered
end
if chunk ~= "" then
    buffered[#buffered + 1] = chunk
    ngx.arg[1] = nil
end

function string.indexOf(s, pattern, init)
    init = init or 0
    local index = string.find(s, pattern, init, true)
    return index or -1;
end

function x_debug(args)
    local whole = "\n"
    for i = 1, #args do
        whole = whole .. 'replace#' .. tostring(i) .. tostring(args[i]) .. '++++\n'
    end
    return whole
end

vpn_host = ngx.var.vpn_host
proxy_sip = ngx.var.proxy_sip
scheme = ngx.var.scheme

function StripFileName(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$")  -- *nix system
end

local current_uri = ''
if ngx.var.uri ~= nil then
    current_uri = StripFileName(ngx.var.uri)
    if current_uri == nil then
        current_uri = ''
    end
    ngx.log(ngx.ERR, 'uri: ' .. tostring(ngx.var.uri) .. current_uri)
end


-- 替换规则
function replace (args)
    ngx.log(ngx.ERR, current_uri .. '=>   ' .. args[1] .. '#------#' .. args[2] .. '#------#' .. args[3]);
    local prefix_l2 = string.sub(args[3], 0, 2)
    if args[2] == '' and (args[1] == 'https' or args[1] == 'http') and prefix_l2 == ':/' then
        return scheme .. '://' .. vpn_host .. '/' .. string.gsub(args[3], '://', '', 3)
    end

    if args[2] ~= "'" and args[2] ~= '"' then
        return args[1] .. args[2] .. args[3]
    end
    local prefix_l1 = string.sub(args[3], 0, 1)
    local l = #args[3]

    if l == 0 then
        return args[1] .. args[2] .. args[3]
    elseif l == 1 and prefix_l1 == '"' then
        return ""
    elseif prefix_l2 == '..' then
        return args[1] .. args[2] .. args[3]
    elseif prefix_l2 == './' then
        return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. proxy_sip .. current_uri .. string.sub(args[3], 2)
    elseif prefix_l2 == '/' then
        return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. proxy_sip .. '/'
    elseif prefix_l2 == 'ja' and string.indexOf(args[3], 'javascript') > 0 then
        return args[1] .. args[2] .. args[3]
    elseif prefix_l2 == '//' then
        return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. string.sub(args[3], 3)
    elseif prefix_l2 == "\\/" then
        return args[1] .. args[2] .. scheme .. ':\\/\\/' .. vpn_host .. '/' .. proxy_sip .. '\\/' .. string.sub(args[3], 3)
    elseif prefix_l1 == '#' or prefix_l1 == '+' then
        return args[1] .. args[2] .. args[3]
    elseif prefix_l1 == '/' then
        return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. proxy_sip .. '/' .. string.sub(args[3], 2)
    end

    ---- ip类型 正则匹配不准，需要重新匹配格式化  如 href="http://139.198.16.175:8076/"
    local newParse = url.parse(args[3]) -- 真实url的 url 解析
    if newParse.host ~= nil then
        if newParse.host ~= vpn_host then
            if newParse.scheme ~= nil then
                return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. string.gsub(args[3], newParse.scheme .. '://', '', 7)
            else
                -- //www.baidu.com
                return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. string.gsub(args[3], newParse.scheme .. '//', '', 7)
            end
        else
            return args[1] .. args[2] .. args[3]
        end
    end

    if prefix_l1 ~= '/' then
        return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. proxy_sip .. current_uri .. '/' .. args[3]
    end

    return args[1] .. args[2] .. scheme .. '://' .. vpn_host .. '/' .. proxy_sip .. '/' .. args[3]
end

if eof then
    local whole = table.concat(buffered)
    ngx.ctx.buffered = nil
    -- ngx.log(ngx.ERR, 'replace string: ' .. regexp_url)
    whole = ngx.re.gsub(whole, regexp_url, replace)
    ngx.arg[1] = whole
end