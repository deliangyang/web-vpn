cp xx.conf /usr/local/etc/openresty/conf.d/
# cp new_filter/fiter.lua /usr/local/etc/openresty/conf.d/
openresty -s stop
openresty -t
openresty

echo '===============================================' >> /Users/ydl/work/company/untitled1/error.log

curl -s 127.0.0.1:9964/a.php > a.html
curl -s 127.0.0.1:9964/b/c/d/e/f/a.php > b.html


tail -f /Users/ydl/work/company/untitled1/error.log