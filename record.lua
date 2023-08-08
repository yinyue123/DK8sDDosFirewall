
function stats(during)
    local request_length = ngx.var.request_length
    local bytes_sent = ngx.var.bytes_sent
    local ip = ngx.var.limit_key
    local dict = ngx.shared.traffic_stats
    local count_key = "count:"..during..":"..ip
    local bytes_key = "bytes:"..during..":"..ip
    local costs_key = "costs:"..during..":"..ip
    dict:incr(count_key, 1)
    dict:incr(bytes_key, request_length + bytes_sent)
    dict:incr(costs_key, math.floor(ngx.var.request_time * 1000))
    ngx.log(ngx.INFO, string.format('Usage %20s %5d %5d %5d',
            ip, 1, request_length + bytes_sent, math.floor(ngx.var.request_time * 1000)))
end

stats("hour")
stats("day")
