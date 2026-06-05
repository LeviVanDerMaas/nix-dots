vim.o.shiftwidth = 2;

local flakeroot = vim.fs.root(0, "flake.nix")
local hostname = vim.uv.os_gethostname()
local function in_homes_dir(yn)
  local in_homes = vim.startswith(vim.api.nvim_buf_get_name(0), flakeroot .. "/homes")
  if yn then return in_homes else return not in_homes end
end


-- Disable standard nixd lsp config (if it was active) so we can set up our own
vim.lsp.enable("nixd", false)

-- nixd config for files not under ./homes, these use NixOS options
vim.lsp.config("nixd_nixos", vim.lsp.config["nixd"])
vim.lsp.config("nixd_nixos", {
  root_dir = function(bufnr, on_dir)
    if in_homes_dir(false) then
      on_dir(flakeroot)
    end
  end,
  settings = {
    nixd = {
      options = {
        nixos = {
          expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations." .. hostname .. ".options"
        },
      }
    }
  }
})
vim.lsp.enable("nixd_nixos", true)

-- nixd config for files under ./homes, these use HM options
vim.lsp.config("nixd_home_manager", vim.lsp.config["nixd"])
vim.lsp.config("nixd_home_manager", {
  root_dir = function(bufnr, on_dir)
    if in_homes_dir(true) then
      on_dir(flakeroot)
    end
  end,
  settings = {
    nixd = {
      options = {
        nixos = {
          expr = "{}" -- Must overwrite this otherwise it will try to read this from <nixpkgs>
        },
        home_manager = {
          -- TODO: make this for arbitrary users if I add more than a home config for myself
          expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.levi.options"
        },
      }
    }
  }
})
vim.lsp.enable("nixd_home_manager", true)
