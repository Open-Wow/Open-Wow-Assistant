local discordia = require('discordia')
local client = discordia.Client()

local rolesManager = require('roles')
local topicsManager = require('topics')
local config = require('config')

local CommandList = {
  ['!cpp'] = 1,
  ['!lua'] = 2,
  ['!sql'] = 3,
  ['?help'] = true,
  ['?search'] = true
}

client:on('heartbeat', function()
  local topicsResult = topicsManager.getLatestTopics()
  local commentResult = topicsManager.getLatestComment()

  local channel = client:getChannel('795322876831203338')

  if topicsResult then
    channel:send {
      embed = {
        title = "Nouveau Contenu !",
        fields = topicsResult,
        author = {
          name = 'Open-Wow',
          icon_url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'
        },
        thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
        color = discordia.Color.fromRGB(0, 255, 0).value,
        footer = {
          text = "Commande automatique",
        }
      }
    }
  end
  if commentResult then
    channel:send {
      embed = {
        title = "Nouveau Commentaire !",
        fields = commentResult,
        author = {
          name = 'Open-Wow',
          icon_url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'
        },
        thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
        color = discordia.Color.fromRGB(255, 165, 0).value,
        footer = {
          text = "Commande automatique",
        }
      }
    }
  end
end)

client:on('memberJoin', function(member)
  rolesManager.getRoles(member, 0)
end)

client:on('messageCreate', function(message)
  local channel = message.channel
  local channelId = message.channel.id

  if channelId == '794712840241676318' then
    local authorId = message.author.id
    if authorId ~= '794651068247179294' then
      message:delete()
    end

    local msg = message.content
    if CommandList[msg] and type(CommandList[msg]) == 'number' then
      local member = message.member

      if rolesManager.getRoles( member, CommandList[msg] ) then
        channel:send {
          embed = {
            title = "Commande rôle",
            fields = {
              {name = 'Votre commande a été reçue, les actions suivantes ont été effectuées :', value = 'Ajout du rôle '..msg:gsub("%!", "")..'.', inline = true}
            },
            author = {
    					name = member.user.name,
    					icon_url = member.user.avatarURL
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
              {name = 'Votre commande a été reçue, les actions suivantes ont été effectuées :', value = 'Suppression du rôle '..msg:gsub("%!", "")..'.', inline = true}
            },
            author = {
    					name = member.user.name,
    					icon_url = member.user.avatarURL
    				},
            thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
            color = discordia.Color.fromRGB(0, 255, 0).value,
            footer = {
              text = "Commande effectuée le : "..discordia.Date():toISO(' ', ' '),
            }
          }
        }
      end

    elseif CommandList[string.match(msg, '?search' .. "?")] then
      if string.match(msg, '?search' .. "?") then
        local result = topicsManager.getList(msg:gsub('?search' .. " ", ""))
        local member = message.member

        if result then
          channel:send {
            embed = {
              title = "Commande de recherche",
              fields = result,
              author = {
      					name = member.user.name,
      					icon_url = member.user.avatarURL
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
              title = "Commande de recherche",
              fields = {
                {name = 'Votre commande a été reçue, votre recherche ne peu malheureusement pas aboutir :', value = 'Merci d\'entrer une valeur de recherche valide, ou faire une demande de tutoriel pour le sujet recherchés.', inline = true}
              },
              author = {
      					name = member.user.name,
      					icon_url = member.user.avatarURL
      				},
              thumbnail = {url = 'https://cdn.discordapp.com/icons/793570897562173490/f4c76abd317caad9fc9082d6a6c75d00.webp'},
              color = discordia.Color.fromRGB(255, 0, 0).value,
              footer = {
                text = "Commande effectuée le : "..discordia.Date():toISO(' ', ' '),
              }
            }
          }
        end
      end
    end
  end
end)

client:run('Bot '..config.discord.token)
