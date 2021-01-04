local roles = {}

roles.index = {
  [0] = '793576228531339315', -- member
  [1] = '793576468684210177', -- cpp
  [2] = '793576490150527047', -- lua
  [3] = '793576537685098506', -- sql
}

function roles.getRoles( member, type )
  if type > 0 then
    if ( member:hasRole( roles.index[type] ) ) then
      roles.removeRoles( member, type )
      return false
    else
      roles.addRoles( member, type )
      return true
    end
  else
    roles.addRoles( member, type )
    return true
  end
end

function roles.removeRoles( member, type )
  member:removeRole( roles.index[type] )
  return false
end

function roles.addRoles( member, type )
  member:addRole( roles.index[type] )
  return true
end

return roles
