local config = {}

    config.toTimestamp = function(date)
        local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
        local timeToConvert = date

        local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
        local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})

        return convertedTimestamp
    end

    config.mysql = {
        host = '127.0.0.1',
        username = 'username',
        password = 'password',
        database = 'flarum'
    }

    config.discord = {
        token = 'discord_token'
    }

return config
