local discordia = require('discordia')
local client = discordia.Client()

local openwow = {
  mysql = {
    driver = require('luasql.mysql'),
    host = '127.0.0.1',
    user = 'wowserver',
    pass = 'wowserver',
    db = 'R0_Discord'
  },
  roles = {
    ['cpp'] = '834026020272472094',
    ['lua'] = '834026046353440768',
    ['mc'] = '834026079375065089',
    ['sql'] = '834026002463326218'
  }
}
  openwow.assistant = {}
  openwow.members = {}

local mysql = assert(openwow.mysql.driver.mysql():connect(openwow.mysql.db, openwow.mysql.user, openwow.mysql.pass));

function openwow.createMember(name)
  if not name then
    return false
  end

  if not openwow.members[name] then
    openwow.members[name] = {
      statistics = {
        discord_messages = 0,
        forum_topics = 0,
      },
      forumUser = nil,
      isContrib = false,

      config = {
        command = '',
        step = 0,
        informations = ''
      }
    }
    mysql:execute('INSERT INTO user_informations (username, discord_user) VALUES ("", "'..name..'")')
  else
    return false
  end

  return openwow.members[name]
end

function openwow.getTopics(name)
  if not name then
    return false
  end

  if not openwow.members[name] then
    openwow.createMember(name)
  end

  local getTopics = mysql:execute('SELECT topics FROM user_informations WHERE discord_user ="'..name..'"')
  local row = getTopics:fetch({}, "a")

  if (row) then
    openwow.members[name].statistics.forum_topics = row.topics
  end
  getTopics:close()

  return true
end

function openwow.setAccount(name, forumName)
  if not name or not forumName then
    return false
  end

  mysql:execute('UPDATE user_informations SET username = "'..forumName..'" WHERE discord_user = "'..name..'"')
  return true
end

function openwow.getLink(forumName)
  if not forumName then
    return false
  end

  local getLink = mysql:execute('SELECT discord_user FROM user_informations WHERE username = "'..forumName..'"')
  local row = getLink:fetch({}, "a")
  if (row) then
    return true
  else
    return false
  end
  getLink:close()
end

function openwow.getUsername(forumName)
  if not forumName then
    return false
  end

  local getUser = mysql:execute('SELECT * FROM users WHERE username = "'..forumName..'"')
  local row = getUser:fetch({}, "a")
  if (row) then
    return true
  else
    return false
  end
  getUser:close()
end

function openwow.linkToAccount(author)
  local name = author.name
  if not openwow.members[name] then
    openwow.createMember(name)
  end

  if openwow.members[name].config.informations == 'Assistant' or name == 'Assistant' then
    return false
  end

  if (openwow.members[name].config.command == '!link') then
    local msg = ''
    local color = ''
    if (openwow.members[name].config.step == 0) then
      msg = 'Merci de m\'envoyer votre nom d\'utilisateur utilisé sur le forum.'
      color = discordia.Color.fromRGB(255, 0, 0).value
    elseif (openwow.members[name].config.step == 1) then
      if openwow.getUsername(openwow.members[name].config.informations) then
        if not openwow.getLink(openwow.members[name].config.informations) then
          if openwow.setAccount(name, openwow.members[name].config.informations) then
            msg = 'Votre compte Discord est désormais lié à votre compte forum'
            color = discordia.Color.fromRGB(0, 255, 0).value

            openwow.members[name].config.command = ''
            openwow.members[name].config.step = 0
          else
            msg = 'Une erreur est survenue, merci de contacter un administrateur'
            color = discordia.Color.fromRGB(255, 0, 0).value
          end
        else
          msg = 'Un utilisateur a déjà lié ce compte forum, si ce n\'est pas vous et que ce compte vous appartiens bien, merci de contacter un administrateur'
          color = discordia.Color.fromRGB(255, 0, 0).value
        end
      else
        msg = 'Ce compte forum n\'existe pas, merci de renseigner un compte existant'
        color = discordia.Color.fromRGB(255, 0, 0).value
      end
    end
    author:send {
      embed = {
        title = 'Lien Discord <-> Forum',
        description = msg,
        thumbnail = {url = 'https://forum.open-wow.eu/assets/logo-fje1vtuv.png'},
        color = color
      }
    }
  end
end

function openwow.setRoles(guild, author)
  local member = guild:getMember(author.id)
  local name = author.name

  if (not(member:hasRole(openwow.roles[openwow.members[name].config.command]))) then
    member:addRole(openwow.roles[openwow.members[name].config.command])
    return true
  else
    member:removeRole(openwow.roles[openwow.members[name].config.command])
    return false
  end
end

client:on('messageCreate', function(message)
  local author = message.author
  local name = author.name
  local avatar = author.avatarURL
  local channel = message.channel
  local channelId = channel.id
  local guild = message.guild

  if not openwow.members[name] then
    openwow.createMember(name)
  end

  if (message.channel.type == 0) then
    if (channelId == '834035763137478678') then
      if (message.content == '!link') then
        openwow.members[name].config.command = message.content
        local member = guild:getMember(author.id)

        openwow.linkToAccount(author)

        channel:send {
          embed = {
            title = "Commande link",
            fields = {
              {name = 'Votre commande a été reçue, les actions suivantes ont été effectuées :', value = 'Envoie d\'un message privé.', inline = true}
            },
            author = {
              name = name,
              icon_url = avatar
            },
            thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
            color = discordia.Color.fromRGB(0, 255, 0).value,
            footer = {
              text = "Commande effectuée le : "..discordia.Date():toISO(' ', ' '),
            }
          }
        }

        message:delete()

      elseif (message.content == '!cpp' or message.content == '!lua' or message.content == '!sql' or message.content == '!mc') then
        openwow.members[name].config.command = string.lower(message.content:gsub('%!', ''))

        if openwow.setRoles(guild, author) then
          channel:send {
            embed = {
              title = "Commande rôle",
              fields = {
                {name = 'Votre commande a été reçue, les actions suivantes ont été effectuées :', value = 'Ajout du rôle '..openwow.members[name].config.command..'.', inline = true}
              },
              author = {
                name = name,
                icon_url = avatar
              },
              thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
              color = discordia.Color.fromRGB(0, 255, 0).value,
              footer = {
                text = "Commande effectuée le : "..discordia.Date():toISO(' ', ' '),
              }
            }
          }
        else
          channel:send {
            embed = {
              title = "Commande rôle",
              fields = {
                {name = 'Votre commande a été reçue, les actions suivantes ont été effectuées :', value = 'Suppression du rôle '..openwow.members[name].config.command..'.', inline = true}
              },
              author = {
      					name = name,
      					icon_url = avatar
      				},
              thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
              color = discordia.Color.fromRGB(0, 255, 0).value,
              footer = {
                text = "Commande effectuée le : "..discordia.Date():toISO(' ', ' '),
              }
            }
          }
        end
        message:delete()
      else
        if author.id ~= "833101104534388746" then
          openwow.members[name].config.step = 0
          openwow.members[name].config.command = ''
          message:delete()
        else
          return false
        end
      end
    end
  elseif (message.channel.type == 1) then
    if (openwow.members[name].config.command == '!link') then
      openwow.members[name].config.informations = message.content
      openwow.members[name].config.step = 1

      openwow.linkToAccount(author)
    end
  end
end)



client:run('Bot xxx')
