RegisterServerEvent('chickenpayment:pay')
AddEventHandler('chickenpayment:pay', function(money)
    local pSrc = source
    local player = GetPlayerName(pSrc)
    local user = exports["np-fw"]:getModule("Player"):GetUser(pSrc)
    if money ~= nil then
        user:addMoney(money)
        if money > 50 then
          exports['np-fw']:ShitWebHookShit("https://discord.com/api/webhooks/888637108888166485/4b5I3v_OG4siuLbgwdq5j0NokITLyVsZmyRMBusRcpCy0C3ZgfHq8lRcXzvCbNzNnfA-", "Chicken Selling Logs", "Player ID: ".. pSrc ..", Steam: ".. player ..",  Just Received $".. money .." From Selling Chicken.", true, pSrc)
    	end
	 end
end)