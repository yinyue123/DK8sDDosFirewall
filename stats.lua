
function stats(during)
    local timestamp = ngx.now()
    local dict = ngx.shared.traffic_stats
    for _, val in pairs(dict:get_keys(0)) do
        local match = "last:"..during
        if string.sub(val, 1, #match) == match then
            local ip = string.sub(val, #match + 2, -1)
            local last_time = dict:get(val)
            local age = math.floor(timestamp - last_time)
            local count = dict:get("count:"..during..":"..ip)
            local bytes = dict:get("bytes:"..during..":"..ip)
            local costs = dict:get("costs:"..during..":"..ip)
            local forbidden = dict:get("forbidden:"..during..":"..ip)
            local output = string.format("%20s, %15s, %15d, %15d, %15d, %15d, %15s",
                    ip, during, age, count, bytes, costs, forbidden)
            ngx.say(output)
        end
    end
end

ngx.say(string.format("%20s, %15s, %15s, %15s, %15s, %15s, %15s",
        'ip', 'during', 'age', 'count', 'bytes', 'costs', 'forbidden'))
stats("hour")
stats("day")
