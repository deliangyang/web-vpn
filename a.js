reg = [

    //  # 前缀, 必须有  'action='(表单) 'href='(链接) 'src=' 'url('(css) '@import'(css) '":'(js/json, "key":"value")
    //  # \s 表示空白字符,如空格tab
    /(\b(?:(?:src|href|action)\s*=|url\s*\(|@import\s*|"\s*:)\s*)/,  // prefix, eg: src=
    // 左边引号, 可选 (因为url()允许没有引号). 如果是url以外的, 必须有引号且左右相等(在重写函数中判断, 写在正则里可读性太差)
    /(["'])?/, // quote  "'
    // 域名和协议头, 可选. http:// https:// // http:\/\/ (json) https:\/\/ (json) \/\/ (json)
    /(((?:https?:)?\\?\/\\?\/)((?:[-a-z0-9]+\.)+[a-z]+(:\d{1,5})?))?/,
    // url路径, 含参数 可选
    // full path(with query string)  /foo/bar.js?love=luciaZ
    // 查询字符串, 可选
    // query string  ?love=luciaZ
    /([^\s;+$?#'"\{}]*?(\?[^\s?#'"]*?)?)/,
    //右引号(可以是右括弧), 必须
    /(["')])(\W)/g].map(function (r) {
    return r.source
}).join('')

console.log(reg)

const regex_adv_url_rewriter = new RegExp(reg, "gi");