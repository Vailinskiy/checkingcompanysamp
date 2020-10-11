script_name('Company Pomogator')
script_author("kreyN")
script_version("1.0")

require "lib.moonloader"
require "lib.sampfuncs"
local sampev = require "samp.events"
local dlstatus = require ('moonloader').download_status
local as_action = require('moonloader').audiostream_state
local memory = require "memory"
local imgui = require 'imgui'
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
local fa = require 'faIcons'
local effil = require 'effil'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
encoding.default = 'CP1251'
u8 = encoding.UTF8


local directIni = "settingscomp.ini"
local mainIni = inicfg.load({
    config =
    {
        NotfAboutAcceptingInCC = false,
        NotfAboutAns = false,
        themenumber = 1,
        MinimalOrder = 0,
        ProductTypeToDeliveryFirst = "",
        ProductTypeToDeliverySecond = "",
        ProductTypeToDeliveryThird = "",
        ProductTypeToDeliveryFourth = "",
        ProductTypeNumberToDeliveryFirst = 0,
        ProductTypeNumberToDeliverySecond = 0,
        ProductTypeNumberToDeliveryThird = 0,
        ProductTypeNumberToDeliveryFourth = 0,
        ifDeliveryToLS = false,
        ifDeliveryToSF = false,
        ifDeliveryToLV = false,
        FirstNumberOfStorage = 0,
        SecondNumberOfStorage = 0,
        MinimalAmountToAccept = 0,
        AcceptedNumber = 0,
        AcceptedDeliveries = 0,
        AcceptedProduct = 0,
        MoneyFromSells = 0,
        MoneyFromDeliveries = 0,
        NotfAboutAnsVK = false,
        NotfAboutMovingVK = false,
        NotfAboutLostConnection = false,
        PPose = false,
        AntiAFKBoolean = false,
        AutoUpdate = true,
        PlayerVKID = 0
    },
    acceptedlog = {}
    }, directIni
)
-------- Загрузка ини
if not doesFileExist(directIni) then
    inicfg.save(mainIni, directIni)
end


--------
------ Все переменные
local script_version = 1
local script_versiontext = '1.0'
local uppath = thisScript().path
local upinfourl = "https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/scrptvers.ini"
local updownloadurl = ""
local autoupdatebool = imgui.ImBool(mainIni.config.AutoUpdate)
local site = "https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/somename"
local notfanssound = loadAudioStream('https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/notfhint.wav')
local NotfAboutAcceptingInCompanyChat = imgui.ImBool(mainIni.config.NotfAboutAcceptingInCC)
local NotfAns = imgui.ImBool(mainIni.config.NotfAboutAns)
local NotfAnsVK = imgui.ImBool(mainIni.config.NotfAboutAnsVK)
local NotfMoveVK = imgui.ImBool(mainIni.config.NotfAboutMovingVK)
local otherPos = imgui.ImBool(mainIni.config.PPose)
local NotfLostConn = imgui.ImBool(mainIni.config.NotfAboutLostConnection)
local aafkbool = imgui.ImBool(mainIni.config.AntiAFKBoolean)
local PVKID = imgui.ImInt(mainIni.config.PlayerVKID)
local main_window_state = imgui.ImBool(false)
local radio_theme = imgui.ImInt(mainIni.config.themenumber)
local productintostorage_comboselect1 = imgui.ImInt(mainIni.config.ProductTypeNumberToDeliveryFirst)
local productintostorage_comboselect2 = imgui.ImInt(mainIni.config.ProductTypeNumberToDeliverySecond)
local productintostorage_comboselect3 = imgui.ImInt(mainIni.config.ProductTypeNumberToDeliveryThird)
local productintostorage_comboselect4 = imgui.ImInt(mainIni.config.ProductTypeNumberToDeliveryFourth)
local fnumberofstorage = imgui.ImInt(mainIni.config.FirstNumberOfStorage)
local snumberofstorage = imgui.ImInt(mainIni.config.SecondNumberOfStorage)
local amountofacceptedorders = imgui.ImInt(mainIni.config.AcceptedNumber)
local amountofaccepteddeliveries = imgui.ImInt(mainIni.config.AcceptedDeliveries)
local amountofmoneyfromsells = imgui.ImFloat(mainIni.config.MoneyFromSells)
local amountofmoneyfromdeliveries = imgui.ImFloat(mainIni.config.MoneyFromDeliveries)
local amountofacceptedproduct = imgui.ImInt(mainIni.config.AcceptedProduct)
local screnabled = imgui.ImBool(false)
local dlpointls = imgui.ImBool(mainIni.config.ifDeliveryToLS)
local dlpointsf = imgui.ImBool(mainIni.config.ifDeliveryToSF)
local dlpointlv = imgui.ImBool(mainIni.config.ifDeliveryToLV)
local prod_slad1 = u8:decode(mainIni.config.ProductTypeToDeliveryFirst)
local prod_slad2 = u8:decode(mainIni.config.ProductTypeToDeliverySecond)
local prod_slad3 = u8:decode(mainIni.config.ProductTypeToDeliveryThird)
local prod_slad4 = u8:decode(mainIni.config.ProductTypeToDeliveryFourth)
local min_zakaz = imgui.ImInt(mainIni.config.MinimalAmountToAccept)
local menunum = 0
local xyz = 0
local tag = " {bf8f15}CHelper {ffffff}• "
------

local changelog = [[
    v1.0
    • Релиз скрипта
]]


------ Все массивы
colorThemes = {u8"Красная", u8"Фиолетовая", u8"Зелёная"}

--numberofstorage = {}
local dlendpointsls = {
    'Police Department LS',
    'Аэропорт Los Santos',
    'Больница Los Santos',
    'СТО Los Santos',
    'Байкерский клуб Hells Angels',
    'Здание Суда',
    'Business Center',
    'Администрация Президента',
    ''
}
local dlendpointssf = {
    'Police Department SF',
    'Аэропорт San Fierro',
    'Больница San Fierro',
    'СТО San Fierro',
    'Порт Bayside',
    'Железнодорожный завод',
    'База ВМФ',
    'Байкерский клуб Bandidos',
}
local dlendpointslv = {
    'Police Department LV',
    'Аэропорт Las Venturas',
    'Больница Las Venturas',
    'СТО Las Venturas',
    'Bar "Amnesia"',
    'База ВВС',
    'База СВ',
    'Family Center',
    'Байкерский клуб Outlaws',
    'Байкерский клуб Bandidos',
    'Alcatraz',
}
local producttype = {
    u8'',
    u8'Алкоголь',
    u8'Аксессуары',
    u8'Автозапчасти',
    u8'Канцелярские товары',
    u8'Косметические средства',
    u8'Мебель',
    u8'Одежда',
    u8'Оружие',
    u8'Пиротехника',
    u8'Продукты питания',
    u8'Парашютное снаряжение',
    u8'Радиоигрушки',
    u8'Спорт-Товары',
    u8'Транспорт',
    u8'Товары общего пользования',
}

------





--------- Работа с уведомлениями ВК
--vk longpoll api globals
local key, server, ts

function threadHandle(runner, url, args, resolve, reject) -- обработка effil потока без блокировок
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end

function requestRunner() -- создание effil потока с функцией https запроса
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end

function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(function()
		threadHandle(runner, url, args, resolve, reject)
	end)
end

local vkerr, vkerrsend -- сообщение с текстом ошибки, nil если все ок
function tblfromstr(str)
	local a = {}
	for b in str:gmatch('%S+') do
		a[#a+1] = b
	end
	return a
end

function loop_async_http_request(url, args, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(function()
		while true do
			while not key do wait(0) end
			url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --меняем url каждый новый запрос потокa, так как server/key/ts могут изменяться
			threadHandle(runner, url, args, longpollResolve, reject)
		end
	end)
end


function sendvknotf(msg, host)
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if mainIni.config.PlayerVKID > 0 then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. mainIni.config.PlayerVKID .. '&message=' .. msg .. '&access_token=985ad417a7bc5638437851e3712f700c32585956bfaa2e412471b79da0fa8c993d7255ed33c3902b16591&v=5.80',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end

function longpollGetKey()
	async_http_request('https://api.vk.com/method/groups.getLongPollServer?group_id=199233305&access_token=985ad417a7bc5638437851e3712f700c32585956bfaa2e412471b79da0fa8c993d7255ed33c3902b16591&v=5.80', '', function (result)
		if result then
			if not result:sub(1,1) == '{' then
				vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
				return
			end
			local t = decodeJson(result)
			if t.error then
				vkerr = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
				return
			end
			server = t.response.server
			ts = t.response.ts
			key = t.response.key
			vkerr = nil
		end
	end)
end

----------- Отправка сообщений из ВК в игру
function longpollResolve(result)
	if result then
		if not result:sub(1,1) == '{' then
			vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
			return
		end
		local t = decodeJson(result)
		if t.failed then
			if t.failed == 1 then
				ts = t.ts
			else
				key = nil
				longpollGetKey()
			end
			return
		end
		if t.ts then
			ts = t.ts
		end
		if t.updates then
			for k, v in ipairs(t.updates) do
				if v.type == 'message_new' and tonumber(v.object.from_id) == tonumber(mainIni.config.PlayerVKID) and v.object.text then
					if v.object.payload then
						local pl = decodeJson(v.object.payload)
						if pl.button then
							if pl.button == 'sumearned' then
                                sendvknotf('Суммарно заработанная сумма с помощью бота(продажи+доставка): ' .. mainIni.config.MoneyFromSells + mainIni.config.MoneyFromDeliveries)
                                return
							elseif pl.button == 'commands' then
                                sendvknotf('Доступные команды:\n—» !sendtochat [ваше сообщение] - отправить сообщение в чат игры\n—» !quit - экстренное прерывание пакетов данных(т.е. отключение от сервера). Данный способ беспалевный, т.к. в этом случае вы "вылетаете" с сервера с ошибкой.')
                                return
                            elseif pl.button == 'stats' then
                                sendvknotf('—» Количество принятых заказов: ' .. amountofacceptedorders.v .. '\n—» Количество принятых доставок: '..amountofaccepteddeliveries.v..'\n—» Заработанная сумма с продажи товаров со склада: '.. amountofmoneyfromsells.v)
                            
                            end
						end
					end
                    local objsend = tblfromstr(v.object.text)
                    if objsend[1] == '!sendtochat' then
                        print('this')
                        local args = table.concat(objsend, " ", 2, #objsend) 
                        if #args > 0 then
                            args = u8:decode(args)
                            sampSendChat(args)
                            sendvknotf('Сообщение "' .. args .. '" было успешно отправлено в игру')
                        else
                            sendvknotf('Неправильный аргумент! Пример: !sendtochat [строка]')
                        end
                    elseif objsend[1] == '!quit' then
                        sendEmptyPacket(PACKET_CONNECTION_LOST)
                        closeConnect()
                        sendvknotf('Успешно разорвано соединение с сервером.')
                    end
				end
			end
		end
	end
end
-----------

------ Клавиатура ВК 
function vkKeyboard() --создает конкретную клавиатуру для бота VK, как сделать для более общих случаев пока не задумывался
	local keyboard = {}
	keyboard.one_time = false
	keyboard.buttons = {}
    keyboard.buttons[1] = {}
    keyboard.buttons[2] = {}
    local row = keyboard.buttons[1]
    local row2 = keyboard.buttons[2]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'secondary'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "sumearned"}'
    row[1].action.label = 'Суммарно заработано'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'secondary'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "stats"}'
    row[2].action.label = 'Статистика'
    row2[1] = {}
    row2[1].action = {}
	row2[1].color = 'primary'
	row2[1].action.type = 'text'
	row2[1].action.payload = '{"button": "commands"}'
    row2[1].action.label = 'Команды'
	return encodeJson(keyboard)
end

---------- Функции кнопок клавиатуры
function sendHelp()
	local response = 'Отправить сообщение на аккаунт /send\nПока все ://'
	vk_request(response)
end
----------

-----------------------

------ Main function
function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
        while not isSampAvailable() do wait(100) end
    --------- Проверка на наличие ключа
        while sampGetCurrentServerName() == 'SA-MP' do wait(0) end
        local bool, users = getTableUsersByUrl(site)
        assert(bool, 'Downloading list users failed.')
        local _, myid = sampGetPlayerIdByCharHandle(playerPed)
        if isAvailableUser(users, sampGetPlayerNickname(myid)) == false then
            sampAddChatMessage(tag .. "Купите сначала ключ, затем используйте.", 4290744085)
            sampAddChatMessage(tag .. "После добавления вас в список, перезапустите игру, чтобы все заработало.", 4290744085)
            thisScript():unload()
        else
            sampAddChatMessage(tag .. "Вы находитесь в списке. Приятного заработка.", 4290744085)
        end
        if autoupdatebool.v then
            autoupdate(upinfourl, updownloadurl, '##nil', thisScript().path)
        end
    --------
        wait(100)
            sampRegisterChatCommand("ch", cmd_ch)
            sampRegisterChatCommand("test", cmd_test)
            sampRegisterChatCommand("test2", cmd_test2)
        imgui.SwitchContext()
        SwitchColorTheme(mainIni.config.themenumber)
        workwithoutpause(mainIni.config.AntiAFKBoolean)
        lua_thread.create(vkget)
    while true do
        wait(0)
        px, py, pz = getCharCoordinates(PLAYER_PED)
        -- IMGUI
        imgui.Process = main_window_state.v
    end
end

function char_to_hex(str)
	return string.format("%%%02X", string.byte(str))
end

function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end



------ Регистрация команд

function cmd_ch()
    main_window_state.v = not main_window_state.v
end

function cmd_test(arg)
    arg = "Департамент ЛС - Оружие - 20.000 - $1.20"
    amountofacceptedorders.v = amountofacceptedorders.v+1
    mainIni.config.AcceptedNumber = amountofacceptedorders.v
    local kolvo = 20000
    local price = 1.20 
    amountofmoneyfromsells.v = price*kolvo+amountofmoneyfromsells.v
    mainIni.config.MoneyFromSells = amountofmoneyfromsells.v
    table.insert(mainIni.acceptedlog, arg)
    inicfg.save(mainIni, directIni)
    arg = "Больница Las Venturas - Косметические средства - 35.000 - $1.00"
    amountofacceptedorders.v = amountofacceptedorders.v+1
    mainIni.config.AcceptedNumber = amountofacceptedorders.v
    local kolvo = 35000
    local price = 1.00 
    amountofmoneyfromsells.v = price*kolvo+amountofmoneyfromsells.v
    mainIni.config.MoneyFromSells = amountofmoneyfromsells.v
    amountofacceptedproduct.v = 55000
    mainIni.config.AcceptedProduct = amountofacceptedproduct.v
    table.insert(mainIni.acceptedlog, arg)
    inicfg.save(mainIni, directIni)
end

function cmd_test2() -- '%{FFDF80%}(.+)%.%{FFFFFF%} Перевозка товаров [Склад №(.+) %- (.*)%] (.+) (.+) %$(.+)'
    --[[strngg = '{FFDF80}1.{FFFFFF} Перевозка товаров [Склад №39 - База СВ] Оружие 10600 $0.60'
    sampAddChatMessage(strngg, -1) -- {FFDF80}(%d+).{FFFFFF}%s(.*)%c(.*)%c(%d+)%s%-%s$(%S+)%c$(%S+)]]
    sampShowDialog(15, "Head", '{FFDF80}1.{FFFFFF} Перевозка товаров [Склад №39 - База СВ]\tОружие\t10600\t$0.60', "ok", 'cancel', 4)
    local input = sampGetDialogText()
                    sampAddChatMessage(input,-1)
                    print(input)
                    local numm, numskladd, deliverypointt, prdtypee, amountt, pricee = input:match('%{FFDF80%}(%d+)%.%{FFFFFF%} Перевозка товаров %[Склад №(.+) %- (.*)%]	(.*)	(%d+)	%$(.*)')
                    if numm ~= nil then
                        sampAddChatMessage('Num: '..numm..'.', -1)
                    else
                        sampAddChatMessage('No matches numm', -1)
                    end
                    if numskladd ~= nil then
                        sampAddChatMessage('Numsklad: '..numskladd..'.', -1)
                    else
                        sampAddChatMessage('No matches numsklad', -1)
                    end
                    if deliverypointt ~= nil then
                        sampAddChatMessage('DLP: '..deliverypointt..'.', -1)
                    else
                        sampAddChatMessage('No matches DLP', -1)
                    end
                    if prdtypee ~= nil then
                        sampAddChatMessage('PDT: '..prdtypee..'.', -1)
                    else
                        sampAddChatMessage('No matches PDT', -1)
                    end
                    if amountt ~= nil then
                        sampAddChatMessage('Amount: '..amountt..'.', -1)
                    else
                        sampAddChatMessage('No matches Amount', -1)
                    end
                    if pricee ~= nil then
                        sampAddChatMessage('Price: '..pricee..'.', -1)
                    else
                        sampAddChatMessage('No matches Price', -1)
                    end
end

------ Как в чате появится строка, то..
function sampev.onServerMessage(color, text)
        if color == -6732289 and NotfAns.v then
            setAudioStreamState(notfanssound, 1)
            setAudioStreamVolume(notfanssound, 100)
        end
        if color == -6732289 and NotfAnsVK.v then
            sendvknotf("Сообщение от администратора:\n" .. text)
        end
    if not isPauseMenuActive() and screnabled.v then
        
        if text:find("Новый заказ на бирже доставки товара. Введите /company для просмотра") then
            sampAddChatMessage("• {FFC800}[Подсказка] {ffffff}Новый заказ на бирже доставки товара. Введите /company для просмотра", -1)
            sampSendChat('/exchange2')
        end
        if text:find("2 новых заказов на бирже продажи товара. Введите /company для просмотра") then
            sampAddChatMessage("• {FFC800}[Подсказка] {ffffff}2 новых заказов на бирже продажи товара. Введите /company для просмотра", -1)
            if sampIsDialogActive() == false then
                sampSendChat("/exchange1")
            elseif dialogId ~= 1267 then
                lua_thread.create(function()
                    wait(1)
                    sampCloseCurrentDialogWithButton(0)
                    local _, id = sampGetPlayerIdByCharHandle()
                    local ping = sampGetPlayerPing(id)
                    wait(ping+5)
                    sampCloseCurrentDialogWithButton(0)
                    sampSendChat("/exchange1")
                end)
            end
        end
    end
end

------ Как откроется диалог, то..
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 1240 and screnabled.v and main_window_state then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(0)
        end)
    end
    if dialogId == 1268 and screnabled.v and main_window_state then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1267 and screnabled.v then
        lua_thread.create(function ()
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d+%.{FFFFFF}") then
                    local num, kuda, tovar, kolvo, price, dostavka = line:match("{FFDF80}(%d+).{FFFFFF}%s(.*)%c(.*)%c(%d+)%s%-%s$(%S+)%c$(%S+)")
                    if dlpointls.v then
                        if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) then
                            if has_value(dlendpointsls, kuda) then
                                sampSendDialogResponse(1267, 1, num-1, -1)
                                local _, id = sampGetPlayerIdByCharHandle()
                                local ping = sampGetPlayerPing(id)
                                wait(ping+5)
                                if not text:find("{AC0000}[Ошибка] {ffffff}На Ваших складах недостаточно товара для этого заказа") then
                                    amountofacceptedorders.v = amountofacceptedorders.v+1
                                    amountofacceptedproduct.v = kolvo+amountofacceptedproduct.v
                                    mainIni.config.AcceptedNumber = amountofacceptedorders.v
                                    mainIni.config.MoneyFromSells = price*kolvo + amountofmoneyfromsells.v
                                    mainIni.config.AcceptedProduct = amountofacceptedproduct.v
                                    inicfg.save(mainIni, directIni)
                                    table.insert(mainIni.acceptedlog, tempstring1)
                                end
                            end
                        end
                    end
                    if dlpointsf.v then
                        if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) and has_value(dlendpointssf, kuda) then
                            if has_value(dlendpointssf, kuda)  then 
                                sampSendDialogResponse(1267, 1, num-1, -1)
                                local _, id = sampGetPlayerIdByCharHandle()
                                local ping = sampGetPlayerPing(id)
                                wait(ping+5)
                                if not text:find("{AC0000}[Ошибка] {ffffff}На Ваших складах недостаточно товара для этого заказа") then
                                    amountofacceptedorders.v = amountofacceptedorders.v+1
                                    mainIni.config.AcceptedNumber = amountofacceptedorders.v
                                    mainIni.config.MoneyFromSells = price*kolvo + amountofmoneyfromsells.v
                                    inicfg.save(mainIni, directIni)
                                    table.insert(mainIni.acceptedlog, tempstring1)
                                end
                            end
                        end
                    end
                    if dlpointlv.v then
                        if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) and has_value(dlendpointslv, kuda) then
                            if has_value(dlendpointslv, kuda) then 
                                sampSendDialogResponse(1267, 1, num-1, -1)
                                local _, id = sampGetPlayerIdByCharHandle()
                                local ping = sampGetPlayerPing(id)
                                wait(ping+5)
                                if not text:find("{AC0000}[Ошибка] {ffffff}На Ваших складах недостаточно товара для этого заказа") then
                                    amountofacceptedorders.v = amountofacceptedorders.v+1
                                    mainIni.config.AcceptedNumber = amountofacceptedorders.v
                                    mainIni.config.MoneyFromSells = price*kolvo + amountofmoneyfromsells.v
                                    inicfg.save(mainIni, directIni)
                                    table.insert(mainIni.acceptedlog, tempstring1)
                                end
                            end
                        end
                    end
                elseif line:find("Далее") then
                    sampSendDialogResponse(1267, 1, 52, -1)
                    local _, id = sampGetPlayerIdByCharHandle()
                    local ping = sampGetPlayerPing(id)
                    wait(ping+5)
                    sampCloseCurrentDialogWithButton(0)
                end
            end
        end)
    end
    if dialogId == 1269 and screnabled.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1270 and screnabled.v then
        for line in text:gmatch("[^\r\n]+") do
            if line:find("%%{FFDF80%}%d+%.%{FFFFFF%}") then
                local num, numsklad, deliverypoint, prdtype, amount, price = text:match('%{FFDF80%}(%d+)%.%{FFFFFF%} Перевозка товаров %[Склад №(.+) %- (.*)%]	(.*)	(%d+)	%$(.*)')
                tempstring1 = deliverypoint.." - "..prdtype.." - "..amount.." - $"..price..""
                if numsklad == fnumberofstorage.v or numsklad == snumberofstorage.v then
                    sampSendDialogResponse(1267, 1, num-1, -1)
                    amountofaccepteddeliveries.v = amountofaccepteddeliveries.v+amount
                    mainIni.config.AcceptedDeliveries = amountofaccepteddeliveries.v
                    amountofmoneyfromdeliveries.v = amountofmoneyfromdeliveries.v+price*amount
                    mainIni.config.MoneyFromDeliveries = amountofmoneyfromdeliveries.v
                    inicfg.save(mainIni, directIni)
                    table.insert(mainIni.acceptedlog, tempstring1)
                    if NotfAboutAcceptingInCompanyChat.v then
                        sampSendChat("[! Новый заказ !] Цена за доставку: " .. price .. "$, количество: " .. amount .. " ед., тип: " .. prdtype..".")
                    end
                end
            end
        end
    end
    if dialogId == 1271 and screnabled.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1272 and screnabled.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
end





function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
    end
end

SwitchColorTheme = function(theme)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 10.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 5.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    if theme == 1 or theme == nil then
        colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
        colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
        colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.ChildWindowBg]          = colors[clr.WindowBg];
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
        colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
        colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
        colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBgActive]          = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
        colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
        colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
        colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
        colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
        colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
        colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
        colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
        colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
        colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
    elseif theme == 2 then
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00);
        colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.ChildWindowBg]          = colors[clr.WindowBg];
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50);
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00);
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.35, 0.74, 0.40);
        colors[clr.FrameBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.MenuBarBg]              = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53);
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00);
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00);
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00);
        colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
        colors[clr.CheckMark]              = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.Button]                 = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.ButtonHovered]          = ImVec4(0.45, 0.05, 0.60, 1.00);
        colors[clr.ButtonActive]           = ImVec4(0.35, 0.01, 0.50, 1.00);
        colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.HeaderHovered]          = ImVec4(0.29, 0.33, 0.98, 0.80);
        colors[clr.HeaderActive]           = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ResizeGripHovered]      = ImVec4(0.40, 0.39, 0.38, 0.16);
        colors[clr.ResizeGripActive]       = ImVec4(0.40, 0.39, 0.38, 0.39);
        colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
        colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
        colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
        colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35);
        colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
    elseif theme == 3 then
        colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[clr.ChildWindowBg]          = colors[clr.WindowBg]
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
        colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
        colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
        colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
        colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
        colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
        colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
        colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
        colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
        colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
    end
end

function imgui.OnDrawFrame()
        imgui.LockPlayer = true
        local sw, sh = getScreenResolution()
            -- center
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(900, 370), imgui.Cond.FirstUseEver)
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
        local button_size = imgui.ImVec2(200,30)
        local smallbutton_size = imgui.ImVec2(70, 19)
        imgui.Begin("Company Helper", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
        local pos = imgui.GetCursorScreenPos()
		local menu_colors = {
            u_left = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]),
            u_right = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]),
            b_right = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]),
            b_left = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button])
        }
        imgui.GetWindowDrawList():AddRectFilledMultiColor(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 200, pos.y + 600), menu_colors.u_left:GetU32(),menu_colors.u_right:GetU32(),menu_colors.b_right:GetU32(),menu_colors.b_left:GetU32())

            imgui.SetCursorPos(imgui.ImVec2(0,135))
            imgui.BeginGroup()
            if imgui.Button(fa.ICON_TABLE .. u8"  Статистика", button_size) then
                menunum = 0
            end
            if imgui.Button(fa.ICON_COGS .. u8"  Настройки", button_size) then
                menunum = 1
            end
            imgui.EndGroup()
            imgui.SetCursorPos(imgui.ImVec2(205, 5))
            if menunum == 0 then
                imgui.BeginChild(u8"Окно статистики", imgui.ImVec2(685, 23), true)
                    imgui.Columns(3, _, true)
                    imgui.Separator()
                    imgui.SetColumnWidth(-1, 225); imgui.SetCursorPosX(7); imgui.Text(" "..fa.ICON_ROCKET .. u8"  Кол-во пойм. заказов: ".. amountofacceptedorders.v); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 225); imgui.SetCursorPosY(5); imgui.Text(" "..fa.ICON_PRODUCT_HUNT .. u8"  Кол-во принятого товара: " .. amountofacceptedproduct.v); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 240); imgui.SetCursorPosY(5); imgui.Text(" "..fa.ICON_USD .. u8"  Цена проданного товара: " .. amountofmoneyfromsells.v); imgui.NextColumn()
                imgui.EndChild()

                imgui.SetCursorPosX(205)
                imgui.BeginChild(u8"Окно лога", imgui.ImVec2(685, 332), true)
                    imgui.SetCursorPosY(5)
                    imgui.CenterText(u8"Окно лога действий")
                    imgui.SameLine()
                    imgui.SetCursorPosX(605)
                    imgui.SetCursorPosY(5)
                    if imgui.Button(u8"Очистить", smallbutton_size) then
                        imgui.OpenPopup("##clearbutton")
                    end
                    if imgui.BeginPopupModal("##clearbutton", true, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                        imgui.CenterText(u8"Вы действительно хотите очистить всю статистику?")
                        imgui.CenterText(u8"Данное действие необратимо.")
                        imgui.SetCursorPosX(80)
                        if imgui.Button(u8"Да", smallbutton_size) then
                            mainIni.acceptedlog = {}
                            amountofacceptedorders.v = 0
                            amountofaccepteddeliveries.v = 0
                            amountofmoneyfromsells.v = 0
                            amountofmoneyfromdeliveries.v = 0
                            amountofacceptedproduct.v = 0
                            mainIni.config.AcceptedNumber = amountofacceptedorders.v 
                            mainIni.config.AcceptedDeliveries = amountofaccepteddeliveries.v
                            mainIni.config.MoneyFromSells = amountofmoneyfromsells.v
                            mainIni.config.MoneyFromDeliveries = amountofmoneyfromdeliveries.v
                            mainIni.config.AcceptedProduct = amountofacceptedproduct.v
                            inicfg.save(mainIni, directIni)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8"Нет", smallbutton_size) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    imgui.Separator()
                    imgui.BeginChild("##220", imgui.ImVec2(685, 300), false)
                    imgui.Columns(5, _, true)
                    imgui.SetColumnWidth(-1, 30); imgui.SetCursorPosX(10); imgui.Text(fa.ICON_SORT_NUMERIC_ASC); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 155); imgui.Text(u8"Куда доставлено"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 155); imgui.Text(u8"Тип"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 119); imgui.Text(u8"Количество"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 119); imgui.Text(fa.ICON_USD .. u8" Цена за ед."); imgui.NextColumn()
                    for k, v in ipairs(mainIni.acceptedlog) do
                    imgui.Separator() -- Департамент ЛС - Оружие - 20.000 - $1.20
                        local point, prdtp, amount, prce = v:match("(.*) %- (.*) %- (.*) %- %$(.*)")
                        imgui.SetCursorPosX(10)
                        if point ~= nil and prdtp ~= nil and amount ~= nil and prce ~= nil then
                            imgui.Text('' .. k)
                            imgui.NextColumn()
                            imgui.Text(u8(point..''))
                            imgui.NextColumn()
                            imgui.Text(u8(prdtp..''))
                            imgui.NextColumn()
                            imgui.Text(u8(amount..''))
                            imgui.NextColumn()
                            imgui.Text(u8(prce..''))
                            imgui.NextColumn()
                            --
                        end
                    end
                    imgui.Columns(1)
                    imgui.Separator()
                    imgui.EndChild()
                imgui.EndChild()
            elseif menunum == 1 then
                imgui.BeginChild(u8"Окно настроек", imgui.ImVec2(340, 150), true)
                imgui.SetCursorPosX(7)
                imgui.SetCursorPosY(7)
                    imgui.BeginGroup()
                        imgui.CenterText(u8"Настройка опций")
                        if imgui.Checkbox(u8"Ловля заказов", screnabled) then end
                        imgui.SameLine()
                        imgui.SetCursorPosX(135)
                        if imgui.Checkbox(u8"AAFK", aafkbool) then workwithoutpause(aafkbool.v) end
                        imgui.SameLine()
                        imgui.TextQuestion(u8"Будьте внимательны, данная функция сохраняется\nв настройках. Т.е. при заходе в следующий раз, она\nавтоматически будет включена.")
                        imgui.SameLine()
                        imgui.SetCursorPosX(220)
                        if imgui.Checkbox(u8"AutoUpdate", autoupdatebool) then end
                        imgui.EndGroup()
                imgui.Separator()
                imgui.SetCursorPosX(7)
                imgui.SetCursorPosY(55)
                    imgui.BeginGroup()
                        imgui.CenterText(u8"Темы")
                        for gg, value in pairs(colorThemes) do
                            if imgui.RadioButton(value, radio_theme, gg) then
                                SwitchColorTheme(gg)
                                mainIni.config.themenumber = gg
                                inicfg.save(mainIni, directIni)
                            end
                        end
                    imgui.EndGroup()
                imgui.EndChild()
                -------
                imgui.SameLine()
                -------
                imgui.SetCursorPosX(550)
                imgui.SetCursorPosY(5)
                imgui.BeginChild(u8"Окно настроек фильтра", imgui.ImVec2(340, 150), true)
                        imgui.SetCursorPosY(5)
                        imgui.CenterText(u8"Брать заказы из городов "); imgui.SameLine(); imgui.TextQuestion(u8"Заказы будут браться из одного или нескольких городов")
                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Лос-Сантос", dlpointls, 0) then
                            mainIni.config.ifDeliveryToLS = dlpointls.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX(110)
                        if imgui.Checkbox(u8"Сан-Фиерро", dlpointsf, 1) then
                            mainIni.config.ifDeliveryToSF = dlpointsf.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX(215)
                        if imgui.Checkbox(u8"Лас-Вентурас", dlpointlv, 2) then
                            mainIni.config.ifDeliveryToLV = dlpointlv.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.Separator()
                        imgui.CenterText(u8"Минимальное количество товаров для заказа "); imgui.SameLine(); imgui.TextQuestion(u8"От сколько единиц брать заказы в /exchange1")
                        imgui.SetCursorPosX(10)
                        imgui.PushItemWidth(100)
                        if imgui.InputInt("##3", min_zakaz, 0, 0) then
                            mainIni.config.MinimalAmountToAccept = min_zakaz.v
                            inicfg.save(mainIni, directIni)
                        end
                imgui.EndChild()
                ------
                imgui.SetCursorPos(imgui.ImVec2(205, 160))
                imgui.BeginChild(u8"Окно настроек складов", imgui.ImVec2(340, 200), true)
                        imgui.SetCursorPosX(170)
                        imgui.SetCursorPosY(5)
                        imgui.CenterText(u8"Номера 2 ваших складов")
                        imgui.PushItemWidth(70)
                        imgui.SetCursorPosX(10)
                        if imgui.InputInt("##1", fnumberofstorage, 0, 0) then
                            if fnumberofstorage.v < 0 then fnumberofstorage.v = 0 elseif fnumberofstorage.v > 99 then fnumberofstorage.v = 99 end
                            mainIni.config.FirstNumberOfStorage = fnumberofstorage.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        if imgui.InputInt("##2", snumberofstorage, 0, 0) then
                            if snumberofstorage.v < 0 then snumberofstorage.v = 0 elseif snumberofstorage.v > 99 then snumberofstorage.v = 99 end
                            mainIni.config.SecondNumberOfStorage = snumberofstorage.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.Separator()
                        imgui.CenterText(u8"Типы товаров")
                        imgui.SameLine()
                        imgui.TextQuestion(u8"Используется при ловле заказов")
                        imgui.PushItemWidth(180)
                        imgui.SetCursorPosX(10)
                        if imgui.Combo("##11", productintostorage_comboselect1, producttype) then
                            mainIni.config.ProductTypeToDeliveryFirst = producttype[productintostorage_comboselect1.v+1]
                            mainIni.config.ProductTypeNumberToDeliveryFirst = productintostorage_comboselect1.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.PushItemWidth(180)
                        imgui.SetCursorPosX(10)
                        if imgui.Combo("##12", productintostorage_comboselect2, producttype) then
                            mainIni.config.ProductTypeToDeliverySecond = producttype[productintostorage_comboselect2.v+1]
                            mainIni.config.ProductTypeNumberToDeliverySecond = productintostorage_comboselect2.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.PushItemWidth(180)
                        imgui.SetCursorPosX(10)
                        if imgui.Combo("##13", productintostorage_comboselect3, producttype) then
                            mainIni.config.ProductTypeToDeliveryThird = producttype[productintostorage_comboselect3.v+1]
                            mainIni.config.ProductTypeNumberToDeliveryThird = productintostorage_comboselect3.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.PushItemWidth(180)
                        imgui.SetCursorPosX(10)
                        if imgui.Combo("##14", productintostorage_comboselect4, producttype) then
                            mainIni.config.ProductTypeToDeliveryFourth = producttype[productintostorage_comboselect4.v+1]
                            mainIni.config.ProductTypeNumberToDeliveryFourth = productintostorage_comboselect4.v
                            inicfg.save(mainIni, directIni)
                        end
                imgui.EndChild()

                imgui.SameLine()

                imgui.BeginChild(u8"Окно настройки уведомлений", imgui.ImVec2(340, 200), true)
                        imgui.SetCursorPosY(3)
                        imgui.CenterText(u8"Уведомления")
                        imgui.Separator()
                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Уведомление в чат компании о принятии заказа", NotfAboutAcceptingInCompanyChat, 12) then
                            mainIni.config.NotfAboutAcceptingInCC = NotfAboutAcceptingInCompanyChat.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.TextQuestion(u8"Автоматически отправляет в /cm сообщение с\nинформацией о новом заказе.")
                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Звуковое уведомление об /ans", NotfAns, 13) then
                            mainIni.config.NotfAboutAns = NotfAns.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.TextQuestion(u8("Данное уведомление сработает при появлении вопросов\nк вам со стороны администрации."))

                        imgui.Separator()

                        imgui.CenterText(u8"Уведомления в ВК")

                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Уведомления об /ans", NotfAnsVK, 14) then
                            mainIni.config.NotfAboutAnsVK = NotfAnsVK.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.TextQuestion(u8("Если администратор напишет вам в /ans, то бот группы\nнапишет вам в лс в ВК. Для этого нужно указать\nID ВК вашей страницы ниже."))

                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Уведомления об изменении позиции персонажа", otherPos, 15) then
                            mainIni.config.PPose = otherPos.v
                        end
                        imgui.SameLine()
                        imgui.TextAlert("{ffffff}Если персонаж изменил свою позицию(например,\n  слап админа), то вам придет сообщение об этом в ВК.\n\n  {ff5452}Будьте осторожны с данной опцией{ffffff}, ведь оно отправляет\n  сообщения при {ff5452}каждом{ffffff} изменении позиции игрока со\n  стороны сервера")
                        
                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Уведомление о потере соединения", NotfLostConn, 16) then
                            mainIni.config.NotfAboutLostConnection = NotfLostConn.v
                            inicfg.save(mainIni, directIni)
                        end

                        imgui.SetCursorPosX(10)
                        imgui.PushItemWidth(80)
                        if imgui.InputInt("##111", PVKID, 0, 0) then
                            mainIni.config.PlayerVKID = PVKID.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.TextQuestion(u8('Укажите Ваш VK ID.\nГде его взять? Самый простой способ:\n  • Зайдите в "Настройки" вашего аккаунта\n  • В поле "Адрес страницы" нажмите "Изменить"\n  • Над кнопкой "Сохранить" будет текст - "Номер страницы - (цифры)"\n  • Перепишите эти цифры в поле "VK ID" '))
                imgui.EndChild()
            end
        imgui.End()
        imgui.PopStyleVar()
end

function handlePos(pos)
	if otherPos.v then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		sendvknotf('Сервер изменил позицию персонажа на\n X:' .. string.format('%.3f', pos.x) .. ' | Y: ' .. string.format('%.3f', pos.y) .. ' | Z: ' .. string.format('%.3f',  pos.z) .. ' || Расстояние: ' .. string.format('%.3f', getDistanceBetweenCoords3d(x, y, z, pos.x, pos.y, pos.z)) .. '\nВозможен телепорт или слап.')
	end
end

function sampev.onSetPlayerPos(pos)
    handlePos(pos)
end

function sampev.onSetPlayerPosFindZ(pos)
	handlePos(pos)
end

function onReceivePacket(id)
	if NotfLostConn.v then
		if id == 33 then
			sendvknotf('Потеряно соединение с сервером. Возможна потеря интернета, или нестабильность сервера. Требуется перезаход.')
		elseif id == 32 then
			sendvknotf('Сервер закрыл соединение. Возможен тихий кик, кик или бан. Требуется перезаход.')
		end
	end
end
------ Текст подсказки
function imgui.TextQuestion(text)
    imgui.TextDisabled(fa.ICON_INFO_CIRCLE)
    if imgui.IsItemHovered() then
        imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 6)
        imgui.BeginTooltip()
        local p = imgui.GetCursorScreenPos()
        imgui.SetCursorScreenPos(imgui.ImVec2(p.x + 10,p.y + 10))
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        local p = imgui.GetCursorScreenPos()
        local obrez = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize,450,450,text).x
        imgui.SetCursorScreenPos(imgui.ImVec2(p.x + obrez + 20,p.y + 10))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
        imgui.PopStyleVar()
    end
end

function imgui.TextAlert(text)
    imgui.TextDisabled(fa.ICON_EXCLAMATION_TRIANGLE)
    if imgui.IsItemHovered() then
        imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 6)
        imgui.BeginTooltip()
        local p = imgui.GetCursorScreenPos()
        imgui.SetCursorScreenPos(imgui.ImVec2(p.x + 10,p.y + 10))
        imgui.PushTextWrapPos(450)
        imgui.TextColoredRGB(text)
        local p = imgui.GetCursorScreenPos()
        local obrez = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize,450,450,text).x
        imgui.SetCursorScreenPos(imgui.ImVec2(p.x + obrez + 20,p.y + 10))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
        imgui.PopStyleVar()
    end
end

--------------- ВСЕ ОСТАЛЬНЫЕ ФУНКИ ---------------
----------- Закрытие окна на клавишу ESC
function onWindowMessage(m, p)
    if p == 0x1B and main_window_state.v then
        consumeWindowMessage()
        main_window_state.v = false
    end
end
----------- Централизация текста
function imgui.CenterText(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
----------- Сентрализация кнопки
function imgui.CenterButton(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Button(text)
end
----------- Скрытие курсора на краш скрипта
function onScriptTerminate(LuaScript, quitGame)

    if LuaScript == thisScript() and not quitGame then
        showCursor(false, false)
    end
end
----------- Вертикальный разделитель
function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end
----------- Цветной текст в имгуи
function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end
--------- гет вк
function vkget()
	longpollGetKey()
	local reject, args = function() end, ''
	while not key do 
		wait(1)
	end
	local runner = requestRunner()
	while true do
		while not key do wait(0) end
		url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --меняем url каждый новый запрос потокa, так как server/key/ts могут изменяться
		threadHandle(runner, url, args, longpollResolve, reject)
		wait(100)
	end
end


----------- ПРИВЯЗКА СКРИПТА К НИКУ -----------
----------- Таблица ников
function getTableUsersByUrl(url)
    local n_file, bool, users = os.getenv('TEMP')..os.time(), false, {}
    downloadUrlToFile(url, n_file, function(id, status)
        if status == 6 then bool = true end
    end)
    while not doesFileExist(n_file) do wait(0) end
    if bool then
        local file = io.open(n_file, 'r')
        for w in file:lines() do
            local n, d = w:match('(.*): (.*)')
            users[#users+1] = { name = n, date = d }
        end
        file:close()
        os.remove(n_file)
    end
    return bool, users
end
----------- Проверка на доступность
function isAvailableUser(users, name)
    for i, k in pairs(users) do
        if k.name == name then
            local d, m, y = k.date:match('(%d+)%.(%d+)%.(%d+)')
            local time = {
                day = tonumber(d),
                isdst = true,
                wday = 0,
                yday = 0,
                year = tonumber(y),
                month = tonumber(m),
                hour = 0
            }
            if os.time(time) >= os.time() then return true end
        end
    end
    return false
end

----------- Anti AFK
function workwithoutpause(bool)	
	if bool then
		memory.setuint8(7634870, 1, false)
		memory.setuint8(7635034, 1, false)
		memory.fill(7623723, 144, 8, false)
		memory.fill(5499528, 144, 6, false)
	else
		memory.setuint8(7634870, 0, false)
		memory.setuint8(7635034, 0, false)
		memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
		memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
	end
end

----------- Check array
function has_value (ustab, usval)
    for _, value in ipairs(ustab) do
        if value == usval then
            return true
        end
    end

    return false
end

----------- Вылет с сервера
function sendEmptyPacket(id)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt8(bs, id)
	raknetSendBitStream(bs)
	raknetDeleteBitStream(bs)
end

function closeConnect()
	local bs = raknetNewBitStream()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, bs)
	raknetDeleteBitStream(bs)
end

---------- Autoupdate
function autoupdate(infourl, downloadurl, prefix, downloadpath)
    updateinicheck = downloadUrlToFile(infourl, downloadpath,
        function (id, status)
            sampAddChatMessage(tag .. 'Проверяю наличие обновлений', 4290744085)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA and updateinicheck == id then
                updateIni = inicfg.save(nil, downloadpath)
                if tonumber(updateIni.info.vers) > script_version then
                    lua_thread.create(function (prefix)
                        sampAddChatMessage(tag .. 'Есть обновление. Текующая версия скрипта: '..script_versiontext..'. Новая: '..updateIni.info.verstext, 4290744085)
                        sampAddChatMessage(tag .. 'Обновляюсь..', 4290744085)
                        wait(200)
                        updatefiledownload = downloadUrlToFile(downloadurl, downloadpath, function(id2,status2)
                            if status2 == dlstatus.STATUS_ENDDOWNLOADDATA and updatefiledownload == id2 then
                                sampAddChatMessage(tag .. 'Обновление прошло успешно. Перезагружаюсь..', 4290744085)
                                ifupdatesuccess = true
                                lua_thread.create(function() wait(500) thisScript():reload() end)
                            end
                            if status2 == dlstatus.STATUS_ENDDOWNLOAD and updatefiledownload == id2 then
                                if ifupdatesuccess == nil then
                                    sampAddChatMessage(tag .. 'Упс! Что-то пошло не так! Запускаю старую версию.', 4290744085)
                                    sampAddChatMessage(tag .. 'Просьба написать в личные сообщения группы с хештэгом "#ошибка"!', 4290744085)
                                    update = false
                                end
                            end
                        end)
                    end, prefix)
                else
                    update = false
                    sampAddChatMessage(tag .. 'Обновление не требуется.')
                end
            else
                sampAddChatMessage(tag .. 'Не получилось проверить на обновление. Возможно, что-то мешает скрипту.', 4290744085)
                sampAddChatMessage(tag .. 'Если у вас есть !0AntiStealerByDarkP1xel32.ASI то удалите его и попробуйте снова.', 4290744085)
                update = false
            end
        end
    )
end