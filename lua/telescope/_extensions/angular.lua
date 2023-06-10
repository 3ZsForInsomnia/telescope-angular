local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local getModulesInFolder = function(path, relative)
  local modules = {}
  local handle = io.popen("ls " .. path)

  for file in handle:lines() do
    if string.match(file, ".+%.module%.ts") then
      table.insert(modules, relative .. "/" .. file)
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
    local lastSlash = string.find(absolutePath, "/[^/]*$") - 1
    absolutePath = string.sub(absolutePath, 1, lastSlash)
    local moduleFound = getModulesInFolder(absolutePath, path)
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
        return {
          value = entry,
          display = entry,
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
