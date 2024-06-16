--[[
@author: Mysteyam
@name: ID system - Automatic generation of a sequence of numbers
--]]
local dbConnection = dbConnect("mysql", "dbname=name;host=host", "your_username", "your_password" )

function doesIDExist(idNumber)
    local query = dbQuery(dbConnection, "SELECT idNumber FROM nazwa_tabeli WHERE idNumber = ?", idNumber)
    local result = dbPoll(query, -1)
    return result and #result > 0
end

function saveIDToDatabase(uid, login, idNumber, date)
    local query = dbExec(dbConnection, "INSERT INTO nazwa_tabeli (uid, login, idNumber, date) VALUES (?, ?, ?, ?)", uid, login, idNumber, date)
    return query
end

    
function wygenerujID(length, uid, login)
    local chars = "0123456789"
    local maxAttempts = 10
    local result = ""
    
    for attempt = 1, maxAttempts do
        result = ""
        for i = 1, length do
            local randomIndex = math.random(1, #chars)
            result = result .. chars:sub(randomIndex, randomIndex)
        end
        
        if not doesIDExist(result) then
            local date = os.date("%Y-%m-%d %H:%M:%S")
            local saved = saveIDToDatabase(uid, login, result, date)
            if saved then
                outputDebugString("ID zapisany w bazie danych!", 3)
            else
                outputDebugString("Błąd zapisu ID do bazy danych!", 3)
            end
            return result
        end
    end
    
    -- Jeśli przekroczono maksymalną liczbę prób
    outputDebugString("Nie udało się wygenerować unikalnego ID po " .. maxAttempts .. " próbach. ID: "..result, 3)
    return false
end

    
addCommandHandler("id", function(player, command, length)
    local uid = getElementData(player, "gracz:uid")
    local login = getPlayerName(player)

    length = tonumber(length)
        
    if length and length > 0 and length < 30 then
        local randomNumberString = wygenerujID(length, uid, login)
        if randomNumberString then
            outputDebugString("Wygenerowany ID: " .. randomNumberString, 3)
        end
    else
        outputDebugString("Wpisz poprawną ilość znaków.", 3)
    end
end)




addCommandHandler("wygenerujKod", function(player, command)
    local uid = getElementData(player, "gracz:uid")
    local login = getPlayerName(player)

    local length = 6  -- Ustawienie długości na 6 cyfr
    local randomNumberString = wygenerujID(length, uid, login)
    if randomNumberString then
        local formattedID = randomNumberString:sub(1, 3) .. " " .. randomNumberString:sub(4, 6)
        outputDebugString("Wygenerowany ID: " .. randomNumberString, 3)
        outputServerLog("ID: " .. formattedID)
    else
        outputDebugString("Wpisz poprawną ilość znaków.", 3)
    end
end)
