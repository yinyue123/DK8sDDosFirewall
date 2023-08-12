function set_key(dict, key, value)
    local ok, err = dict:set(key, value)
    if not ok then
        ngx.log(ngx.ERR, "Set key", key, "err", err)
        -- ngx.exit(444)
        ngx.exit(429)
    end
end

function str_concat(...)
    local str = {...}
    return table.concat(str, ':')
end

function protect(during, ttl, count_limit, bytes_limit, costs_limit)
    local dict = ngx.shared.traffic_stats
    local timestamp = ngx.now()
    local ip = ngx.var.limit_key
    local count_key = str_concat("count", during, ip)
    local bytes_key = str_concat("bytes", during, ip)
    local costs_key = str_concat("costs", during, ip)
    local last_time_key = str_concat("last", during, ip)
    local forbidden_key = str_concat("forbidden", during, ip)

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
        -- ngx.exit(444)
        ngx.exit(429)
    end

    local bytes = dict:get(bytes_key)
    if bytes ~= nil and bytes > tonumber(bytes_limit) then
        set_key(dict, forbidden_key, true)
        -- ngx.exit(444)
        ngx.exit(429)
    end

    local cost = dict:get(costs_key)
    if cost ~= nil and cost > tonumber(costs_limit) then
        set_key(dict, forbidden_key, true)
        -- ngx.exit(444)
        ngx.exit(429)
    end
end

protect("hour", 3600, ngx.var.limit_count_per_hour, ngx.var.limit_bytes_per_hour, ngx.var.limit_costs_per_hour)
protect("day", 3600 * 24, ngx.var.limit_count_per_day, ngx.var.limit_bytes_per_day, ngx.var.limit_costs_per_day)
