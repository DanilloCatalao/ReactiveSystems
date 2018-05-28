
sw1 = 1
sw2 = 2
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

bssidTable = {}
rssiTable = {}
channelTable = {}
wifiTable = {}

wificonf = {
  ssid = "Pity 2.4",
  pwd = "22783390",
  got_ip_cb = function (iptable) print ("ip: ".. iptable.IP) end,
  save = false 
}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf) 

net.dns.setdnsserver("8.8.8.8", 1)
net.dns.resolve("www.google.com", function(sk, ip)
if (ip == nil) then print("DNS fail!") else print(ip) end
end)

function getLocation ()
    return function()
       
        postContentString = [[{"considerIp": "false","wifiAccessPoints":[]]

         for key,value in pairs(wifiTable) do
            postContentString = postContentString .. [[{"macAddress":]] .. [["]] .. value[1] .. [["]] .. [[,]]
            postContentString = postContentString .. [["signalStrength":]] .. [["]] ..value[2] .. [["]] .. [[,]]
            postContentString = postContentString .. [["channel":]] .. [["]] .. value[3] .. [["]] .. [[}]]
            if key < table.getn(wifiTable) then
                postContentString = postContentString .. [[,]]
            end
         end
        postContentString = postContentString .. [[]}]]
        print(postContentString)
        http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCF4y7ycMi6p_O5ICkgkxA6SmLMU0nc-rA',
          'Content-Type: application/json\r\n',
          postContentString,
          function(code, data)
            if (code < 0) then
              print("HTTP request failed :", code)
            else
              print(code, data)
            end
          end)
    end              
end
gpio.trig(sw1, "down", getLocation() )

function getAp ()
    return function ()
        function listap(t)
            print("\n"..string.format("%32s","SSID").."\tBSSID\t\t\t\t  RSSI\t\tAUTHMODE\tCHANNEL")
            for ssid,v in pairs(t) do
                local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
                table.insert( wifiTable, {bssid,rssi,channel} )
                print(string.format("%32s",ssid).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
            end
        end
        wifi.sta.getap(listap)        
    end
end
gpio.trig(sw2, "down", getAp() )










