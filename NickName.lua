local requests = require('requests')
local json = require('json')

function main()
    repeat wait(0) until isSampAvailable()

    local url = 'https://raw.githubusercontent.com/legacy-Chay/NickName/refs/heads/main/NickName.json'
    local response = requests.get(url)

    if response.status_code ~= 200 then
        return sampAddChatMessage("Доступ запрещён", -1)
    end

    local ok, data = pcall(json.decode, response.text)
    if not ok or type(data) ~= "table" then
        return sampAddChatMessage("Доступ запрещён", -1)
    end

    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(id)
    local serverName = sampGetCurrentServerName() or ""

    local userData = data[nick]
    if not userData or type(userData) ~= "table" or #userData < 2 then
        return sampAddChatMessage("Доступ запрещён", -1)
    end

    local allowedServer = userData[1]
    local expiryDate = userData[2]

    if serverName ~= allowedServer or not isAccessValid(expiryDate) then
        return sampAddChatMessage("Доступ запрещён", -1)
    end

    sampAddChatMessage("Доступ разрешён", -1)
end

function isAccessValid(dateStr)
    local day, month, year = dateStr:match("(%d%d)%.(%d%d)%.(%d%d%d%d)")
    if not day or not month or not year then return false end

    local expiryTime = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 23, min = 59 })
    return os.time() <= expiryTime
end
