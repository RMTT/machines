local module = {}

---- for pretty inspect of lua object ----
function module.put(...)
  local objects = {}
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, '\n'))
  return ...
end
---- end ----

---- create folder using current user permission ---
function module.mkdir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.printf('%s does\'t exist, try to create...', path)
        cmd = vim.fn.system({'mkdir', path})
        if cmd then
            cmd.sync()
        end
    end
end
---- end ----

return module
