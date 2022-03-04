local url = require("url")

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

-- local host =
-- local headers = ngx.req.get_headers()

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

-- 替换规则
function replace (args)
    -- m 是一个 数组10个元素
    --for i = 1, #m do
    --    ngx.log(ngx.ERR,  'replace#' .. tostring(i) .. tostring(m[i]) .. '####')
    --end
    prefix = args[1]
    quote_left = args[2]
    domain_and_scheme = args[3]
    scheme = args[4]
    domain = args[5]
    port = args[6]
    path = args[7]
    query_string = args[8]
    quote_right = args[9]
    right_suffix = args[10]

    local urlPath = path

    -- ip类型 正则匹配不准，需要重新匹配格式化  如 href="http://139.198.16.175:8076/"
    local newParse = url.parse(urlPath)-- 真实url的 url 解析
    local vpn_host = ngx.var.vpn_host
    local proxy_sip = ngx.var.proxy_sip
    if right_suffix == false then
        right_suffix = ''
    end

    if quote_left == false then
        quote_left = ''
    end
    if quote_right == false then
        quote_right = ''
    end

    if (port == false and domain == false and scheme == false) then
        if newParse.port ~= nil then
            port = newParse.port
        end

        if (newParse.host ~= nil) then
            domain = newParse.host
        end

        if (newParse.protocol ~= nil) then
            scheme = newParse.protocol + "//"
        end

        if (newParse.pathname ~= nil) then
            urlPath = newParse.path
        end

        if path == false then
            path = ''
        end
        if query_string == false then
            query_string = ''
        end
    else
        proxy_sip = domain
    end

    -- 不替换逻辑
    if scheme ~= false and #scheme > 0 and string.indexOf(scheme, '//') >= 0 then

    elseif (#path > 0 and string.indexOf(path, '/') ~= 1)
            or string.indexOf(path, 'javascript') > -1
            or right_suffix == '#'
            or path == ''
            or (quote_right == ')' and (quote_left == '' or quote_left == false))
            or string.indexOf(path, '..') == 1 then
        return prefix .. quote_left .. path .. quote_right .. right_suffix --.. x_debug(args)
    end

    -- return x_debug(args)
    return prefix .. quote_left .. 'http://' .. vpn_host .. '/' .. proxy_sip .. path .. quote_right .. right_suffix
end

if eof then
    local whole = table.concat(buffered)
    ngx.ctx.buffered = nil
    local vpn_host = ngx.var.vpn_host
    local proxy_sip = ngx.var.proxy_sip
    whole = ngx.re.gsub(whole, [[(=\s?["'])(/[^"';]+["'])]], function(m)
        if string.indexOf(m[2], '//') >= 0 then
            return m[1] .. m[2]
        end
        return m[1] .. 'http://' .. vpn_host .. '/' .. proxy_sip .. m[2]
    end)
    -- whole = 'src="javascript:(0)"'
    -- whole = 'src="/js/jquery.js"''

    regexp_urls = [[(\b(?:(?:src|href|action)\s*=|url\s*\(|@import\s*|"\s*:)\s*)(["'])?(((?:https?:)?\\?\/\\?\/)((?:[-a-z0-9]+\.)+[a-z]+(:\d{1,5})?))?([^\s;+$?#'"\{}]*?(\?[^\s?#'"]*?)?)(["')])(\W)]]
    whole = ngx.re.gsub(whole, regexp_urls, replace)

    ngx.arg[1] = whole
end