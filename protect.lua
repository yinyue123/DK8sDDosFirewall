
function garbage_clean(dict, during, ttl, timestamp)
    local capacity = dict:capacity()
    local free_space = dict:free_space()
    local used_ratio = (capacity - free_space) / capacity
    if used_ratio < 0.9 then
        return
    end
    for key, value in dict:pairs() do
        local match = "last:"..during
        if string.sub(key, 1, #match) == match then
            local ip = string.sub(str, #match + 1, -1)
            if value + ttl < timestamp then
                dict:delete(key)
                dict:delete("count:"..during..":"..ip)
                dict:delete("bytes:"..during..":"..ip)
                dict:delete("costs:"..during..":"..ip)
                ngx.log(ngx.ERR, "Garbage clean", key)
            end
        end
    end
end

function set_key(dict, key, value)
    local ok, err = dict:set(key, value)
    if not ok then
        ngx.log(ngx.ERR, "Set key", key, "err", err)
        ngx.exit(444)
    end
end

function protect(during, ttl, count_limit, bytes_limit, costs_limit)
    local dict = ngx.shared.traffic_stats
    local timestamp = ngx.now()
    local ip = ngx.var.limit_key
    local count_key = "count:"..during..":"..ip
    local bytes_key = "bytes:"..during..":"..ip
    local costs_key = "costs:"..during..":"..ip
    local last_time_key = "last:"..during..":"..ip

    garbage_clean(dict, during, ttl, timestamp)
    local last_time = dict:get(last_time_key)
    if last_time == nil or last_time + ttl < timestamp then
        set_key(dict, last_time_key, timestamp)
        set_key(dict, count_key, 0)
        set_key(dict, bytes_key, 0)
        set_key(dict, costs_key, 0)
        ngx.log(ngx.ERR, "add ip", last_time_key, count_key, bytes_key, costs_key)
    end

    local count = dict:get(count_key)
    ngx.log(ngx.ERR, "get count", count_key, count)
    if count ~= nil and count > tonumber(count_limit) then
        ngx.exit(444)
    end

    local bytes = dict:get(bytes_key)
    ngx.log(ngx.ERR, "get bytes", bytes_key, bytes)
    if bytes ~= nil and bytes > tonumber(bytes_limit) then
        ngx.exit(444)
    end

    local cost = dict:get(costs_key)
    ngx.log(ngx.ERR, "get costs", costs_key, cost)
    if bytes ~= nil and bytes > tonumber(costs_limit) then
        ngx.exit(444)
    end
end

protect("hour", 3600, ngx.var.limit_count_per_hour, ngx.var.limit_bytes_per_hour, ngx.var.limit_costs_per_hour)
protect("day", 3600 * 24, ngx.var.limit_count_per_day, ngx.var.limit_bytes_per_day, ngx.var.limit_costs_per_hour)
