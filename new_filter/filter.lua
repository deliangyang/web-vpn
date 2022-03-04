---
--- Created by ydl QQ: 2411125253.
--- DateTime: 2022/3/4 12:19 PM
---

local _M = {}

rule_prefix = {
    [[src=\?]],
    "action=",
    "href[=:]",
    "import (",
    "url[(:]",
    "post(",
    "get(",
    "link\":\"",
    "src=\\\"",
    "window.open(",
    "push(",
    "Path\":\"",
    "path:\"",
    "url,",
    "href\",\"",
    "href,",
    "window.location = "
}

regexp_url = '[[' .. table.concat(rule_prefix, "|") .. ']]'

return _M

