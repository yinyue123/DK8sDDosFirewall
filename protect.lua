
function garbage_clean(dict, during, ttl, timestamp)
    local capacity = dict:capacity()
    local free_space = dict:free_space()
    local used_ratio = (capacity - free_space) / capacity
    if used_ratio < 0.9 then
        return
    end
    for _, val in pairs(dict:get_keys()) do
        local match = "last:"..during
        if string.sub(val, 1, #match) == match then
            local ip = string.sub(val, #match + 2, -1)
            local last_time = dict:get(val);
            if last_time + ttl < timestamp then
                dict:delete(val)
                dict:delete("count:"..during..":"..ip)
                dict:delete("bytes:"..during..":"..ip)
                dict:delete("costs:"..during..":"..ip)
                ngx.log(ngx.INFO, "Garbage Clean", val)
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
    local forbidden_key = "last:"..during..":"..ip

    garbage_clean(dict, during, ttl, timestamp)
    local last_time = dict:get(last_time_key)
    if last_time == nil or last_time + ttl < timestamp then
        set_key(dict, last_time_key, timestamp)
        set_key(dict, count_key, 0)
        set_key(dict, bytes_key, 0)
        set_key(dict, costs_key, 0)
        set_key(dict, forbidden_key, false)
    end

    local count = dict:get(count_key)
    if count ~= nil and count > tonumber(count_limit) then
        set_key(dict, forbidden_key, true)
        ngx.exit(444)
    end

    local bytes = dict:get(bytes_key)
    if bytes ~= nil and bytes > tonumber(bytes_limit) then
        set_key(dict, forbidden_key, true)
        ngx.exit(444)
    end

    local cost = dict:get(costs_key)
    if cost ~= nil and cost > tonumber(costs_limit) then
        set_key(dict, forbidden_key, true)
        ngx.exit(444)
    end
end

protect("hour", 3600, ngx.var.limit_count_per_hour, ngx.var.limit_bytes_per_hour, ngx.var.limit_costs_per_hour)
protect("day", 3600 * 24, ngx.var.limit_count_per_day, ngx.var.limit_bytes_per_day, ngx.var.limit_costs_per_day)
