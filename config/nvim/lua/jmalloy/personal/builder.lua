local M = {}

-- Store the terminal buffer ID
M.runner_buf = nil
M.build_command = nil -- Will be loaded per project

-- Function to find or create the runner terminal
local function get_runner_terminal()
  if M.runner_buf and vim.api.nvim_buf_is_valid(M.runner_buf) then
    return M.runner_buf
  end

  -- Create a new terminal buffer
  vim.cmd("vsplit") -- Open in vertical split
  vim.cmd("terminal")
  M.runner_buf = vim.api.nvim_get_current_buf()

  return M.runner_buf
end

-- Load project-specific build command
local function load_build_command()
  local build_file = vim.fn.getcwd() .. "/.nvim_build.lua"
  if vim.fn.filereadable(build_file) == 1 then
    M.build_command = dofile(build_file)
  else
    M.build_command = nil
  end
end

-- Run the build command in the runner terminal
function M.run_build()
  if not M.build_command then
    load_build_command()
  end

  if not M.build_command then
    print("No build command set for this project!")
    return
  end

  local term_buf = get_runner_terminal()
  vim.fn.chansend(vim.api.nvim_buf_get_var(term_buf, "terminal_job_id"), M.build_command .. "\n")
end

-- Command to manually set a build command
function M.set_build_command(cmd)
  M.build_command = cmd
  print("Build command set: " .. cmd)
end

-- Setup function to define commands
function M.setup()
  vim.api.nvim_create_user_command("RunBuild", M.run_build, {})
  vim.api.nvim_create_user_command("SetBuildCommand", function(opts)
    M.set_build_command(opts.args)
  end, { nargs = 1 })
end

return M
