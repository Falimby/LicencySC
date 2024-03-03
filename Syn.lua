

delayWarp = delaywarp * 1000
bot = getBot()
inventory = bot:getInventory()
bot.legit_mode = true
bot.collect_range = 4
bot.collect_interval = 100
bot.object_collect_delay = 110
farm = bot.auto_farm


function reconnect(word,id,ex,ey)
  local worldz = bot:getWorld()
  while bot.status ~= BotStatus.online do 
    bot.auto_reconnect = false 
    sleep(100)
    bot:connect()
    sleep(delayRecon * 1000)
    InfoNotif(bot.name:upper().." Status Reconnecting")
    if bot.status == BotStatus.account_banned then 
      InfoNotif("[ "..bot.name:upper().." ] Status Banned")
      bot:stopScript()
      sleep(100)
    end
  end
  if bot.status == BotStatus.online and worldz.name:upper() ~= word:upper() then 
    bot:warp(word)
    sleep(delaywarp)
  end
  if ex and ey then 
      bot:findPath(ex,ey)
      sleep(100)
  end 
end

function getIndex()
    for index,bot in pairs(getBots()) do
        if bot.name:upper() == bot.name:upper() then
            return index
        end
    end
    return 0 
end

for i, botz in pairs(getBots()) do 
  if getBot().name:upper() == botz.name:upper() then
    indexBot = i
  end
  indexLast = i 
end

function getStatus(inibot)
    local status = {
        [BotStatus['offline']] = 'offline',
        [BotStatus["online"]] = "online",
        [BotStatus["account_banned"]] = "banned",
        [BotStatus["location_banned"]] = "temporary banned",
        [BotStatus["server_overload"]] = "overload",
        [BotStatus["too_many_login"]] = "many login",
        [BotStatus["maintenance"]] = "maintenance",
        [BotStatus["version_update"]] = "version update",
        [BotStatus["server_busy"]] = "login fail",
        [BotStatus["error_connecting"]] = "ercon",
        [BotStatus["logon_fail"]] = "login fail",
        [BotStatus["high_load"]] = "high load",
        [BotStatus["changing_subserver"]] = "change subserver"
    }
    return status[inibot.status]
end
function cekStatus(client)
    if getStatus(client) == 'online' then
        return ':green_circle:'
    end
    return ':red_circle:'
end
function getDatas()
    local data = {online = 0,offline = 0,gems = 0,bot = #getBots()}
    for _,client in pairs(getBots()) do
        if getStatus(client) == 'online' then data.online = data.online + 1 else data.offline = data.offline + 1 end
        data.gems = data.gems + client.gem_count
    end
    return data
end
function changeString(nama_,end_)
    local _end = math.floor(end_ * 2)
    if hide_sensitive then
        local first = string.sub(nama_, 1, end_)
        local last = string.rep("x", string.len(nama_) - _end)
        return first .. 'xxx'
    else
        return nama_
    end
end
function InfoNotif(description)
    local script = [[
        $webHookUrl = "]]..status_bot.url..[["
        $content = "]]..description..[["
        $payload = @{
            content = $content 
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    ]]
    if status_bot.enable then
        sleep(500 * (getIndex() - 1))
        local pipe = io.popen("powershell -command -", "w")
        pipe:write(script)
        pipe:close()
    end
end

function warplock()
    if bot.status == BotStatus.online then
        function On_Dialog(variant, netid)
            if variant:get(0):getString() == "OnDialogRequest" then
                if variant:get(1):getString():find("myWorldsUiTab_0") then
                    bot:warp(variant:get(1):getString():match("add_button|(%w+)|"))
                    sleep(delayWarp)
                end
            end
        end
        addEvent(Event.variantlist, On_Dialog)
        bot:wrenchPlayer(getLocal().netid)
        bot:sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..getLocal().netid.."|\nbuttonClicked|my_worlds")
        listenEvents(5)
    end
end
function scanfloat(id)
    local count = 0
    for _, obj in pairs(bot:getWorld():getObjects()) do
        if obj.id == id then
            count = count + obj.count 
        end
    end
    return count 
end
function takefloat(id)
    local worlds = nil 
    if bot:isInWorld() then
        worlds = bot:getWorld()
        for _,obj in pairs(worlds:getObjects()) do
            if obj.id == id then
                if getInfo(worlds:getTile(math.floor(obj.x / 32),math.floor(obj.y / 32)).fg).collision_type == 0 then
                    bot:findPath(math.floor(obj.x / 32),math.floor(obj.y / 32))
                    sleep(1000)
                    bot:collect(id,100)
                    if inventory:getItemCount(id) > 0 then
                        break 
                    end
                end
            end
        end
    end
end
function drop(itm,count)
    bot:drop(itm,(count or inventory:getItemCount(itm)))
    sleep(1000)
end
function pickaxe()
  if pickaxeTake and inventory:getItemCount(98) == 0 then
    sleep(delayPick * (getIndex() - 1))
    Infobot('Taking Pickaxe...')
    bot:warp(pickaxeWorld,pickaxeDoor)
    sleep(delayWarp)
    if scanfloat(98) > 0 then 
      local worldz = bot:getWorld()
      local locals = worldz:getLocal()
      takefloat(98)
      sleep(200)
      bot.auto_collect = false
      sleep(200)
      local last_ex = math.floor(locals.posx / 32)
      local last_ey = math.floor(locals.posy / 32)
      while inventory:getItemCount(98) > 1 do 
        reconnect(pickaxeWorld,pickaxeDoor,last_ex,last_ey)
        bot:drop(98,inventory:getItemCount(98) - 1)
        sleep(1000)
      end
    end
  elseif inventory:getItemCount(98) > 1 then
    bot:warp(pickaxeWorld,pickaxeDoor)
    Infobot('Drop Pickaxe, To much...')
    bot.auto_collect = false
    sleep(200)
    local last_ex = math.floor(locals.posx / 32)
    local last_ey = math.floor(locals.posy / 32)
    while inventory:getItemCount(98) > 1 do 
      reconnect(pickaxeWorld,pickaxeDoor,last_ex,last_ey)
      bot:drop(98,(inventory:getItemCount(98) - 1))
      sleep(1000)
      if inventory:getItemCount(98) > 1 then 
        bot:moveTo(1,0)
        sleep(1000)
      end
    end
  end
end
function getIndex()
    for index,bot in pairs(getBots()) do
        if bot.name:upper() == bot.name:upper() then
            return index
        end
    end
    return 0 
end
function findTree(tree,amount)
    local word = bot:getWorld()
    local locals = word:getLocal()
    local attempt = 0
    for tilex = 0,99,1 do 
      for tiley = 16,40,1 do 
        if bot:getWorld():getTile(tilex,tiley).fg == tree then 
          bot:findPath(tilex,tiley)
          sleep(1000)
          last_ex = math.floor(locals.posx / 32)
          last_ey = math.floor(locals.posy / 32)
          while bot:getWorld():getTile(tilex,tiley).fg ~= 0 do
            reconnect(word.name,last_ex,last_ey)
            bot:hit(bot.x,bot.y)
            sleep(delayHarvest)
          end
          attempt = attempt + 1
          reconnect(word.name,last_ex,last_ey)
        end 
        if attempt >= amount then
            break
        end
      end
    end
end

function breakBlock(id,amount)
  bot.auto_collect = true
  local worldz = bot:getWorld()
  local locals = worldz:getLocal()
  local last_ex = math.floor(locals.posx / 32),math.floor(locals.posy / 32)
  local last_ey = math.floor(locals.posx / 32),math.floor(locals.posy / 32)
  while bot:getInventory():getItemCount(id) > 0 and bot:getInventory():getItemCount(id+1) <= amount do
    if worldz:getTile(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32)).fg == 0 or worldz:getTile(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32)).bg == 0 then 
      bot:place(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32),id)
      sleep(delayPlace)
      reconnect(worldz.name,last_ex,last_ey)
    end
    while worldz:getTile(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32)).fg ~= 0 or worldz:getTile(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32)).bg ~= 0 do 
      bot:hit(math.floor(locals.posx / 32) - 1,math.floor(locals.posy / 32))
      sleep(delayBreak)
      reconnect(worldz.name,last_ex,last_ey)
    end
  end
  drop(id+1)
  sleep(1000)
  drop(id+1)
  sleep(1000)
  if scanfloat(id+1) > 0 then 
    takefloat(id+1)
  end 
end

function placeDirt()
  Infobot('Placing Dirt...')
  local word = bot:getWorld()
  local locals = word:getLocal()
    for tilex = 34, 55 do
        bot:findPath(tilex,17)
        sleep(200)
        local last_ex = math.floor(locals.posx / 32)
        local last_ey = math.floor(locals.posy / 32)
        while bot:getWorld():getTile(tilex,18).fg == 0 do
            reconnect(word.name,last_ex,last_ey)
            bot:place(tilex,18,2)
            sleep(delayPlace)
        end
    end
end
function dirt(amount)
  local word = bot:getWorld()
  local locals = word:getLocal()
  Infobot('STEP 1')
  local attempt = 0 
    for tiley = 19, 24, 1 do
        for tilex = 82, 99, 1 do
            if bot:getWorld():getTile(tilex,tiley).fg == 2 then
                bot:findPath(tilex,tiley - 1)
                sleep(200)
                local last_ex = math.floor(locals.posx / 32)
                local last_ey = math.floor(locals.posy / 32)
                while bot:getWorld():getTile(tilex,tiley).fg ~= 0 do
                    reconnect(word.name,last_ex,last_ey)
                    bot:hit(tilex,tiley)
                    sleep(delayBreak)
                end
                attempt = attempt + 1
            end
            if attempt >= amount or bot:getWorld():getTile(tilex,tiley).fg ~= 2 then
              Infobot('STEP 1 DONE')
                break
            end
        end
        if attempt >= amount then
            break
        end
    end
end
function findDirt(amount)
  local word = bot:getWorld()
  local locals = word:getLocal()
  Infobot('Finding ' ..amount..' Dirt Seed...')
    for tiley = 19, 53, 1 do
        for tilex = 82, 99, 1 do
            if bot:getWorld():getTile(tilex,tiley).fg ~= 0 then
                bot:findPath(tilex,tiley - 1)
                sleep(200)
                local last_ex = math.floor(locals.posx / 32)
                local last_ey = math.floor(locals.posy / 32)
                while bot:getWorld():getTile(tilex,tiley).fg ~= 0 do 
                    reconnect(word.name,last_ex,last_ey)
                    bot:hit(tilex,tiley)
                    sleep(delayBreak)
                end
            end
            if bot:getInventory():getItemCount(3) >= amount then
                break
            end
        end
        if bot:getInventory():getItemCount(3) >= amount then
            break
        end
    end
end
function plant(tree,amount)
    local word = bot:getWorld()
    local locals = word:getLocal()
    local attempt = 0
    for tilex = 36, 55 do
        if bot:getWorld():getTile(tilex,17).fg == 0 then
            bot:findPath(tilex,17)
            sleep(200)
            local last_ex = math.floor(locals.posx / 32)
            local last_ey = math.floor(locals.posy / 32)
            while bot:getWorld():getTile(tilex,17).fg == 0 do
                reconnect(word.name,last_ex,last_ey)
                bot:place(tilex,17,tree)
                sleep(delayPlant)
            end
            attempt = attempt + 1
        end
        if attempt >= amount then
            break
        end
    end
end
function harvest(tree)
    local word = bot:getWorld()
    local locals = word:getLocal()
    local attempt = 0
    for tilex = 35, 55 do
        if bot:getWorld():getTile(tilex,17).fg ~= 0 then
            bot:findPath(tilex,17)
            sleep(200)
            local last_ex = math.floor(locals.posx / 32)
            local last_ey = math.floor(locals.posy / 32)
            while bot:getWorld():getTile(tilex,17).fg ~= 0 do 
                reconnect(word.name,last_ex,last_ey)
                bot:hit(tilex,17)
                sleep(delayHarvest)
            end
            attempt = attempt + 1
        end
        if attempt >= 10 then
            break
        end
    end
end
function splice(item1,item2,amount)
    local word = bot:getWorld()
    local locals = word:getLocal()
    local attempt = 0
    for tilex = 36, 55 do
        if bot:getWorld():getTile(tilex,17).fg == 0 then
            bot:findPath(tilex,17)
            sleep(200)
            local last_ex = math.floor(locals.posx / 32)
            local last_ey = math.floor(locals.posy / 32)
            while bot:getWorld():getTile(tilex,17).fg == 0 do
                reconnect(word.name,last_ex,last_ey)
                bot:place(tilex,17,item1)
                sleep(delayPlant)
            end
            while bot:getWorld():getTile(tilex,17).fg == item1 do
                reconnect(word.name,last_ex,last_ey)
                bot:place(tilex,17,item2)
                sleep(delayPlant)
            end
            attempt = attempt + 1
        end
        if attempt >= amount then
            break
        end
    end
end
function placeWood()
  local word = bot:getWorld()
  local locals = word:getLocal()
  Infobot('Placing Wood Block...')
    for tilex = 35, 55 do
        bot:findPath(tilex,17)
        sleep(200)
        local last_ex = math.floor(locals.posx / 32)
        local last_ey = math.floor(locals.posy / 32)
        while bot:getWorld():getTile(tilex,16).fg == 0 do
            bot:place(tilex,16,100)
            sleep(delayPlace)
            reconnect(word.name,last_ex,last_ey)
        end
    end
end
function breakWood()
  local word = bot:getWorld()
  local locals = word:getLocal()
  Infobot('Breaking Wood Block')
    for tilex = 35, 55 do
        bot:findPath(tilex,17)
        sleep(200)
        local last_ex = math.floor(locals.posx / 32)
        local last_ey = math.floor(locals.posy / 32)
        while bot:getWorld():getTile(tilex,16).fg ~= 0 do 
            reconnect(word.name,last_ex,last_ey)
            bot:hit(tilex,16)
            sleep(delayBreak)
            reconnect(word.name,last_ex,last_ey)
        end
        if bot:getInventory():getItemCount(101) > 5 then
          if bot:getInventory():getItemCount(101) > 0 then 
            drop(101)
            sleep(1000)
          end
          if bot:getInventory():getItemCount(101) > 0 then 
            drop(101)
            sleep(1000)
          end
          if scanfloat(101) > 0 then 
              takefloat(101)
          end
            break
        end
    end
end
function Droplist()
  if dropTrash and inventory:getItemCount(trash_drop.id) > 0 then 
    bot:warp(dropWorld,dropDoor)
    sleep(7000)
    bot.auto_collect = false
    sleep(1000)
    for index,item in pairs(trash_list) do 
      if inventory:getItemCount(item) > 0 then 
        Infobot('After Drop Finish Tutorial...')
        drop(item)
        sleep(1000)
        while inventory:getItemCount(item) > 0 do 
          bot:moveRight(1)
          sleep(1000)
          drop(item)
        end
      end
    end
  end
end
function drop(itm,count)
    bot:drop(itm,(count or inventory:getItemCount(itm)))
    sleep(1000)
end
function meMethodkan()
  local worldz = bot:getWorld():getLocal()
  sleep(100)
  bot:say("/sethome")
  sleep(1099)
  bot:wrenchPlayer(worldz.netid)
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|popup\nnetID|"..worldz.netid.."|\nbuttonClicked|open_personlize_profile")
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|personalize_profile\nbuttonClicked|100|params_0\n\ncheckbox_show_achievements|1\ncheckbox_show_total_ach_count|1\ncheckbox_show_account_age|1\ncheckbox_show_homeworld|1")
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|personalize_profile_achievement\nbuttonClicked|26|params_0,0")
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|personalize_profile\nbuttonClicked|100|params_1\n\ncheckbox_show_achievements|1\ncheckbox_show_total_ach_count|1\ncheckbox_show_account_age|1\ncheckbox_show_homeworld|1")
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|personalize_profile_achievement\nbuttonClicked|24|params_1,0")
  sleep(1000)
  bot:sendPacket(2,"action|dialog_return\ndialog_name|personalize_profile\nbuttonClicked|save\n\ncheckbox_show_achievements|1\ncheckbox_show_total_ach_count|1\ncheckbox_show_account_age|1\ncheckbox_show_homeworld|1")
  sleep(100)
end


function Infobot(status)
    if status_activity.enable then 
        local total_ = #getBots() 
        local syn = Webhook.new(status_activity.url)
        syn.avatar_url = 'https://cdn.discordapp.com/attachments/1180523579381665933/1180577805403181076/20231203_013427.png'
		syn.embed1.use = true
		syn.embed1.title = "***SYN || SKIP ALL TUTOR V.1.2***"
        syn.embed1.thumbnail = 'https://cdn.discordapp.com/attachments/1180523579381665933/1180577805403181076/20231203_013427.png'
        syn.embed1.description = '** '.. bot.name:upper() .. ': ' .. status .. '\n' .. 
            '**Gems : **' .. getDatas().gems ..'\n' ..
            '**Online : **' .. getDatas().online ..'\n' ..
            '**Offline : **' .. getDatas().offline ..'\n' ..
            '**Update  :** <t:' .. os.time() .. ':R>'
		syn.embed1.color = math.random(000000,9999999)
        if total_ > 24 then
            total_ = 24
        end
        for i = 1,total_ do
            local status_ = ':question:'
            local scriptRun = ':question:'
            local tile_x = 0
            local tile_y = 0

            if getBots()[i].name:upper() ~= bot.name:upper() then if getBots()[i]:isRunningScript() then scriptRun = '<:executed:1180094361137074217>' else scriptRun = '<:terminated:1180094318019608677>' end else scriptRun = '<:executed:1180094361137074217>' end
            if getBots()[i]:isInWorld() then tile_x = math.floor(getBots()[i]:getWorld():getLocal().posx / 32) tile_y = math.floor(getBots()[i]:getWorld():getLocal().posy / 32) end
            if getStatus(getBots()[i]) == 'online' then status_ = '<a:online2:1174926338164002818>' else status_ = '<a:OFFLINE:1142826338307280997>' end

            local status_all = 'Status : ' .. getStatus(getBots()[i]) .. '[ ' .. getBots()[i]:getPing() .. ']\n' ..
                'Script : ' .. scriptRun .. '\n' ..
                'Level : ' .. getBots()[i].level .. '\n' .. 
                'Gems : ' .. getBots()[i].gem_count .. '\n' .. 
                '``' .. changeString(getBots()[i]:getWorld().name:upper(),math.floor(string.len(getBots()[i]:getWorld().name:upper()) / 2)) .. '``'
            
            syn.embed1:addField('['..i..'] '..changeString(getBots()[i].name:upper(),math.floor(string.len(getBots()[i].name) / 2)) .. ' ' .. status_,status_all,true)
        end
        syn.embed1.footer.icon_url = 'https://cdn.discordapp.com/attachments/1180523579381665933/1180577805403181076/20231203_013427.png'
        syn.embed1.footer.text = 'SYN SC All Tutor | Date : ' .. os.date("!%a, %b/%d/%Y at %I:%M %p", os.time() + 25200)
        if status_activity.msg == '' then syn:send() else syn:edit(status_activity.msg) end
    end
end
sleep(delayExe * (getIndex() - 1))
pickaxe()
if inventory:getItemCount(370) == 0 then 
  if not bot:isInWorld() then 
    bot:warp(bot.name:upper())
    sleep(delayWarp)
  end
  warplock()
  if inventory:getItemCount(98) > 0 then 
    bot:wear(98)
    sleep(500)
  end
  bot.auto_collect = true
  findTree(3,7)
  sleep(200)
  placeDirt()
  sleep(200)
  dirt(25)
  sleep(200)
  findDirt(22)
  sleep(200)
  Infobot('STEP 2')
  sleep(200)
  plant(3,10)
  sleep(31000)
  Infobot('STEP 3')
  sleep(200)
  harvest(3)
  sleep(200)
  Infobot('STEP 4')
  sleep(200)
  findTree(11,7)
  sleep(200)
  breakBlock(10,10)
  sleep(200)
  Infobot('STEP 5')
  sleep(200)
  findTree(5,10)
  sleep(200)
  breakBlock(4,10)
  sleep(200)
  Infobot('STEP 6')
  sleep(200)
  splice(3,5,10)
  sleep(68000)
  harvest(101)
  sleep(200)
  placeWood()
  sleep(200)
  Infobot('STEP 7')
  sleep(200)
  breakWood()
  sleep(200)
  Infobot('STEP 8')
  sleep(200)
  splice(101,3,1)
  sleep(122000)
  Infobot('STEP 9')
  sleep(200)
  word = getBot():getWorld().name
  reconnect(word,bot.x,bot.y)
  bot:hit(bot.x,bot.y)
  sleep(delayHarvest)
  reconnect(word,bot.x,bot.y)
  if scanfloat(370) > 0 then 
    reconnect(word,bot.x,bot.y)
    takefloat(370)
    reconnect(word,bot.x,bot.y)
    sleep(100)
    Infobot('STEP 10')
    sleep(200)
    reconnect(word,bot.x,bot.y)
    bot:wear(370)
    sleep(500)
  end
end
bot.auto_collect = false
sleep(1000)
bot:say("/sethome")
sleep(1000)
meMethodkan()
sleep(100)
Infobot('DROP TRASH')
sleep(200)
Droplist()
reconnect(dropWorld,bot.x,bot.y)
sleep(1000)
InfoNotif('['..bot.name..'] Finish Tutorial Quust!')
bot.auto_reconnect = false
bot:disconnect()
bot:stopScript()

