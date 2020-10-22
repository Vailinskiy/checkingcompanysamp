script_name('Company Helper')
script_author("kreyN")
script_version("1.0")
if not getMoonloaderVersion then
    return print("This script requires MoonLoader to be installed")
end

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
        FirstStorageAmountProds = 0,
        SecondStorageAmountProds = 0,
        MinimalAmountToAccept = 0,
        MinimalPriceToAccept = 0,
        AcceptedNumber = 0,
        AcceptedDeliveries = 0,
        AcceptedProduct = 0,
        MoneyFromSells = 0,
        MoneyFromDeliveries = 0,
        DisAnyNotfChat = false,
        NotfAboutAnsVK = false,
        NotfAboutMovingVK = false,
        NotfAboutLostConnection = false,
        NotfAboutAcceptingEx1VK = false,
        NotfAboutAcceptingEx2VK = false,
        NotfAboutDefaultChat = false,
        NotfAboutOutOfProd = false,
        IgnorePrice = 5.00,
        PPose = false,
        AntiAFKBoolean = false,
        AutoUpdate = true,
        PlayerVKID = 0,
        RestartStatusIni = 0,
        Debug = false
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
local restartstatus = mainIni.config.RestartStatusIni
local script_version = 1
local script_versiontext = '1.0'
local uppath = thisScript().path
local upinfourl = "https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/scrptvers.ini"
local updownloadurl = ""
local autoupdatebool = imgui.ImBool(mainIni.config.AutoUpdate)
local site = "https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/somename"
local disableanynotfbool = imgui.ImBool(mainIni.config.DisAnyNotfChat)
local notfanssound = loadAudioStream('https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/notfhint.wav')
local notfanssoundprnk = loadAudioStream('https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/prnknotf.mp3') 
local hellonoviigod = loadAudioStream('https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/noviigod.mp3')
local NotfAboutAcceptingInCompanyChat = imgui.ImBool(mainIni.config.NotfAboutAcceptingInCC)
local NotfAns = imgui.ImBool(mainIni.config.NotfAboutAns)
local NotfAnsVK = imgui.ImBool(mainIni.config.NotfAboutAnsVK)
local NotfMoveVK = imgui.ImBool(mainIni.config.NotfAboutMovingVK)
local notfacceptex1vk = imgui.ImBool(mainIni.config.NotfAboutAcceptingEx1VK)
local notfacceptex2vk = imgui.ImBool(mainIni.config.NotfAboutAcceptingEx2VK)
local notfoutofprod = imgui.ImBool(mainIni.config.NotfAboutOutOfProd)
local notfdefchat = imgui.ImBool(mainIni.config.NotfAboutDefaultChat)
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
local fnumberofstorageprods = mainIni.config.FirstStorageAmountProds
local snumberofstorageprods = mainIni.config.SecondStorageAmountProds
local amountofacceptedorders = imgui.ImInt(mainIni.config.AcceptedNumber)
local amountofaccepteddeliveries = imgui.ImInt(mainIni.config.AcceptedDeliveries)
local amountofmoneyfromsells = imgui.ImFloat(mainIni.config.MoneyFromSells)
local amountofmoneyfromdeliveries = imgui.ImFloat(mainIni.config.MoneyFromDeliveries)
local amountofacceptedproduct = imgui.ImInt(mainIni.config.AcceptedProduct)
local screnabled = imgui.ImBool(false)
local catchingex2 = imgui.ImBool(false)
local dlpointls = imgui.ImBool(mainIni.config.ifDeliveryToLS)
local dlpointsf = imgui.ImBool(mainIni.config.ifDeliveryToSF)
local dlpointlv = imgui.ImBool(mainIni.config.ifDeliveryToLV)
local prod_slad1 = u8:decode(mainIni.config.ProductTypeToDeliveryFirst)
local prod_slad2 = u8:decode(mainIni.config.ProductTypeToDeliverySecond)
local prod_slad3 = u8:decode(mainIni.config.ProductTypeToDeliveryThird)
local prod_slad4 = u8:decode(mainIni.config.ProductTypeToDeliveryFourth)
local min_zakaz = imgui.ImInt(mainIni.config.MinimalAmountToAccept)
local min_price = imgui.ImFloat(mainIni.config.MinimalPriceToAccept)
local ignorepricefloat = imgui.ImFloat(mainIni.config.IgnorePrice) 
local menunum = 0
local xyz = 0
local tag = " {bf8f15}CHelper {ffffff}• "
local checkingstorage1 = false
local checkingstorage2 = false
local tmpvar1 = false
local tmpvar2 = false
local tempstring1 = ''
local tempstring2 = ''

local numEx1, kudaEx1, tovarEx1, kolvoEx1, priceEx1, dostavkaEx1 = 0, '', '', 0, 0, 0
local numEx2, numskladEx2, deliverypointEx2, prdtypeEx2, amountEx2, priceEx2 = 0, 0, '', '', 0, 0
local aam = 0

local goorderprods1, goorderprods2 = false, false

local debugmode = imgui.ImBool(mainIni.config.Debug)

local niceblue = 4282550261
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
    'Порт Los Santos',
    'Больница Los Santos',
    'СТО Los Santos',
    'Байкерский клуб Hells Angels',
    'Здание Суда',
    'Business Center',
    'Администрация Президента',
    'Concert Hall',
    'Jefferson Hotel',
    'Trump Hotel'
}
local dlendpointssf = {
    'Police Department SF',
    'Аэропорт San Fierro',
    'Порт San Fierro',
    'Больница San Fierro',
    'СТО San Fierro',
    'Порт Bayside',
    'Железнодорожный завод',
    'База ВМФ',
    'Байкерский клуб Bandidos',
    'Администрация Президента'
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
    'El Quabrados Hotel',
    'Emerald Isle Motel',
    'Pirates Hotel',
    'Шахта'
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
                                sendvknotf('Суммарно заработанная сумма с помощью бота(продажа+доставка): ' .. mainIni.config.MoneyFromSells + mainIni.config.MoneyFromDeliveries)
                                return
							elseif pl.button == 'commands' then
                                sendvknotf('Доступные команды:\n—» !sc [ваше сообщение] - отправить сообщение в чат игры\n—» !quit - экстренное прерывание пакетов данных(т.е. отключение от сервера). Данный способ беспалевный, т.к. в этом случае вы "вылетаете" с сервера с ошибкой.\n—» !stats - Выводит общую информацию из окна "Статистика"\n—» !checkprods1 - Выводит информацию о состоянии первого склада на текущий момент.(аналогично с !checkprods2)\n—» !order1 [тип] [откуда] [сколько] [по какой цене] - заказать продукты для первого склада\n—»!order2 [тип] [откуда] [сколько] [по какой цене] - заказать продукты для второго склада\n—» !restart - Перезапуск скрипта')
                                return
                            elseif pl.button == 'status' then
                                sendvknotf('—» Количество принятых заказов: ' .. amountofacceptedorders.v .. '\n—» Количество принятых доставок: '..amountofaccepteddeliveries.v..'\n—» Заработанная сумма с продажи товаров со склада: '.. amountofmoneyfromsells.v)
                            elseif pl.button == 'refresh' then
                                sendvknotf('Данные были обновлены.')
                            end
						end
					end
                    local objsend = tblfromstr(v.object.text)
                    if objsend[1] == '!sc' then
                        local args = table.concat(objsend, " ", 2, #objsend) 
                        if #args > 0 then
                            args = u8:decode(args)
                            sampSendChat(args)
                            sendvknotf('Сообщение "' .. args .. '" было успешно отправлено в игру')
                        else
                            sendvknotf('Неправильный аргумент! Пример: !sc [строка]')
                        end
                    elseif objsend[1] == '!quit' then
                        sendEmptyPacket(PACKET_CONNECTION_LOST)
                        closeConnect()
                        sendvknotf('Успешно разорвано соединение с сервером.')
                    elseif objsend[1] == '!stats' then
                        sendvknotf('Статистика\n\n—» Количество пойманных заказов с помощью скрипта: '.. amountofacceptedorders.v..'\n—» Кол-во принятого товара: ' .. amountofacceptedproduct.v .. '\n—» Цена проданного товара: ' .. amountofmoneyfromsells.v)
                    elseif objsend[1] == '!checkprods1' then
                        if fnumberofstorage.v ~= nil and fnumberofstorage.v ~= 0 then
                            checkingstorage1 = true
                            sampSendChat("/company")
                        else
                            sendvknotf("Вы не ввели номер Вашего первого склада!")
                        end
                    elseif objsend[1] == '!checkprods2' then
                        if snumberofstorage.v ~= nil and snumberofstorage.v ~= 0 then
                            checkingstorage2 = true
                            sampSendChat("/company")
                        else
                            sendvknotf("Вы не ввели номер Вашего второго склада!")
                        end
                    elseif objsend[1] == '!order1' then
                        local args = table.concat(objsend, " ", 2, #objsend)
                        if #args > 0 then
                            if #objsend >= 7 and #objsend <= 10 then
                                if args:find('%S+ - .* %d+ .*') then
                                    ttp, dp, am, pr = args:match('(%S+) %- (.*) (%d+) (.*)')
                                    ttp = u8:decode(ttp)
                                    dp = u8:decode(dp)
                                    am = u8:decode(am)
                                    pr = u8:decode(pr)
                                    if not tonumber(ttp) and not tonumber(dp) and tonumber(am) and tonumber(pr) then
                                        sendvknotf('Тип товара: '..ttp..'\nОткуда: '..dp..'\nСколько: '..am..'\nПо какой цене: '..pr)
                                        sampSendChat('/company')
                                        goorderprods1 = true
                                    else
                                        sendvknotf('Вы неправильно ввели аргументы. Пример:\n!order1 Оружие - Аэропорт Las Venturas 120000 0.3\n!order1 [тип] [откуда] [сколько] [по какой цене]')
                                    end
                                else
                                    sendvknotf('Вы неправильно ввели аргументы. Внимательно посмотрите на шаблон.')
                                end
                            else
                                sendvknotf('Оу. Введено неверное количество аргументов.')
                            end
                        else
                            sendvknotf('Введите аргументы! Пример: !order1 Оружие - Аэропорт Las Venturas 120000 0.3')
                        end
                    elseif objsend[1] == '!order2' then
                        local args = table.concat(objsend, " ", 2, #objsend)
                        if #args > 0 then
                            if #objsend >= 7 and #objsend <= 10 then
                                if args:find('%S+ - .* %d+ .*') then
                                    ttp2, dp2, am2, pr2 = args:match('(%S+) %- (.*) (%d+) (.*)')
                                    ttp2 = u8:decode(ttp2)
                                    dp2 = u8:decode(dp2)
                                    am2 = u8:decode(am2)
                                    pr2 = u8:decode(pr2)
                                    if not tonumber(ttp2) and not tonumber(dp2) and tonumber(am2) and tonumber(pr2) then
                                        sendvknotf('Тип товара: '..ttp2..'\nОткуда: '..dp2..'\nСколько: '..am2..'\nПо какой цене: '..pr2)
                                        sampSendChat('/company')
                                        goorderprods2 = true
                                    else
                                        sendvknotf('Вы неправильно ввели аргументы. Пример:\n!order2 Оружие - Аэропорт Las Venturas 120000 0.3\n!order2 [тип] [откуда] [сколько] [по какой цене]')
                                    end
                                else
                                    sendvknotf('Вы неправильно ввели аргументы. Внимательно посмотрите на шаблон.')
                                end
                            else
                                sendvknotf('Оу. Введено неверное количество аргументов.')
                            end
                        else
                            sendvknotf('Введите аргументы! Пример: !order2 Оружие - Аэропорт Las Venturas 120000 0.3')
                        end
                    elseif objsend[1] == '!restart' then
                        sendvknotf('Перезапускаюсь..')
                        restartstatus = 1
                        mainIni.config.RestartStatusIni = restartstatus
                        inicfg.save(mainIni, directIni)
                        thisScript():reload()
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
    keyboard.buttons[3] = {}
    local row = keyboard.buttons[1]
    local row2 = keyboard.buttons[2]
    local row3 = keyboard.buttons[3]
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
    row3[1] = {}
    row3[1].action = {}
	row3[1].color = 'positive'
	row3[1].action.type = 'text'
	row3[1].action.payload = '{"button": "refresh"}'
    row3[1].action.label = 'Обновить данные'
	return encodeJson(keyboard)
end


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
            if not disableanynotfbool.v then
                sampAddChatMessage(tag .. "Купите сначала ключ, затем используйте.", 4290744085)
                sampAddChatMessage(tag .. "После добавления вас в список, перезапустите игру, чтобы все заработало.", 4290744085)
            end
            thisScript():unload()
        else
            if not disableanynotfbool.v then
                sampAddChatMessage(tag .. "Вы находитесь в списке. Приятного заработка.", 4290744085)
            end
        end
        if autoupdatebool.v then
            autoupdate('https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/updatecheck.json', '##nil', 'https://raw.githubusercontent.com/Vailinskiy/checkingcompanysamp/main/updatecheck.json')
        end
        if restartstatus == 1 then
            sendvknotf('Скрипт успешно перезапущен!')
            restartstatus = 0
            mainIni.config.RestartStatusIni = restartstatus
            inicfg.save(mainIni, directIni)
        end
    --------
        wait(100)
            sampRegisterChatCommand("ch", cmd_ch)
            sampRegisterChatCommand("test", cmd_test)
        imgui.SwitchContext()
        SwitchColorTheme(mainIni.config.themenumber)
        workwithoutpause(mainIni.config.AntiAFKBoolean)
        lua_thread.create(vkget)
        local day = os.date("%d")
        local month = os.date("%m")
        if tonumber(day) == 31 and tonumber(month) == 12 or tonumber(day) == 30 and tonumber(month) == 12 then
            setAudioStreamState(hellonoviigod, 1)
            setAudioStreamVolume(hellonoviigod, 15)
        end
    while true do
        wait(0)
        px, py, pz = getCharCoordinates(PLAYER_PED)
        resid, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        pping = sampGetPlayerPing(id)
        -- IMGUI
        imgui.Process = main_window_state.v

        if isKeyJustPressed(VK_G) and sampIsDialogActive() then
            local did = sampGetCurrentDialogId()
            sampAddChatMessage(did, -1)
        end
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
function cmd_test()
    goorderprods1 = true
    sampSendChat('/company')
end


------ Как откроется диалог, то..
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 1240 then
        if checkingstorage1 or checkingstorage2 then
            sampSendDialogResponse(1240, 1, 1, -1)
            if checkingstorage1 then
                tmpvar1 = true
            end
            if checkingstorage2 then
                tmpvar2 = true
            end
            checkingstorage1 = false
            checkingstorage2 = false
        end
        if screnabled.v and main_window_state then
            lua_thread.create(function()
                wait(1)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
    end
    if dialogId == 1241 then
        if tmpvar1 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{E3FFCC}%d%.{FFFFFF} Склад") then
                    local num, numbb = line:match("%{E3FFCC%}(%d+)%.%{FFFFFF%} Склад №(%d+) %[.*%]")
                    if tonumber(numbb) == fnumberofstorage.v then
                        sampSendDialogResponse(1241, 1, num-1, -1)
                    elseif tonumber(numbb) ~= fnumberofstorage.v then
                        sendvknotf("Что-то пошло не так. Проверьте правильность введенного номер 1 склада.")
                    end
                end
            end
            sampSendDialogResponse(1241, 0, 0, -1)
            lua_thread.create(function()
                wait(pping+15)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        if tmpvar2 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{E3FFCC}%d%.{FFFFFF} Склад") then
                    local num, numbb = line:match("%{E3FFCC%}(%d+)%.%{FFFFFF%} Склад №(%d+) %[.*%]")
                    if tonumber(numbb) == snumberofstorage.v then
                        sampSendDialogResponse(1241, 1, num-1, -1)
                    else
                        sendvknotf("Что-то пошло не так. Проверьте правильность введенного номера 2 склада.")
                    end
                end
            end
            sampSendDialogResponse(1241, 0, 0, -1)
            lua_thread.create(function()
                wait(pping+15)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
    end
    if dialogId == 1257 and tmpvar1 or tmpvar2 then
        sampSendDialogResponse(1257, 1, 1, -1)
    end



    if dialogId == 1264 then
        if tmpvar1 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("Состояние склада:	Доступно: {D7D8FB}.*{FFFFFF}%s+Ожидает доставки: {D7D8FB}.*{FFFFFF}	Всего: {D7D8FB}.*/.*") then
                    local aviableprod, waiting4del, all1, all2 = line:match("Состояние склада:%s+Доступно: %{D7D8FB%}(%d+)%{FFFFFF%}%s+Ожидает доставки: %{D7D8FB%}(%d+)%{FFFFFF%}%s+Всего: %{D7D8FB%}(%d+)/(%d+)")
                    fnumberofstorageprods = "Доступное количество продуктов: "..aviableprod.." | В ожидании доставки на склад: "..waiting4del..' | Всего: '..all1.."/"..all2
                end
            end
            if fnumberofstorageprods ~= nil and fnumberofstorageprods ~= 0 then
                sendvknotf('Состояние склада №'..fnumberofstorage.v..':\n\n'..fnumberofstorageprods)
            else
                sendvknotf('Что-то пошло не так. Возможно, неверно введен номер 1 склада')
            end
        end
        if tmpvar2 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("Состояние склада:	Доступно: {D7D8FB}.*{FFFFFF}%s+Ожидает доставки: {D7D8FB}.*{FFFFFF}	Всего: {D7D8FB}.*/.*") then
                    local aviableprod, waiting4del, all1, all2 = line:match("Состояние склада:%s+Доступно: %{D7D8FB%}(%d+)%{FFFFFF%}%s+Ожидает доставки: %{D7D8FB%}(%d+)%{FFFFFF%}%s+Всего: %{D7D8FB%}(%d+)/(%d+)")
                    snumberofstorageprods = "Доступное количество продуктов: "..aviableprod.." | В ожидании доставки на склад: "..waiting4del..' | Всего: '..all1.."/"..all2
                end
            end
            if snumberofstorageprods ~= nil and snumberofstorageprods ~= 0 then
                sendvknotf('Состояние склада №'..snumberofstorage.v..':\n\n'..snumberofstorageprods)
            else
                sendvknotf('Что-то пошло не так. Возможно, неверно введен номер 2 склада')
            end
        end
        if tmpvar1 or tmpvar2 then
            sampSendDialogResponse(1241, 0, 0, -1)
            lua_thread.create(function()
                wait(pping+15)
                sampCloseCurrentDialogWithButton(0)
            end)
            tmpvar1 = false
            tmpvar2 = false
        end
    end



    if dialogId == 1214 then -- /company main window
        if screnabled.v and main_window_state then
            lua_thread.create(function()
                wait(1)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        if goorderprods1 then
            sampSendDialogResponse(1214, 1, 1, -1)
        end
        if goorderprods2 then
            sampSendDialogResponse(1214, 1, 1, -1)
        end
    end
    if dialogId == 1215 then -- Собственность компании
        if goorderprods1 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{E3FFCC}%d+%.{FFFFFF}") then
                    local num, type, numtype = line:match("{E3FFCC}(%d+).{FFFFFF} (%S+) №(%d+) %[.*%]")
                    if type == "Склад" then
                        if tonumber(numtype) == fnumberofstorage.v then
                            sampSendDialogResponse(1215, 1, num-1, -1)
                        end
                    end
                end
            end
        end
        if goorderprods2 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{E3FFCC}%d+%.{FFFFFF}") then
                    local num, type, numtype = line:match("{E3FFCC}(%d+).{FFFFFF} (%S+) №(%d+) %[.*%]")
                    if type == "Склад" then
                        if tonumber(numtype) == snumberofstorage.v then
                            sampSendDialogResponse(1215, 1, num-1, -1)
                        end
                    end
                end
            end
        end
    end
    if dialogId == 1231 then -- Управление складом
        if goorderprods1 then
            sampSendDialogResponse(1231, 1, 1, -1)
        end
        if goorderprods2 then
            sampSendDialogResponse(1231, 1, 1, -1)
        end
    end
    if dialogId == 1238 then -- Дилаог с информацией о заполненности склада / сделать заказ
        if goorderprods1 then
            for line in text:gmatch("[^\r\n]+") do -- Состояние склада:	Доступно: {D7D8FB}119100{FFFFFF}	Ожидает доставки: {D7D8FB}900{FFFFFF}	Всего: {D7D8FB}120000/120000
                if line:find("Состояние склада:") then
                    local aviable, wait4del, allinall1, allinall2 = line:match("Состояние склада:%s+Доступно:%s+{D7D8FB}(%d+){FFFFFF}%s+Ожидает доставки:%s+{D7D8FB}(%d+){FFFFFF}%s+Всего:%s+{D7D8FB}(%d+)/(%d+)")
                    needtoorder = allinall2-allinall1
                    if debugmode.v then
                        print("Сколько нужно заказать: "..needtoorder)
                    end
                    sampSendDialogResponse(1238, 1, 1, -1)
                end
            end
        end
        if goorderprods2 then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("Состояние склада:") then
                    local aviable, wait4del, allinall1, allinall2 = line:match("Состояние склада:%s+Доступно:%s+{D7D8FB}(%d+){FFFFFF}%s+Ожидает доставки:%s+{D7D8FB}(%d+){FFFFFF}%s+Всего:%s+{D7D8FB}(%d+)/(%d+)")
                    needtoorder2 = allinall2-allinall1
                    if debugmode.v then
                        print("Сколько нужно заказать: "..needtoorder2)
                    end
                    sampSendDialogResponse(1238, 1, 1, -1)
                end
            end
        end
    end
    if dialogId == 1251 then -- Диалог выбора типа товара для заказа
        if goorderprods1 then
            local ifwassend = false
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d.{FFFFFF}") then
                    local num, tovp = line:match("{FFDF80}(%d+).{FFFFFF}%s+(.*)%s+%d")
                    if tovp == ttp and goorderprods1 then
                        ifwassend = true
                        sampSendDialogResponse(1251, 1, num, -1)
                    elseif not ifwassend then
                            sampAddChatMessage("Не найдено. Проверьте правильность написания типа товара.", niceblue)
                    end
                end
            end
            ifwassend = false
        end
        if goorderprods2 then
            local ifwassend = false
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d.{FFFFFF}") then
                    local num, tovp = line:match("{FFDF80}(%d+).{FFFFFF}%s+(.*)%s+%d")
                    if tovp == ttp2 and goorderprods2 then
                        ifwassend = true
                        sampSendDialogResponse(1251, 1, num, -1)
                    elseif not ifwassend then
                            sampAddChatMessage("Не найдено. Проверьте правильность написания типа товара.", niceblue)
                    end
                end
            end
            ifwassend = false
        end
    end
    if dialogId == 1250 then -- Выбор точки отправки
        if goorderprods1 then
            local ifwassend2 = true
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d.{FFFFFF}") then
                    local num, where = line:match("{FFDF80}(%d).{FFFFFF} (.*)")
                    num = tonumber(num)
                    if where == dp then
                        sampSendDialogResponse(1250, 1, num-1, -1)
                        ifwassend2 = false
                    elseif not ifwassend2 then
                            sampAddChatMessage("Не найдено.",niceblue)
                            goorderprods1 = false
                    end
                end
            end
            ifwassend2 = true
        end
        if goorderprods2 then
            local ifwassend2 = true
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d.{FFFFFF}") then
                    local num, where = line:match("{FFDF80}(%d).{FFFFFF} (.*)")
                    num = tonumber(num)
                    if where == dp2 then
                        sampSendDialogResponse(1250, 1, num-1, -1)
                        sampAddChatMessage("hei", niceblue)
                        ifwassend2 = false
                    elseif not ifwassend2 then
                            sampAddChatMessage("Не найдено.",niceblue)
                            goorderprods2 = false
                    end
                end
            end
            ifwassend2 = true
        end
    end
    if dialogId == 1252 then -- Количество товара
        if goorderprods1 then
            sampSendDialogResponse(1252, 1, -1, am)
        end
        if goorderprods2 then
            sampSendDialogResponse(1252, 1, -1, am2)
        end
    end
    if dialogId == 1253 then -- Цена за 1 единицу
        if goorderprods1 then
            sampSendDialogResponse(1253, 1, -1, pr)
        end
        if goorderprods2 then
            sampSendDialogResponse(1253, 1, -1, pr2)
        end
    end
    if dialogId == 1254 then
        if goorderprods1 then
            sampSendDialogResponse(1254, 1, -1, _)
            sendvknotf('Заказ успешно отправлен. Скрипт заказал '..needtoorder..' единиц продуктов. Затрачено было денег: '..needtoorder*pr..'$.')
            goorderprods1 = false
            return false
        end
        if goorderprods2 then
            sampSendDialogResponse(1254, 1, -1, _)
            goorderprods2 = false
            sendvknotf('Заказ успешно отправлен. Скрипт заказал '..needtoorder2..' единиц продуктов. Затрачено было денег: '..needtoorder2*pr2..'$.')
            return false
        end
    end
    if dialogId == 1241 and screnabled.v then
            for line in text:gmatch("[^\r\n]+") do
                if line:find("{FFDF80}%d+%.{FFFFFF}") then --                    {FFDF80}(%d+).{FFFFFF}%s+(.*)%s+(.*)%s+(%d+)%s+%-%s+%$(.*)%s+%$(.*)
                    local num, kuda, tovar, kolvo, price, dostavka = line:match("{FFDF80}(%d+).{FFFFFF}%s+(.*)%s+(.*)%s+(%d+)%s+%-%s+%$(.*)%s+%$(.*)")
                    if tonumber(dostavka) >= tonumber(min_price.v) then
                        if dlpointls.v or tonumber(dostavka) >= tonumber(mainIni.config.IgnorePrice) then
                            if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) and has_value(dlendpointsls, kuda) then
                                if has_value(dlendpointsls, kuda) then
                                    sampSendDialogResponse(1241, 1, num-1, -1)
                                    kolvoEx1 = tonumber(kolvo)
                                    kudaEx1 = kuda
                                    priceEx1 = tonumber(price)
                                    tovarEx1 = tovar
                                    dostavkaEx1 = tonumber(dostavka)
                                    tempstring1 = kudaEx1.." - "..tovarEx1.." - "..kolvoEx1.." - "..priceEx1
                                    if debugmode.v then
                                        if tempstring1 ~= nil then
                                            print(tempstring1)
                                            sampAddChatMessage(tempstring1, -1)
                                        else
                                            print('Tempstring1 is null.')
                                            sampAddChatMessage('Tempstring1 is null.', -1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if tonumber(dostavka) >= tonumber(min_price.v) then
                        if dlpointsf.v or tonumber(dostavka) >= tonumber(mainIni.config.IgnorePrice) then
                            if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) and has_value(dlendpointssf, kuda) then
                                if has_value(dlendpointssf, kuda)  then 
                                    sampSendDialogResponse(1241, 1, num-1, -1)
                                    kolvoEx1 = tonumber(kolvo)
                                    kudaEx1 = kuda
                                    priceEx1 = tonumber(price)
                                    tovarEx1 = tovar
                                    dostavkaEx1 = tonumber(dostavka)
                                    tempstring1 = kudaEx1.." - "..tovarEx1.." - "..kolvoEx1.." - "..priceEx1
                                    if debugmode.v then
                                        if tempstring1 ~= nil then
                                            print(tempstring1)
                                            sampAddChatMessage(tempstring1, -1)
                                        else
                                            print('Tempstring1 is null.')
                                            sampAddChatMessage('Tempstring1 is null.', -1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if tonumber(dostavka) >= tonumber(min_price.v) then
                        if dlpointlv.v or tonumber(dostavka) >= tonumber(mainIni.config.IgnorePrice) then
                            if (tovar == prod_slad1 or tovar == prod_slad2 or tovar == prod_slad3 or tovar == prod_slad4) and (tonumber(kolvo) >= min_zakaz.v) and has_value(dlendpointslv, kuda) then
                                if has_value(dlendpointslv, kuda) then
                                    sampSendDialogResponse(1241, 1, num-1, -1)
                                    kolvoEx1 = tonumber(kolvo)
                                    kudaEx1 = kuda
                                    priceEx1 = tonumber(price)
                                    tovarEx1 = tovar
                                    dostavkaEx1 = tonumber(dostavka)
                                    tempstring1 = kudaEx1.." - "..tovarEx1.." - "..kolvoEx1.." - "..priceEx1
                                    if debugmode.v then
                                        if tempstring1 ~= nil then
                                            print(tempstring1)
                                            sampAddChatMessage(tempstring1, -1)
                                        else
                                            print('Tempstring1 is null.')
                                            sampAddChatMessage('Tempstring1 is null.', -1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif line:find("Далее") then
                    sampSendDialogResponse(1241, 1, 52, -1)
                    lua_thread.create(function()
                        wait(pping+5)
                        sampCloseCurrentDialogWithButton(0)
                    end)
                end
            end
            lua_thread.create(function()
                wait(pping+5)
                sampCloseCurrentDialogWithButton(0)
            end)
    end
    if dialogId == 1242 and screnabled.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1243 and screnabled.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1244 and catchingex2.v then -- /exchange2 dialog
        for line in text:gmatch("[^\r\n]+") do
            if line:find("%{FFDF80%}(%d+)%.%{FFFFFF%}") then
                local num, numsklad, deliverypoint, prdtype, amount, price = text:match('%{FFDF80%}(%d+)%.%{FFFFFF%}%s+Перевозка товаров%s+%[Склад №(.+) %- (.*)%]%s+(.*)%s+(%d+)%s+%$(.*)')
                if debugmode.v then
                    if num ~= nil and numsklad ~= nil and deliverypoint ~= nil and prdtype ~= nil and amount ~= nil and price then
                        print(num)
                        print(numsklad)
                        print(deliverypoint)
                        print(prdtype)
                        print(amount)
                        print(price)
                    else
                        print('smth is nil value')
                    end
                end
                if tonumber(numsklad) == fnumberofstorage.v or tonumber(numsklad) == snumberofstorage.v then
                    sampSendDialogResponse(1244, 1, num-1, -1)
                    if debugmode.v then
                        print('successful condition numsklad == f/s numberofstorage.v')
                    end
                end
                numEx2 = tonumber(num)
                numskladEx2 = tonumber(numsklad)
                deliverypointEx2 = deliverypoint
                prdtypeEx2 = prdtype
                amountEx2 = tonumber(amount)
                priceEx2 = tonumber(price)
                tempstring2 = deliverypointEx2.." - "..prdtypeEx2.." - "..amountEx2.." - "..priceEx2
                if debugmode.v then
                    if tempstring2 ~= nil then
                        print(tempstring2)
                    else
                        print('Tempstring2 is null.')
                    end
                end
            end
        end
    end
    if dialogId == 1245 and catchingex2.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
    if dialogId == 1246 and catchingex2.v then
        lua_thread.create(function()
            wait(1)
            sampCloseCurrentDialogWithButton(1)
        end)
    end
end


------ Как в чате появится строка, то..
function sampev.onServerMessage(color, text)
    if color == -6732289 and NotfAns.v then
        local day = os.date("%d")
        local month = os.date("%m")
        if tonumber(day) == 1 and tonumber(month) == 4 then
            setAudioStreamState(notfanssoundprnk, 1)
            setAudioStreamVolume(notfanssoundprnk, 25)
        else
            setAudioStreamState(notfanssound, 1)
            setAudioStreamVolume(notfanssound, 100)
        end
    end
    if color == -6732289 and NotfAnsVK.v then
        sendvknotf("Сообщение от администратора:\n" .. text)
    end
    if not isPauseMenuActive() and catchingex2.v then
        if text:find("Вы забронировали товар для продажи. Ожидайте принятия службы доставки в течение 30 минут") then
            sampAddChatMessage("• {00CC00}[Успешно] {ffffff}Вы забронировали товар для продажи. Ожидайте принятия службы доставки в течение 30 минут", -1)
            sampSendChat('/exchange2')
        end
    end
    if text:find("Вы приняли заказ на доставку товара. Теперь он доступен сотрудникам стоянки компании") then
        if debugmode.v then
            if tempstring2 ~= nil then
            print(tempstring2)
            print(amountEx2)
            print(priceEx2)
            end
        end
            if notfacceptex2vk.v then
                if tempstring2~=nil then
                    sendvknotf('Новый заказ /exchange2!\n'..tempstring2)
                end
            end
            if NotfAboutAcceptingInCompanyChat.v then
                if tempstring2 ~= nil then
                    if debugmode.v then
                        print(tempstring2)
                    end
                    sampSendChat("/cm Взял заказ. Информация: " .. tempstring2..'$.')
                end
            end
        amountofaccepteddeliveries.v = amountofaccepteddeliveries.v+tonumber(amountEx2)
        mainIni.config.AcceptedDeliveries = amountofaccepteddeliveries.v
        amountofmoneyfromdeliveries.v = amountofmoneyfromdeliveries.v+tonumber(priceEx2)*tonumber(amountEx2)
        mainIni.config.MoneyFromDeliveries = amountofmoneyfromdeliveries.v
        table.insert(mainIni.acceptedlog, tempstring2)
        inicfg.save(mainIni, directIni)
    end
    if not isPauseMenuActive() and screnabled.v then
        if text:find("2 новых заказов на бирже продажи товара. Введите /company для просмотра") then
            sampAddChatMessage("• {FFC800}[Подсказка] {ffffff}2 новых заказов на бирже продажи товара. Введите /company для просмотра", -1)
            if sampIsDialogActive() == false then
                sampSendChat("/exchange1")
            elseif dialogId ~= 1267 then
                lua_thread.create(function()
                    wait(1)
                    sampCloseCurrentDialogWithButton(0)
                    wait(pping+5)
                    sampCloseCurrentDialogWithButton(0)
                    sampSendChat("/exchange1")
                end)
            end
        end
    end
    if text:find("Вы забронировали товар для продажи. Ожидайте принятия службы доставки в течение 30 минут") then
        if notfacceptex1vk.v then
            sendvknotf('Новый заказ /exchange1!\n'..tempstring1)
        end
        if screnabled.v then
            amountofacceptedorders.v = amountofacceptedorders.v+1
            amountofacceptedproduct.v = tonumber(kolvoEx1)+amountofacceptedproduct.v
            mainIni.config.AcceptedNumber = amountofacceptedorders.v
            mainIni.config.MoneyFromSells = tonumber(priceEx1)*tonumber(kolvoEx1) + amountofmoneyfromsells.v
            mainIni.config.AcceptedProduct = amountofacceptedproduct.v
            table.insert(mainIni.acceptedlog, tempstring1)
            inicfg.save(mainIni, directIni)
        end
    end
    if notfoutofprod.v then
        if text:find("На Ваших складах недостаточно товара для этого заказа") then
            sendvknotf("Ахтунг!\nЗакончились продукты на складе!")
        end
    end
    if notfdefchat.v then
        if text:find("- .*%(.*%) %[.*%]") then
            local plid = text:match("- .*%(.*%) %[(%d+)%]")
            local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if tonumber(plid) ~= id then
                sendvknotf("Внимание! Новое сообщение в обычный чат!\n\n"..text)
            end
        end
        if text:find("(( .*%[.*%]: .* ))") then
            local plid = text:match("%{CCCC99%}%(%( .*%[(%d+)%]: .* %)%)")
            local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if plid ~= nil then
                if tonumber(plid) ~= id then
                    sendvknotf("Внимание! Новое сообщение в нонРП чат!\n\n"..text)
                end
            end
        end
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
        colors[clr.PopupBg]                = colors[clr.WindowBg];
        colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
        colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
        colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
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
        colors[clr.CloseButton]            = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.CloseButtonHovered]     = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
        colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
        colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
        colors[clr.ModalWindowDarkening]   = ImVec4(0.14, 0.14, 0.14, 0.60);
    elseif theme == 2 then
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
        colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.ChildWindowBg]          = colors[clr.WindowBg];
        colors[clr.PopupBg]                = colors[clr.WindowBg];
        colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
        colors[clr.FrameBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBg]                = colors[clr.WindowBg];
        colors[clr.TitleBgActive]          = colors[clr.WindowBg];
        colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53);
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00);
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00);
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00);
        colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
        colors[clr.CheckMark]              = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.SliderGrab]             = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.SliderGrabActive]       = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.Button]                 = ImVec4(0.40, 0.01, 0.55, 1.00);
        colors[clr.ButtonHovered]          = ImVec4(0.45, 0.05, 0.60, 1.00);
        colors[clr.ButtonActive]           = ImVec4(0.35, 0.01, 0.50, 1.00);
        colors[clr.Header]                 = colors[clr.Button];
        colors[clr.HeaderHovered]          = colors[clr.ButtonHovered];
        colors[clr.HeaderActive]           = colors[clr.ButtonActive];
        colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ResizeGripHovered]      = ImVec4(0.40, 0.39, 0.38, 0.16);
        colors[clr.ResizeGripActive]       = ImVec4(0.40, 0.39, 0.38, 0.39);
        colors[clr.CloseButton]            = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.CloseButtonHovered]     = ImVec4(1.00, 1.00, 1.00, 1.00);
        colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
        colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35);
        colors[clr.ModalWindowDarkening]   = ImVec4(0.19, 0.19, 0.19, 0.64);
    elseif theme == 3 then
        colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ChildWindowBg]          = colors[clr.WindowBg]
        colors[clr.PopupBg]                = colors[clr.WindowBg]
        colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10)
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00)
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
        colors[clr.Button]                 = ImVec4(0.20, 0.49, 0.34, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.25, 0.54, 0.39, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.25, 0.54, 0.39, 1.00)
        colors[clr.Header]                 = colors[clr.Button]
        colors[clr.HeaderHovered]          = colors[clr.Button]
        colors[clr.HeaderActive]           = colors[clr.Button]
        colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
        colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
        colors[clr.CloseButton]            = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.CloseButtonHovered]     = ImVec4(1.00, 1.00, 1.00, 1.00)
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
        local wsx, wsy = 900, 370
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(wsx, wsy), imgui.Cond.FirstUseEver)
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
        local button_size = imgui.ImVec2(200,30)
        local smallbutton_size = imgui.ImVec2(70, 19)
        local smallbutton_sizev2 = imgui.ImVec2(120, 19)
        imgui.Begin("Company Helper", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
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
            if imgui.Button(fa.ICON_PIE_CHART .. u8"  Статистика", button_size) then
                menunum = 0
            end
            if imgui.Button(fa.ICON_COGS .. u8"  Настройки", button_size) then
                menunum = 1
            end
            imgui.SetCursorPosY(325)
            local text1 = u8'Company Helper в ВК'
            local text2 = u8'Тема на BlastHack'
            local calc1 = imgui.CalcTextSize(text1)
            local calc2 = imgui.CalcTextSize(text2)
            imgui.SetCursorPosX(100 - calc1.x/2)
            imgui.Link('https://vk.com/companyhelper', u8('Company Helper в ВК'))
            imgui.SetCursorPosY(340)
            imgui.SetCursorPosX(100 - calc2.x/2)
            imgui.Link('https://blast.hk', u8('Тема на BlastHack'))
            imgui.EndGroup()
            imgui.SetCursorPos(imgui.ImVec2(205, 5))
            if menunum == 0 then
                imgui.BeginChild(u8"Окно статистики", imgui.ImVec2(685, 23), true)
                    imgui.Columns(3, _, true)
                    imgui.Separator()
                    imgui.SetColumnWidth(-1, 200); imgui.SetCursorPosX(7); imgui.Text(" "..fa.ICON_ROCKET .. u8"  Кол-во пойм. заказов: ".. amountofacceptedorders.v); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 250); imgui.SetCursorPosY(5); imgui.Text(" "..fa.ICON_PRODUCT_HUNT .. u8"  Кол-во принятого товара: " .. amountofacceptedproduct.v); imgui.NextColumn()
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
                        imgui.SetNextWindowSize(imgui.ImVec2(300, 300))
                        imgui.CenterText(u8"  Вы действительно хотите очистить всю статистику?  ")
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
                    imgui.SetColumnWidth(-1, 155); imgui.Text(u8"Доставка в пункт"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 155); imgui.Text(u8"Тип"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 119); imgui.Text(u8"Количество"); imgui.NextColumn()
                    imgui.SetColumnWidth(-1, 119); imgui.Text(fa.ICON_USD .. u8" Цена за ед."); imgui.NextColumn()
                    for k, v in ipairs(mainIni.acceptedlog) do
                    imgui.Separator() -- База ВВС - Оружие - 68900 - 0.8
                        local point, prdtp, amount, prce = v:match("(.*) %- (.*) %- (%d+) %- (.*)")
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
                            imgui.Text(u8('$'..prce))
                            imgui.NextColumn()
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
                        imgui.SetCursorPosX(7)
                        if imgui.Button(u8"Ловля заказов", smallbutton_sizev2) then
                            imgui.OpenPopup(u8'Ловля заказов')
                        end
                        if imgui.BeginPopupModal(u8"Ловля заказов", true, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                            imgui.Separator()
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"/exchange1", screnabled) then end
                            imgui.SameLine()
                            if imgui.Checkbox(u8"/exchange2  ", catchingex2) then end
                            imgui.SetCursorPosX(60)
                            if imgui.Button(u8"Закрыть", smallbutton_size) then
                                imgui.CloseCurrentPopup()
                            end
                        imgui.EndPopup()
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX(135)
                        if imgui.Checkbox(u8"AAFK", aafkbool) then workwithoutpause(aafkbool.v) end
                        imgui.SameLine()
                        imgui.Hint(u8"Будьте внимательны, данная функция сохраняется\nв настройках. Т.е. при заходе в следующий раз, она\nавтоматически будет включена.\n\n     !!!ВАЖНАЯ ИНФОРМАЦИЯ!!!\nСкрипт не работает, если включать другие AAFK(К\nпримеру, AAFK от MogAika)", 0.3)
                        imgui.SameLine()
                        imgui.SetCursorPosX(220)
                        if imgui.Checkbox(u8"AutoUpdate", autoupdatebool) then mainIni.config.AutoUpdate = autoupdatebool.v; inicfg.save(mainIni, directIni) end
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
                        imgui.CenterText(u8"Брать заказы из городов "); imgui.SameLine(); imgui.Hint(u8"Заказы будут браться из одного или нескольких городов", 0.3)
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
                        imgui.BeginGroup()
                            imgui.SetCursorPosX(10)
                            imgui.Text(u8"Мин. кол-во товаров"); imgui.SameLine(); imgui.Hint(u8"Минимальное количествово товаров для заказа, т.е.\nот сколько единиц брать заказы в /exchange1", 0.3)
                            imgui.SetCursorPosX(10)
                            imgui.PushItemWidth(100)
                            if imgui.InputInt("##3", min_zakaz, 0, 0) then
                                if min_zakaz.v < 0 then
                                    min_zakaz.v = 0
                                else
                                    mainIni.config.MinimalAmountToAccept = min_zakaz.v
                                    inicfg.save(mainIni, directIni)
                                end
                            end
                        imgui.EndGroup()
                        imgui.SameLine()
                        imgui.SetCursorPosX(180)
                        imgui.SetCursorPosY(47)
                        imgui.BeginGroup()
                            imgui.Text(u8"Мин. тариф доставки"); imgui.SameLine(); imgui.Hint(u8"Минимальный тариф для доставки товаров\nСтавьте его МЕНЬШЕ игнорируемой цены", 0.3)
                            imgui.SetCursorPosX(180)
                            imgui.SetCursorPosY(68)
                            imgui.PushItemWidth(100)
                            if imgui.InputFloat("##minprice", min_price, 0, 0, 2) then
                                if min_price.v < 0 then
                                    min_price.v = 0
                                elseif min_price.v > ignorepricefloat.v then
                                    min_price.v = ignorepricefloat.v
                                else
                                    mainIni.config.MinimalPriceToAccept = min_price.v
                                    inicfg.save(mainIni, directIni)
                                end
                            end
                        imgui.EndGroup()
                        imgui.Separator()
                        imgui.CenterText(u8"Цена для забора заказа"); imgui.SameLine(); imgui.Hint(u8'Цена, при которой игнорируется выбор\n"Брать заказы из других городов". Т.е. Если у\nВас стоит фильтр только на ЛВ, есть заказ\nдля ЛС и цена за его доставку равна или\nбольше, чемуказанная сумма, то заказ из ЛС\nвозьмется. Делайте на 0.01 меньше желаемого.\nПример: вы хотите, чтобы ловилось с 1.20. Значит,\nвам нужно выставить 1.19.', 0.3)
                        imgui.SetCursorPosX(10)
                        imgui.PushItemWidth(150)
                        if imgui.SliderFloat('##IngorePriceDrag', ignorepricefloat, 0.3, 2.0, '%.2f$') then
                            local gg = math_round(ignorepricefloat.v, 2)
                            mainIni.config.IgnorePrice = gg
                            inicfg.save(mainIni, directIni)
                            if ignorepricefloat.v < min_price.v then
                                min_price.v = ignorepricefloat.v
                                mainIni.config.MinimalAmountToAccept = min_zakaz.v
                                inicfg.save(mainIni, directIni)
                            end
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
                            if fnumberofstorage.v < 0 then fnumberofstorage.v = 0 elseif fnumberofstorage.v > 99 then fnumberofstorage.v = 99 elseif fnumberofstorage.v == nil then fnumberofstorage.v = 0 end
                            mainIni.config.FirstNumberOfStorage = fnumberofstorage.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        if imgui.InputInt("##2", snumberofstorage, 0, 0) then
                            if snumberofstorage.v < 0 then snumberofstorage.v = 0 elseif snumberofstorage.v > 99 then snumberofstorage.v = 99 elseif snumberofstorage.v == nil then snumberofstorage.v = 0 end
                            mainIni.config.SecondNumberOfStorage = snumberofstorage.v
                            inicfg.save(mainIni, directIni)
                        end
                        --[[imgui.SameLine()
                        if imgui.button(u8"Настройки зафулла") then
                            imgui.OpenPopup(u8"Настройки зафулла складов")
                        end
                        if imgui.BeginPopupModal(u8"Настройки зафулла складов", true, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                            imgui.Separator()
                            imgui.SetCursorPosX(7)
                            imgui.Checkbox(u8"")
                            imgui.EndPopup()
                        end]]
                        imgui.Separator()
                        imgui.CenterText(u8"Типы товаров")
                        imgui.SameLine()
                        imgui.Hint(u8"Используется при ловле заказов", 0.3)
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
                        imgui.Separator()
                        local calc = imgui.CalcTextSize('Debug mode')
                        calc.x = calc.x + 30
                        imgui.SetCursorPosX(340-calc.x)
                        imgui.Checkbox(u8'Debug mode', debugmode)
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
                        imgui.Hint(u8"Автоматически отправляет в /cm сообщение с\nинформацией о новом заказе.", 0.3)
                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Звуковое уведомление об /ans", NotfAns, 13) then
                            mainIni.config.NotfAboutAns = NotfAns.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.Hint(u8("Данное уведомление сработает при появлении вопросов\nк вам со стороны администрации."), 0.3)
                        imgui.SameLine()
                        if imgui.Button(u8"Доп. настройки", imgui.ImVec2(105,19)) then
                            imgui.OpenPopup(u8"Дополнительные настройки уведомлений")
                        end
                        if imgui.BeginPopupModal(u8"Дополнительные настройки уведомлений", true, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                            imgui.Separator()
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"Выключить любые уведомления скрипта в чат игры   ", disableanynotfbool) then mainIni.config.DisAnyNotfChat = disableanynotfbool.v; inicfg.save(mainIni, directIni) end
                            local width = imgui.GetWindowWidth()
                            imgui.SetCursorPosX(width*0.6-70)
                            if imgui.Button(u8"Закрыть") then imgui.CloseCurrentPopup() end
                            imgui.EndPopup()
                        end

                        imgui.Separator()

                        imgui.CenterText(u8"Уведомления в ВК")

                        imgui.SetCursorPosX(10)
                        if imgui.Checkbox(u8"Уведомления об /ans", NotfAnsVK, 14) then
                            mainIni.config.NotfAboutAnsVK = NotfAnsVK.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        imgui.Hint(u8("Если администратор напишет вам в /ans, то бот группы\nнапишет вам в лс в ВК. Для этого нужно указать\nID ВК вашей страницы ниже."),0.3)

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
                        imgui.SameLine(); imgui.Hint(u8('Укажите Ваш VK ID.\nГде его взять? Самый простой способ:\n  • Зайдите в "Настройки" вашего аккаунта\n  • В поле "Адрес страницы" нажмите "Изменить"\n  • Над кнопкой "Сохранить" будет текст - "Номер страницы - (цифры)"\n  • Перепишите эти цифры в поле "VK ID" '),0.3)
                        imgui.SameLine()
                        if imgui.Button(u8"Доп. настройки##1", imgui.ImVec2(120, 19)) then
                            imgui.OpenPopup(u8"Дополнительные настройки уведомлений ВКонтакте")
                        end
                        if imgui.BeginPopupModal(u8"Дополнительные настройки уведомлений ВКонтакте", true, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                            imgui.Separator()
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"Уведомление о принятии заказа в /exchange1             ", notfacceptex1vk) then
                                mainIni.config.NotfAboutAcceptingEx1VK = notfacceptex1vk.v
                                inicfg.save(mainIni, directIni)
                            end
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"Уведомление о принятии заказа в /exchange2", notfacceptex2vk) then
                                mainIni.config.NotfAboutAcceptingEx2VK = notfacceptex2vk.v
                                inicfg.save(mainIni, directIni)
                            end
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"Уведомление об окончании товаров на складе", notfoutofprod) then
                                mainIni.config.NotfAboutOutOfProd = notfoutofprod.v
                                inicfg.save(mainIni, directIni)
                            end
                            imgui.SetCursorPosX(7)
                            if imgui.Checkbox(u8"Уведомление о сообщении в обычный чат(не /ans)", notfdefchat) then
                                mainIni.config.NotfAboutDefaultChat = notfdefchat.v
                                inicfg.save(mainIni, directIni)
                            end
                            imgui.SameLine(); imgui.Hint(u8"Полезно, если администратор решил задать\nвопрос не в /ans, а через обычный чат или\nв нонРП чат /n",0.3)
                            local width = imgui.GetWindowWidth()
                            imgui.SetCursorPosX(width*0.6-70)
                            if imgui.Button(u8"Закрыть", smallbutton_size) then
                                imgui.CloseCurrentPopup()
                            end
                            imgui.EndPopup()
                        end
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

function imgui.Hint(text, delay)
    imgui.TextDisabled(fa.ICON_INFO_CIRCLE)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
            imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 12)
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.MenuBarBg])
                    imgui.BeginTooltip()
                    local p = imgui.GetCursorScreenPos()
                    imgui.SetCursorScreenPos(imgui.ImVec2(p.x + 5,p.y + 5))
                    imgui.PushTextWrapPos(400)
                    imgui.TextUnformatted(text)
                    local p = imgui.GetCursorScreenPos()
                    local obrez = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize,450,450,text).x
                    imgui.SetCursorScreenPos(imgui.ImVec2(p.x + obrez + 15,p.y + 10))
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
            imgui.PopStyleVar()
        end
    end
end

--------------- ВСЕ ОСТАЛЬНЫЕ ФУНКИ ---------------
----------- Закрытие окна на клавишу ESC
function onWindowMessage(m, p)
    if p == 0x1B and main_window_state.v then
        if not sampIsDialogActive() and not sampIsChatInputActive() then
            consumeWindowMessage()
            main_window_state.v = false
        end
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
function imgui.CenterButton(text, size)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Button(text, size)
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
function autoupdate(json_url, prefix, url)
    local dlstatus = require('moonloader').download_status
    local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
    if doesFileExist(json) then os.remove(json) end
    downloadUrlToFile(json_url, json,
      function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
          if doesFileExist(json) then
            local f = io.open(json, 'r')
            if f then
              local info = decodeJson(f:read('*a'))
              updatelink = info.updateurl
              updateversion = info.latest
              f:close()
              os.remove(json)
              if updateversion ~= thisScript().version then
                lua_thread.create(function(prefix)
                  local dlstatus = require('moonloader').download_status
                  local color = 4290744085
                  if not disableanynotfbool.v then
                    sampAddChatMessage(tag..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion, color)
                  end
                  wait(250)
                  downloadUrlToFile(updatelink, thisScript().path,
                    function(id3, status1, p13, p23)
                        if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        if not disableanynotfbool.v then
                            sampAddChatMessage(tag..'Обновление завершено!', color)
                        end
                        goupdatestatus = true
                        lua_thread.create(function() wait(500) thisScript():reload() end)
                      end
                      if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                            if not disableanynotfbool.v then
                                sampAddChatMessage(tag..'Обновление прошло неудачно. Запускаю устаревшую версию..', color)
                            end
                            update = false
                        end
                      end
                    end
                  )
                  end, prefix
                )
              else
                update = false
                if not disableanynotfbool.v then
                    sampAddChatMessage(tag..'Обновление не требуется. Запускаюсь с текущей версии.', 4290744085)
                end
              end
            end
          else
            if not disableanynotfbool.v then
                sampAddChatMessage(tag..'Не получилось проверить обновление. Напишите в личные сообщения официальной группы', 4290744085)
            end
            update = false
          end
        end
      end
    )
  end
---------- Округление
function math_round(roundIn, roundDig) -- первый аргумент - число которое надо округлить, второй аргумент - количество символов после запятой.
    local mul = math.pow(10, roundDig)
    return (math.floor((roundIn * mul) + 0.5)/mul)
end
---------- Гиперссылка
function imgui.Link(link,name,myfunc)
    myfunc = type(name) == 'boolean' and name or myfunc or false
    name = type(name) == 'string' and name or type(name) == 'boolean' and link or link
    local size = imgui.CalcTextSize(name)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local resultBtn = imgui.InvisibleButton('##'..link..name, size)
    if resultBtn then
        if not myfunc then
            os.execute('explorer '..link)
        end
    end
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CloseButton], name)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CloseButtonHovered]))
    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CloseButton], name)
    end
    return resultBtn
end