
function protect(during)
    local timestamp = ngx.now()
    local dict = ngx.shared.traffic_stats
    for key, value in pairs(dict:get_keys()) do
        ngx.log(ngx.ERR, key, value)
        ngx.say(key, ",", value)
        local match = "last:"..during
        if string.sub(key, 1, #match) == match then
            local ip = string.sub(str, #match + 1, -1)
            local last = value - timestamp
            local count = dict:get("count:"..during..":"..ip)
            local bytes = dict:get("bytes:"..during..":"..ip)
            local costs = dict:get("costs:"..during..":"..ip)
            ngx.say(ip, ",", during, ",", last, ",", count, ",", bytes, ",", costs)
        end
    end
end

ngx.say("stats")
protect("hour")
protect("day")
