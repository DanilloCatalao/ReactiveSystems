sw1 = 1
sw2 = 2
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

wificonf = {
  ssid = "cpti",
  pwd = "3domingos",
  got_ip_cb = function (iptable) print ("ip: ".. iptable.IP) end,
  save = false
}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)

net.dns.setdnsserver("8.8.8.8", 1)
net.dns.resolve("www.google.com", function(sk, ip)
if (ip == nil) then print("DNS fail!") else print(ip) end
end)

local meuid = "1320966"
local m = mqtt.Client("clientid " .. meuid, 120)

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  client:subscribe("throw", 0, novaInscricao)
  --publica(client)

end
function throw()
    return function()
        m:publish("throw","2")
    end
end

function turn()
    return function()
        m:publish("turn","2")
    end
end


gpio.trig(sw1, "down", throw() )
gpio.trig(sw2, "down", turn() )


m:connect("test.mosquitto.org", 1883, 0,
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
