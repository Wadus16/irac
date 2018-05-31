Перем ИБ_Ид; 			// infobase
Перем ИБ_Имя;			// name
Перем ИБ_Описание;		// descr
Перем ИБ_ПолноеОписание;// Истина - получено полное описание; Ложь - сокращенное
Перем ИБ_Сеансы;
Перем ИБ_Соединения;
Перем ИБ_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера          - АгентКластера          - ссылка на родительский объект агента кластера
//   Кластер                - Кластер                - ссылка на родительский объект кластера
//   ИБ                     - Строка, Соответствие   - идентификатор информационной базы в кластере
//                                                     или параметры информационной базы	
//   Администратор          - Строка                 - администратор информационной базы
//   ПарольАдминистратора   - Строка                 - пароль администратора информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ, Администратор = "", ПарольАдминистратора = "")

	Если НЕ ЗначениеЗаполнено(ИБ) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый ПараметрыОбъекта("infobase");

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	ИБ_ПолноеОписание = Ложь;

	Если ТипЗнч(ИБ) = Тип("Соответствие") Тогда
		ИБ_Ид = ИБ["infobase"];
		ЗаполнитьПараметрыИБ(ИБ);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		ИБ_Ид = ИБ;
		МоментАктуальности = 0;
	КонецЕсли;

	Если ЗначениеЗаполнено(Администратор) Тогда
		Кластер_Владелец.ДобавитьАдминистратораИБ(ИБ_Ид, Администратор, ПарольАдминистратора);
	КонецЕсли;
	
	ПериодОбновления = 60000;
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(ИБ_Параметры,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ТекОписание = ПолучитьПолноеОписаниеИБ();

	Если ТекОписание = Неопределено Тогда
		ИБ_ПолноеОписание = Ложь;
		ТекОписание = ПолучитьОписаниеИБ();
	Иначе
		ИБ_ПолноеОписание = Истина;
	КонецЕсли;
			
	Если ТекОписание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрыИБ(ТекОписание);

	ИБ_Сеансы = Новый Сеансы(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);
	ИБ_Соединения = Новый Соединения(Кластер_Агент, Кластер_Владелец, , ЭтотОбъект);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура заполняет параметры информационной базы
//   
// Параметры:
//   ДанныеЗаполнения		- Соответствие		- данные, из которых будут заполнены параметры ИБ
//   
Процедура ЗаполнитьПараметрыИБ(ДанныеЗаполнения)

	ИБ_Имя = ДанныеЗаполнения.Получить("name");
	ИБ_Описание = ДанныеЗаполнения.Получить("descr");

	Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, ИБ_Параметры, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыИБ()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт

	Возврат ПараметрыОбъекта.Получить(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает полное описание информационной базы 1С
//
// Возвращаемое значение:
//	Соответствие - полное описание информационной базы 1С
//   
Функция ПолучитьПолноеОписаниеИБ()

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"     , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера" , Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторИБ"           , Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииИБ"       , СтрокаАвторизации());

	ПараметрыЗапуска = Новый ПараметрыКоманды("infobase", ПараметрыКоманды);
		
	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска.ПараметрыКоманды("ПолноеОписание"));
	
	Если НЕ КодВозврата = 0 Тогда
		Если Найти(Кластер_Агент.ВыводКоманды(Ложь), "Недостаточно прав пользователя") = 0 Тогда
			ВызватьИсключение Кластер_Агент.ВыводКоманды(Ложь);
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
		
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если МассивРезультатов.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьПолноеОписаниеИБ()

// Функция возвращает сокращенное описание информационной базы 1С
//
// Возвращаемое значение:
//	Соответствие - сокращенное описание информационной базы 1С
//   
Функция ПолучитьОписаниеИБ()

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"     , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера" , Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторИБ"           , Ид());

	ПараметрыЗапуска = Новый ПараметрыКоманды("infobase", ПараметрыКоманды);
		
	Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска.ПараметрыКоманды("Описание"));
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если МассивРезультатов.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьОписаниеИБ()

// Функция возвращает строку параметров авторизации для информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	ПараметрыАдминистратора = Кластер_Владелец.ПолучитьАдминистратораИБ(Ид());

	Если НЕ ТипЗнч(ПараметрыАдминистратора)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ ПараметрыАдминистратора.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Если ПустаяСтрока(ПараметрыАдминистратора.Администратор) Тогда
		Возврат "";
	КонецЕсли;

	Лог.Отладка("Администратор " + ПараметрыАдминистратора.Администратор);
	Лог.Отладка("Пароль <***>");

	СтрокаАвторизации = СтрШаблон("--infobase-user=%1", ПараметрыАдминистратора.Администратор);

	Если НЕ ПустаяСтрока(ПараметрыАдминистратора.Пароль) Тогда
		СтрокаАвторизации = СтрокаАвторизации + СтрШаблон(" --infobase-pwd=%1", ПараметрыАдминистратора.Пароль);
	КонецЕсли;
			
	Возврат СтрокаАвторизации;
	
КонецФункции // СтрокаАвторизации()
	
// Процедура устанавливает параметры авторизации для информационной базы 1С
//   
// Параметры:
//   Администратор 		- Строка	- администратор информационной базы 1С
//   Пароль			 	- Строка	- пароль администратора информационной базы 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	Кластер_Владелец.ДобавитьАдминистратораИБ(Ид(), Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Функция возвращает идентификатор информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - идентификатор информационной базы 1С
//
Функция Ид() Экспорт

	Возврат ИБ_Ид;

КонецФункции // Ид()

// Функция возвращает имя информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - имя информационной базы 1С
//
Функция Имя() Экспорт

	Если Служебный.ТребуетсяОбновление(ИБ_Имя, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат ИБ_Имя;
	
КонецФункции // Имя()

// Функция возвращает описание информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - описание информационной базы 1С
//
Функция Описание() Экспорт

	Если Служебный.ТребуетсяОбновление(ИБ_Описание, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат ИБ_Описание;
	
КонецФункции // Описание()

// Функция возвращает признак доступности полного описания информационной базы 1С
//   
// Возвращаемое значение:
//	Булево - Истина - доступно полное описание; Ложь - доступно сокращенное описание
//
Функция ПолноеОписание() Экспорт

	Если Служебный.ТребуетсяОбновление(ИБ_ПолноеОписание, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат ИБ_ПолноеОписание;
	
КонецФункции // ПолноеОписание()

// Функция возвращает сеансы информационной базы 1С
//   
// Возвращаемое значение:
//	Сеансы - сеансы информационной базы 1С
//
Функция Сеансы() Экспорт
	
	Если Служебный.ТребуетсяОбновление(ИБ_Сеансы, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат ИБ_Сеансы;
		
КонецФункции // Сеансы()
	
// Функция возвращает соединения информационной базы 1С
//   
// Возвращаемое значение:
//	Соединения - соединения информационной базы 1С
//
Функция Соединения() Экспорт
	
	Если Служебный.ТребуетсяОбновление(ИБ_Соединения, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат ИБ_Соединения;
		
КонецФункции // Соединения()
	
// Функция возвращает значение параметра информационной базы 1С
//   
// Параметры:
//   ИмяПоля			 	- Строка		- Имя параметра информационной базы
//   ОбновитьПринудительно 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Ид, infobase"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ИБ_Ид;
	ИначеЕсли НЕ Найти(ВРЕг("Имя, name"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ИБ_Имя;
	ИначеЕсли НЕ Найти(ВРЕг("Описание, descr"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ИБ_Описание;
	ИначеЕсли НЕ Найти(ВРЕг("ПолноеОписание"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ИБ_ПолноеОписание;
	КонецЕсли;
	
	ЗначениеПоля = ИБ_Параметры.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
		
		ОписаниеПараметра = ПараметрыОбъекта("ИмяПоляРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = ИБ_Параметры.Получить(ОписаниеПараметра["ИмяПараметра"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
		
КонецФункции // Получить()
	
// Процедура изменяет параметры информационной базы
//   
// Параметры:
//   ПараметрыИБ	 	- Структура		- новые параметры информационной базы
//
Процедура Изменить(Знач ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("update");

	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
		
	ВремПараметры = ПараметрыОбъекта();

	Для Каждого ТекЭлемент Из ВремПараметры Цикл
		Если НЕ ПараметрыИБ.Свойство(ТекЭлемент.Ключ) Тогда
			Продолжить;
		КонецЕсли;
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.ПараметрКоманды + "=%1", ПараметрыИБ[ТекЭлемент.Ключ]));
	КонецЦикла;

	Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Кластер_Агент.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Изменить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
