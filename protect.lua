
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
                ngx.log(ngx.INFO, "Garbage clean", key)
            end
        end
    end
end

function set_key(dict, key, value)
    local ok, err = dict:set(key, value)
    if not ok then
        ngx.log(ngx.ERROR, "Set key", key, "err", err)
        ngx.exit(444)
    end
end

function protect(during, ttl, count_limit, bytes_limit)
    local dict = ngx.shared.traffic_stats
    local timestamp = ngx.now()
    local ip = ngx.var.limit_key
    local count_key = "count:"..during..":"..ip
    local bytes_key = "bytes:"..during..":"..ip
    local last_time_key = "last:"..during..":"..ip

    garbage_clean(dict, during, ttl, timestamp)
    local last_time = dict:get(last_time_key)
    if last_time == nil or last_time + ttl < timestamp then
        local lock_key = "lock"
        local acquired, err = dict.add(lock_key, true) -- nice to have
        if acquired then
            set_key(dict, last_time_key, timestamp)
            set_key(dict, count_key, 0)
            set_key(dict, bytes_key, 0)
            dict:delete(lock_key)
        else
            ngx.log(ngx.INFO, "Failed to acquired lock:", err, ". try again later!")
        end
    end

    local count = dict:get(count_key)
    if count ~= nil and count > count_limit then
        ngx.exit(444)
    end

    local bytes = dict:get(bytes_key)
    if bytes ~= nil and bytes > bytes_limit then
        ngx.exit(444)
    end

end

protect("hour", 3600, ngx.var.limit_count_per_hour, ngx.var.bytes_limit_per_hour)
protect("day", 3600 * 24, ngx.var.limit_count_per_day, ngx.var.bytes_limit_per_day)
