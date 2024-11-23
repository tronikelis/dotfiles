-- unpack is deprecated in favor of table.unpack,
-- but nvim still uses older lua that does not support it, so fallback
table.unpack = table.unpack or unpack

require("remaps")
require("plugins")
require("user_commands")
