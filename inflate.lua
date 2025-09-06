-- inflate.lua
local io = require("io")
local os = require("os")

local POINTER_FILE = "pointer.file"
local baseURL = nil
local pointers = {}

-- read pointer.file
local f = assert(io.open(POINTER_FILE, "r"), "Could not open "..POINTER_FILE)
for line in f:lines() do
    line = line:match("^%s*(.-)%s*$") -- trim
    if line ~= "" and not line:match("^##") then
        -- check for baseURL
        local url = line:match('{getURL="([^"]+)"}')
        if url then
            baseURL = url
        end
        -- check for pointer definitions
        local key, val = line:match('(%w+)%s*=%s*"([^"]+)"%s*;')
        if key and val then
            pointers[key] = val
        end
    end
end
f:close()

if not baseURL then
    error("No baseURL found in "..POINTER_FILE)
end

-- download files
for name, filename in pairs(pointers) do
    local fullURL = baseURL.."/"..filename
    print("Downloading "..name.." -> "..fullURL)
    local cmd = string.format('wget -q -O "%s" "%s"', filename, fullURL)
    local ok = os.execute(cmd)
    if ok then
        print("✔ "..filename.." saved")
    else
        print("✘ Failed to download: "..filename)
    end
end
