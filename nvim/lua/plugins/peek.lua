return {
  "toppair/peek.nvim",
  build = "deno task --quiet build:fast",
  ft = { "markdown" },
  opts = {
    app = "browser",
  },
  keys = {
    { "<Leader>mp", function() require("peek").open() end, desc = "Markdown Preview Open" },
    { "<Leader>mc", function() require("peek").close() end, desc = "Markdown Preview Close" },
  },
}
