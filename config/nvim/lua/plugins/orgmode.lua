return {
  "nvim-orgmode/orgmode",
  dependencies = {
    "nvim-orgmode/org-bullets.nvim",
    -- 'lukas-reineke/headlines.nvim',
    "saghen/blink.cmp",
  },
  event = "VeryLazy",
  config = function()
    require("orgmode").setup({
      org_agenda_files = "~/org/gtd/**/*",
      org_default_notes_file = "~/org/refile.org",
      org_capture_templates = {
        r = {
          description = "Repo",
          template = "* [[%x][%(return string.match('%x', '([^/]+)$'))]]%?",
          target = "~/org/repos.org",
        },
      },
    })
    require("org-bullets").setup()
    -- require("headlines").setup({
    --     org = {
    --         headline_highlights = { "Headline1", "Headline2" },
    --     },
    -- })

    require("blink.cmp").setup({
      sources = {
        per_filetype = {
          org = { "orgmode" },
        },
        providers = {
          orgmode = {
            name = "Orgmode",
            module = "orgmode.org.autocompletion.blink",
            fallbacks = { "buffer" },
          },
        },
      },
    })

    -- require('telescope').setup()
    -- require('telescope').load_extension('orgmode')
    -- vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
    -- vim.keymap.set('n', '<leader>fh', require('telescope').extensions.orgmode.search_headings)
    -- vim.keymap.set('n', '<leader>li', require('telescope').extensions.orgmode.insert_link)
  end,
}
