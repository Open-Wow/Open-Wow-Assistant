local topics = {}
  topics.latestTopics = '0'
  topics.latestComment = '0'

  require('utf-8_extensions')

local config = require('config')

local mySQLDriver = require('luasql.mysql')
local mysqlClient = assert(mySQLDriver.mysql():connect(config.mysql.database, config.mysql.username, config.mysql.password, config.mysql.host))

function topics.getLatestComment()
  if not mysqlClient:ping() then
    mysqlClient = assert(mySQLDriver.mysql():connect(config.mysql.database, config.mysql.username, config.mysql.password, config.mysql.host))
  end

  local getComment = assert(mysqlClient:execute("SELECT `discussion_id`, `created_at` FROM `posts` WHERE `created_at` = (SELECT MAX(`created_at`)  FROM `posts`) and type != 'discussionTagged' and number > 2"))
  local commentRow = getComment:fetch({}, "a")

  if commentRow then
    local getTopics = assert(mysqlClient:execute("SELECT `title`, `slug` FROM `discussions` WHERE `id` = "..commentRow.discussion_id..""))
    local topicsRow = getTopics:fetch({}, "a")

    local tempData = {}

    if tostring(config.toTimestamp(commentRow.created_at)) > topics.latestComment then
      table.insert(tempData, {name = tostring(topicsRow.title:toutf8()), value  = 'https://forum.open-wow.eu/d/'..commentRow.discussion_id..'-'..topicsRow.slug..'\n\nDate de mise en ligne : '..commentRow.created_at, inline = false})
      topics.latestComment = tostring(config.toTimestamp(commentRow.created_at))

      return tempData
    end
  end

  mysqlClient:close()
end

function topics.getLatestTopics()
  if not mysqlClient:ping() then
    mysqlClient = assert(mySQLDriver.mysql():connect(config.mysql.database, config.mysql.username, config.mysql.password, config.mysql.host))
  end

  local getTopics = assert(mysqlClient:execute("SELECT `id`, `title`, `slug`, `created_at` FROM `discussions` WHERE `created_at` = (SELECT MAX(`created_at`) FROM `discussions`)"))
  local row = getTopics:fetch({}, "a")
  local tempData = {}

  if tostring(config.toTimestamp(row.created_at)) > topics.latestTopics then
    table.insert(tempData, {name = tostring(row.title:toutf8()), value  = 'https://forum.open-wow.eu/d/'..row.id..'-'..row.slug..'\n\nDate de mise en ligne : '..row.created_at, inline = false})
    topics.latestTopics = tostring(config.toTimestamp(row.created_at))

    return tempData
  end

  mysqlClient:close()
end

function topics.getList(like)
  if not mysqlClient:ping() then
    mysqlClient = assert(mySQLDriver.mysql():connect(config.mysql.database, config.mysql.username, config.mysql.password, config.mysql.host))
  end

  like = string.gsub(like, '"', '\\"')
  like = string.gsub(like, "'", "\\'")

  local getTopics = assert(mysqlClient:execute("SELECT id, title, slug FROM discussions WHERE title like '%"..like.."%'"))
  local row = getTopics:fetch({}, "a")

  if row then
    local tempData = {}

    while row do
      table.insert(tempData, {name = tostring(row.title:toutf8()), value  = 'https://forum.open-wow.eu/d/'..row.id..'-'..row.slug, inline = false})
      row = getTopics:fetch(row, "a")
    end

    return tempData
  else
    return false
  end

  mysqlClient:close()
end

return topics