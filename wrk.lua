local random = math.random

function request()
    local ip = string.format("%d.%d.%d.%d", random(0, 255), random(0, 255), random(0, 255), random(0, 255))
    wrk.headers["X-Forwarded-For"] = ip
    return wrk.format("GET", path)
end

-- wrk -s ./wrk.lua -c 500 -t 8 -d 600s -c 10 http://[target]
-- wrk -s ./wrk.lua -c 500 -t 8 -d 600s -c 150 http://[target]
-- wrk -s ./wrk.lua -c 500 -t 8 -d 600s -c 100000 http://[target]
