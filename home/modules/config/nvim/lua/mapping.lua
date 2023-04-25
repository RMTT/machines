---- using alt+hjkl to move between split/vsplit panels ----
vim.api.nvim_set_keymap('t', '<A-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
---- end ----

---- using <space>y[y] and <space>p to copy and paster from clipboard ----
vim.api.nvim_set_keymap('v', '<space>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>Y', '"+yy', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<space>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>P', '"+P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<space>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<space>P', '"+P', { noremap = true, silent = true })
---- end ----

---- close buffer and window ----
vim.api.nvim_set_keymap('n', '<A-w>', ':bd<CR>', { noremap = true, silent = true })
