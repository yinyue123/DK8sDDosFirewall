
function stats(during)
    local request_length = ngx.var.request_length
    local bytes_sent = ngx.var.bytes_sent
    local ip = ngx.var.limit_key
    local dict = ngx.shared.traffic_stats
    local count_key = "count:"..during..":"..ip
    local bytes_key = "bytes:"..during..":"..ip
    local costs_key = "costs:"..during..":"..ip
    dict:incr(count_key, 1)
    ngx.log(ngx.ERR, "add bytes", count_key, 1)
    dict:incr(bytes_key, request_length + bytes_sent)
    ngx.log(ngx.ERR, "add bytes", bytes_key, request_length + bytes_sent)
    dict:incr(costs_key, math.floor(ngx.var.request_time * 1000))
    ngx.log(ngx.ERR, "add costs", math.floor(ngx.var.request_time * 1000))
end

stats("hour")
stats("day")
