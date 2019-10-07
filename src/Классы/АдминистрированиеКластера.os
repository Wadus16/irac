// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Админ_АдресСервера;
Перем Админ_ПортСервера;
Перем Агент_ИсполнительКоманд;
Перем Агент_Администраторы;
Перем Агент_Администратор;
Перем Кластеры_Администраторы;
Перем ВыводКоманды;
Перем Кластеры;

Перем ПараметрыОбъекта;

Перем ОбработчикОшибок;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АдресСервера           - Строка    - имя сервера агента администрирования (RAS)
//   ПортСервера            - Число     - порт сервера агента администрирования (RAS)
//   ВерсияИлиПутьКРАК      - Строка    - маска версии 1С или путь к утилите RAC
//   Администратор          - Строка    - администратор агента сервера 1С
//   ПарольАдминистратора   - Строка    - пароль администратора агента сервера 1С
//
Процедура ПриСозданииОбъекта(АдресСервера
	                       , ПортСервера
	                       , ВерсияИлиПутьКРАК = "8.3"
	                       , Администратор = ""
	                       , ПарольАдминистратора = "")

	Лог = Служебный.Лог();

	Лог.Предупреждение("[DEPRICATED] Класс ""АдминистрированиеКластера"" устарел,
	                   |используйте класс ""УправлениеКластером1С""!");

	Админ_АдресСервера = АдресСервера;
	Админ_ПортСервера = ПортСервера;
	
	Агент_ИсполнительКоманд = Новый ИсполнительКоманд(ВерсияИлиПутьКРАК);

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Агент);

	Если ЗначениеЗаполнено(Администратор) Тогда
		Агент_Администратор = Новый Структура("Администратор, Пароль", Администратор, ПарольАдминистратора);
	Иначе
		Агент_Администратор = Неопределено;
	КонецЕсли;
	
	Агент_Администраторы = Новый АдминистраторыАгента(ЭтотОбъект);
	Кластеры = Новый Кластеры(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Функция возвращает строку параметров подключения к агенту администрирования (RAS)
//   
// Возвращаемое значение:
//    Строка - строка параметров подключения к агенту администрирования (RAS)
//
Функция СтрокаПодключения() Экспорт

	Сервер = "";
	Если Не ПустаяСтрока(Админ_АдресСервера) Тогда
		Сервер = Админ_АдресСервера;
		Если Не ПустаяСтрока(Админ_ПортСервера) Тогда
			Сервер = Сервер + ":" + Админ_ПортСервера;
		КонецЕсли;
	КонецЕсли;
	        
	Возврат Сервер;

КонецФункции // СтрокаПодключения()

// Функция возвращает строку параметров авторизации на агенте кластера 1С
//   
// Возвращаемое значение:
//    Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Если НЕ ТипЗнч(Агент_Администратор)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ Агент_Администратор.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Если ПустаяСтрока(Агент_Администратор.Администратор) Тогда
		Возврат "";
	КонецЕсли;

	СтрокаАвторизации = СтрШаблон("--agent-user=%1", Служебный.ОбернутьВКавычки(Агент_Администратор.Администратор));

	Если НЕ ПустаяСтрока(Агент_Администратор.Пароль) Тогда
		СтрокаАвторизации = СтрокаАвторизации + СтрШаблон(" --agent-pwd=%1", Агент_Администратор.Пароль);
	КонецЕсли;
	        
	Возврат СтрокаАвторизации;
	
КонецФункции // СтрокаАвторизации()
	
// Процедура устанавливает параметры авторизации на агенте кластера 1С
//   
// Параметры:
//   Администратор         - Строка    - администратор агента сервера 1С
//   Пароль                - Строка    - пароль администратора агента сервера 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	Агент_Администратор = Новый Структура("Администратор, Пароль", Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Процедура добавляет параметры авторизации для указанного кластера
//   
// Параметры:
//   Кластер_Ид         - Строка    - идентификатор кластера 1С
//   Администратор      - Строка    - администратор кластера 1С
//   Пароль             - Строка    - пароль администратора кластера 1С
//
Процедура ДобавитьАдминистратораКластера(Кластер_Ид, Администратор, Пароль) Экспорт

	Если НЕ ТипЗнч(Кластеры_Администраторы) = Тип("Соответствие") Тогда
		Кластеры_Администраторы = Новый Соответствие();
	КонецЕсли;

	Кластеры_Администраторы.Вставить(Кластер_Ид, Новый Структура("Администратор, Пароль", Администратор, Пароль));

КонецПроцедуры // ДобавитьАдминистратораКластера()

// Функция возвращает параметры авторизации для указанного кластера
//   
// Параметры:
//   Кластер_Ид        - Строка    - идентификатор кластера 1С
//
// Возвращаемое значение:
//   Структура         - параметры администратора
//       Администратор      - Строка    - администратор кластера 1С
//       Пароль             - Строка    - пароль администратора кластера 1С
//
Функция ПолучитьАдминистратораКластера(Кластер_Ид) Экспорт

	Если НЕ ТипЗнч(Кластеры_Администраторы) = Тип("Соответствие") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат Кластеры_Администраторы.Получить(Кластер_Ид); 

КонецФункции // ПолучитьАдминистратораКластера()

// Функция возвращает текущий объект-исполнитель команд
//   
// Возвращаемое значение:
//   ИсполнительКоманд        - текущее значение объекта-исполнителя команд
//
Функция ИсполнительКоманд() Экспорт

	Возврат Агент_ИсполнительКоманд;

КонецФункции // ИсполнительКоманд()

// Процедура устанавливает объект-исполнитель команд
//   
// Параметры:
//   НовыйИсполнитель         - ИсполнительКоманд        - новый объект-исполнитель команд
//
Процедура УстановитьИсполнительКоманд(Знач НовыйИсполнитель = Неопределено) Экспорт

	Агент_ИсполнительКоманд = НовыйИсполнитель;

КонецПроцедуры // УстановитьИсполнительКоманд()

// Устанавливает объект-обработчик, который будет вызываться в случае неудачи вызова ИсполнителяКоманд.
// Объект обработчик должен определить метод ОбработатьОшибку с параметрами:
//   * ПараметрыКоманды - передадутся параметры вызванной команды
//   * АгентАдминистрирования - объект АдминистрированиеКластера у которого вызывалась команда
//   * КодВозврата - на входе - полученный код возврата команды. В качестве выходного параметра 
//                   можно присвоить новое значение кода возврата
//
// Параметры:
//   НовыйОбработчикОшибок      - Произвольный      - объект-обработчик
//
Процедура УстановитьОбработчикОшибокКоманд(Знач НовыйОбработчикОшибок) Экспорт

	ОбработчикОшибок = НовыйОбработчикОшибок;

КонецПроцедуры // УстановитьОбработчикОшибокКоманд()

// Функция выполняет команду и возвращает код возврата команды
//   
// Параметры:
//   ПараметрыКоманды         - Массив        - параметры выполнения команды
//
// Возвращаемое значение:
//   Число                     - Код возврата команды
//
Функция ВыполнитьКоманду(ПараметрыКоманды) Экспорт

	ВыводКоманды = Агент_ИсполнительКоманд.ВыполнитьКоманду(ПараметрыКоманды);
	ПолученныйКод = Агент_ИсполнительКоманд.КодВозврата();

	Если НЕ ПолученныйКод = 0 И НЕ ОбработчикОшибок = Неопределено Тогда
		ОбработчикОшибок.ОбработатьОшибку(ПараметрыКоманды, ЭтотОбъект, ПолученныйКод);
	КонецЕсли;

	Возврат ПолученныйКод;

КонецФункции // ВыполнитьКоманду()

// Функция возвращает текст результата выполнения команды
//   
// Параметры:
//    РазобратьВывод        - Булево      - Истина - выполнить преобразование вывода команды в структуру
//                                          Ложь - вернуть текст вывода команды как есть
//
// Возвращаемое значение:
//    Структура, Строка    - вывод команды
//
Функция ВыводКоманды(РазобратьВывод = Истина) Экспорт

	Если РазобратьВывод Тогда
		Возврат РазобратьВыводКоманды(ВыводКоманды);
	КонецЕсли;

	Возврат ВыводКоманды;

КонецФункции // ВыводКоманды()

// Функция возвращает код возврата выполнения команды
//   
// Возвращаемое значение:
//    Число - код возврата команды
//
Функция КодВозврата() Экспорт

	Возврат Агент_ИсполнительКоманд.КодВозврата();

КонецФункции // КодВозврата()

// Функция преобразует переданный текст вывода команды в массив соответствий
// элементы массива создаются по блокам текста, разделенным пустой строкой
// пары <ключ, значение> структуры получаются для каждой строки с учетом разделителя ":"
//   
// Параметры:
//   ВыводКоманды            - Строка            - текст для разбора
//   
// Возвращаемое значение:
//    Массив (Соответствие) - результат разбора
//
Функция РазобратьВыводКоманды(Знач ВыводКоманды)
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ВыводКоманды);

	МассивРезультатов = Новый Массив();
	Описание = Новый Соответствие();

	Для й = 1 По Текст.КоличествоСтрок() Цикл

		ТекстСтроки = Текст.ПолучитьСтроку(й);
	    
		ПозРазделителя = СтрНайти(ТекстСтроки, ":");

		Если НЕ ЗначениеЗаполнено(ТекстСтроки) Тогда
			Если й = 1 Тогда
				Продолжить;
			КонецЕсли;
			МассивРезультатов.Добавить(Описание);
			Описание = Новый Соответствие();
			Продолжить;
		КонецЕсли;

		Если ПозРазделителя = 0 Тогда
			Продолжить;
		КонецЕсли;
	    
		Описание.Вставить(СокрЛП(Лев(ТекстСтроки, ПозРазделителя - 1)), СокрЛП(Сред(ТекстСтроки, ПозРазделителя + 1)));

	КонецЦикла;

	Возврат МассивРезультатов;

КонецФункции // РазобратьВыводКоманды()

// Функция возвращает строку описания подключения к серверу администрирования кластера 1С
//   
// Возвращаемое значение:
//    Строка - описание подключения к серверу администрирования кластера 1С
//
Функция ОписаниеПодключения() Экспорт

	Возврат СокрЛП(Админ_АдресСервера) + ":" + СокрЛП(Админ_ПортСервера) +
			" (v." + СокрЛП(Агент_ИсполнительКоманд.ВерсияУтилитыАдминистрирования()) + ")";

КонецФункции // ОписаниеПодключения()

// Функция возвращает адрес сервера RAS
//   
// Возвращаемое значение:
//    Строка - адрес сервера RAS
//
Функция АдресСервераАдминистрирования() Экспорт

	Возврат Админ_АдресСервера;

КонецФункции // АдресСервераАдминистрирования()

// Функция возвращает порт сервера RAS
//   
// Возвращаемое значение:
//    Строка - порт сервера RAS
//
Функция ПортСервераАдминистрирования() Экспорт

	Возврат Админ_ПортСервера;

КонецФункции // ПортСервераАдминистрирования()

// Функция возвращает версию утилиты администрирования RAC
//   
// Возвращаемое значение:
//    Строка - версия утилиты администрирования RAC
//
Функция ВерсияУтилитыАдминистрирования() Экспорт

	Возврат СокрЛП(Агент_ИсполнительКоманд.ВерсияУтилитыАдминистрирования());

КонецФункции // ВерсияУтилитыАдминистрирования()

// Функция возвращает список администраторов агента кластера 1С
//   
// Возвращаемое значение:
//    Агент_Администраторы - список администраторов агента кластера 1С
//
Функция Администраторы() Экспорт

	Возврат Агент_Администраторы;

КонецФункции // Администраторы()

// Функция возвращает список кластеров 1С
//   
// Возвращаемое значение:
//    Кластеры - список кластеров 1С
//
Функция Кластеры() Экспорт

	Возврат Кластеры;

КонецФункции // Кластеры()    

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает значение параметра администрирования кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно   - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Найти(ВРЕг("АдресСервераАдминистрирования, ras-host"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат АдресСервераАдминистрирования();
	ИначеЕсли НЕ Найти(ВРЕг("ПортСервераАдминистрирования, ras-port"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ПортСервераАдминистрирования();
	ИначеЕсли НЕ Найти(ВРЕг("ВерсияУтилитыАдминистрирования, rac-version"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат ВерсияУтилитыАдминистрирования();
	Иначе
		ЗначениеПоля = Неопределено;
	КонецЕсли;
	
	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()

// Функция возвращает лог библиотеки
//   
// Возвращаемое значение:
//    Логгер - лог библиотеки
//
Функция Лог() Экспорт

	Возврат Лог;

КонецФункции // Лог()    
