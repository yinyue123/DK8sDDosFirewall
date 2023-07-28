
function ping()
    for i=1, 100 do
        ngx.say(i)
        ngx.flush(true)
        ngx.sleep(0.1)
    end
end

ping()
