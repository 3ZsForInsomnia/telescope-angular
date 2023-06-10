local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local getModulesInFolder = function(path)
  local modules = {}
  local handle = io.popen("ls " .. path)

  for file in handle:lines() do
    if string.match(file, ".+%.module%.ts") then
      table.insert(modules, path .. "/" .. file)
    end
  end

  handle:close()
  return modules
end

local getAngularModules = function()
  local path = vim.fn.expand("%")
  local absolutePath = vim.fn.expand("%:p")
  local _, depth = string.gsub(path, "/", "")

  local modules = {}

  local curr = depth;
  while curr > 0 do
    absolutePath = string.sub(absolutePath, 1, string.find(absolutePath, "/[^/]*$") - 1)

    local moduleFound = getModulesInFolder(absolutePath)
    if table.getn(moduleFound) ~= nil then
      for _, module in ipairs(moduleFound) do
        table.insert(modules, module)
      end
    end

    curr = curr - 1
  end

  return modules
end

local angularPicker = function(opts)
  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Angular Modules",
    finder = finders.new_table({
      results = getAngularModules(),
      entry_maker = function(entry)
        local cwd = vim.fn.getcwd()
        local relativePath = string.sub(entry, string.len(cwd) + 2)
        return {
          value = entry,
          display = relativePath,
          ordinal = entry
        }
      end
    }),
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts),
  }):find()
end

local function run()
  angularPicker()
end

return require("telescope").register_extension({
  exports = {
    angular = run,
  },
})
