Server = {}

function http_request(url, method, callback)
    request = CreateHTTPRequestScriptVM(method, url)
    request:SetHTTPRequestAbsoluteTimeoutMS(5000)
    request:Send(function(result)
        if result.StatusCode == 200 then
            local data = json.decode(result["Body"])
            if data and callback then
                callback(data)
            end
        else
        end
    end)
end

function http_request_client(_, event)
    http_request(event.url, event.method, function (data)
        DeepPrintTable(data)
    end)
end








function Server:UpdateProfiles()
    for i = 0, PlayerResource:GetPlayerCount() - 1 do
        http_request("http://spooftd.temp.swtest.ru/getprofile.php?&mode=edit&wins=0&mmr=0&steamid=".. tostring(PlayerResource:GetSteamID(i)) , "get", function (data)
            _G.lua.PlayerServerData[i] = data
        end)
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), "ProfileUpdate", _G.lua.PlayerServerData[i])
    end
end