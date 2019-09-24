// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем ЭтоWindows;
Перем ВыводКоманды;
Перем КодВозврата;
Перем ПутьКУтилитеАдминистрирования;
Перем ВерсияУтилитыАдминистрирования;

Перем Лог;

// Конструктор
//   
// Параметры:
//   ВерсияИлиПутьКРАК                 - Строка    - маска версии 1С или путь к утилите RAC
//
Процедура ПриСозданииОбъекта(ВерсияИлиПутьКРАК = "8.3")

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

	ВерсияУтилитыАдминистрирования = "";

	Если ЗначениеЗаполнено(ВерсияИлиПутьКРАК) Тогда
		ИнициализироватьУтилитуАдминистрирования(ВерсияИлиПутьКРАК);
	КонецЕсли;

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура ищет утилиту RAC и выполняет инициализацию
//   
// Параметры:
//   ВерсияИлиПутьКРАК                 - Строка    - маска версии 1С или путь к утилите RAC
//
Процедура ИнициализироватьУтилитуАдминистрирования(ВерсияИлиПутьКРАК = "") Экспорт

	// Если версия установлена и не указано новая, то инициализация не выполняется
	Если ЗначениеЗаполнено(ВерсияУтилитыАдминистрирования) И НЕ ЗначениеЗаполнено(ВерсияИлиПутьКРАК) Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеЗаполнено(ВерсияИлиПутьКРАК) Тогда
		ПутьКУтилитеАдминистрирования = ВерсияИлиПутьКРАК;
	КонецЕсли;

	// по-умолчанию ищем последнюю версию 8.3
	Если НЕ ЗначениеЗаполнено(ПутьКУтилитеАдминистрирования) Тогда
		ПутьКУтилитеАдминистрирования = "8.3";
	КонецЕсли;

	ШаблонПроверки = "8.";
	Если Лев(ПутьКУтилитеАдминистрирования, СтрДлина(ШаблонПроверки)) = ШаблонПроверки Тогда
		ПутьКУтилитеАдминистрирования = ПолучитьПутьКВерсииПлатформы(ВерсияИлиПутьКРАК);
		УстановитьПутьКУтилитеАдминистрирования(ПутьКУтилитеАдминистрирования);
	КонецЕсли;

	ВерсияУтилитыАдминистрирования = ПолучитьВерсиюУтилитыАдминистрирования(ПутьКУтилитеАдминистрирования());

КонецПроцедуры // ИнициализироватьУтилитуАдминистрирования()

///////////////////////////////////////////////////////////////////////////////////
// Интерфейсные процедуры и функции
///////////////////////////////////////////////////////////////////////////////////

// Функция возвращает версию утилиты RAC
//   
// Возвращаемое значение:
//    Строка - версия утилиты администрирования
//
Функция ВерсияУтилитыАдминистрирования() Экспорт

	Возврат ВерсияУтилитыАдминистрирования;

КонецФункции // ВерсияУтилитыАдминистрирования()

// Функция возвращает путь к утилите RAC
//   
// Возвращаемое значение:
//    Строка - текущий путь к утилите RAC
//
Функция ПутьКУтилитеАдминистрирования() Экспорт
	
	Возврат ПутьКУтилитеАдминистрирования;

КонецФункции // ПутьКУтилитеАдминистрирования()

// Процедура устанавливает переданный путь к утилите RAC
//   
// Параметры:
//   Путь         - Строка        - новый путь к утилите RAC
//
Процедура УстановитьПутьКУтилитеАдминистрирования(Знач Путь = "") Экспорт
	
	Если Путь = "" Тогда
		Возврат;
	КонецЕсли;

	ФайлУтилитыАдминистрирования = Новый Файл(Путь);
	Если Не ФайлУтилитыАдминистрирования.Существует() Тогда
		ВызватьИсключение "Нельзя установить несуществующий путь к утилите RAC: " + ФайлУтилитыАдминистрирования.ПолноеИмя;
	КонецЕсли;

	ПутьКУтилитеАдминистрирования = Путь;

КонецПроцедуры // УстановитьПутьКУтилитеАдминистрирования()

// Функция выполняет запуск утилиты администрирования кластера 1С (rac) с указанными параметрами
//   
// Параметры:
//    ПараметрыКоманды            - Масссив     - список параметров запуска утилиты администрирования кластера 1С (rac)
//    
// Возвращаемое значение:
//    Строка - вывод команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	ИнициализироватьУтилитуАдминистрирования();

	КодВозврата = ЗапуститьИПодождать(ПараметрыКоманды);

	Если КодВозврата = 0 Тогда
		Лог.Отладка("Код возврата равен %1: %2", КодВозврата, ВыводКоманды());
	Иначе
		Лог.Предупреждение("Получен ненулевой код возврата %1: %2", КодВозврата, ВыводКоманды());
	КонецЕсли;

	Возврат ВыводКоманды();

КонецФункции // ВыполнитьКоманду()

// Функция возвращает текст результата выполнения команды
//   
// Возвращаемое значение:
//    Строка - вывод команды
//
Функция ВыводКоманды() Экспорт

	Возврат ВыводКоманды;

КонецФункции // ВыводКоманды()

// Функция возвращает код возврата выполнения команды
//   
// Возвращаемое значение:
//    Число - код возврата команды
//
Функция КодВозврата() Экспорт

	Возврат КодВозврата;

КонецФункции // КодВозврата()

///////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции поиска платформы
///////////////////////////////////////////////////////////////////////////////////

// Функция ищет существующие каталоги с установленной платформой 1С по списку возможных каталогов установки
// соответствующие переданной маске версии
//   
// Параметры:
//   КаталогиУстановкиПлатформы         - Массив        - возможные каталоги установки платформы
//   Версия                             - Строка        - маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//    Массив - массив каталогов с установленной платформой 1С
//
Функция НайтиПодкаталоги1СПоМаскеВерсии(КаталогиУстановкиПлатформы, Знач Версия)

	МассивКаталогов1С = Новый Массив;
	Для Каждого ВозможныйПуть Из КаталогиУстановкиПлатформы Цикл
	
		Лог.Отладка("Выполняю попытку поиска версии в каталоге " + ВозможныйПуть);
	    
		МассивФайлов = НайтиФайлы(ВозможныйПуть, Версия + "*");
		Если МассивФайлов.Количество() = 0 Тогда
			Лог.Отладка("Не найдено ни одного каталога с версией в %1", ВозможныйПуть);
			Продолжить;
		КонецЕсли;
		Если МассивКаталогов1С = Неопределено Тогда
			МассивКаталогов1С = МассивФайлов;
			Продолжить;
		КонецЕсли;
		Для каждого Подкаталог1С Из МассивФайлов Цикл
			ФайлУтилитыАдминистрирования = Новый Файл(ОбъединитьПути(Подкаталог1С.ПолноеИмя, "bin", "rac.exe"));
			Если НЕ ФайлУтилитыАдминистрирования.Существует() Тогда
				Лог.Отладка("Пропускаю каталог 1С %1", Подкаталог1С.Имя);
				Продолжить;
			КонецЕсли;     
			ОписаниеКаталога = Новый Структура("Версия, ФайлУтилитыАдминистрирования",
	                                            Подкаталог1С.Имя,
	                                            ФайлУтилитыАдминистрирования);
			МассивКаталогов1С.Добавить(ОписаниеКаталога);
			Лог.Отладка("Нашел платформу 1С %1", Подкаталог1С.Имя);
		КонецЦикла;
	КонецЦикла;

	Возврат МассивКаталогов1С;

КонецФункции // НайтиПодкаталоги1СПоМаскеВерсии()

// Процедура добавляет в массив расположений пути расположения платформы 1С из файла настройки платформы 1С
//   
// Параметры:
//   ИмяФайла             - Строка        - путь к файлу настройки платформы 1С
//   МассивПутей         - Массив        - массив расположений платформы 1С
//
Процедура ДополнитьМассивРасположенийИзКонфигурационногоФайла(Знач ИмяФайла, Знач МассивПутей)
	
	ФайлКонфига = Новый Файл(ИмяФайла);
	Если Не ФайлКонфига.Существует() Тогда
		Лог.Отладка("Конфигурационный файл " + ИмяФайла + " не найден.");
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Читаю конфигурационный файл " + ИмяФайла + ".");
	Конфиг = Новый КонфигурацияСтартера;
	Конфиг.Открыть(ИмяФайла);
	
	Значения = Конфиг.ПолучитьСписок("InstalledLocation");
	Если Значения <> Неопределено Тогда
		Для Каждого Путь Из Значения Цикл
			МассивПутей.Добавить(Путь);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры // ДополнитьМассивРасположенийИзКонфигурационногоФайла()

// Процедура добавляет в массив расположений стандартные пути расположения платформы 1С
//   
// Параметры:
//   МассивПутей         - Массив        - массив расположений платформы 1С
//
Процедура ДополнитьМассивРасположенийИзСтандартныхПутей(Знач МассивПутей)
	
	КаталогПрограмм_86 = "C:" + "\Program Files (x86)\";
	КаталогПрограмм_64 = "C:" + "\Program Files\";

	ФайлProgramFiles = Новый Файл(КаталогПрограмм_86);
	Если Не ФайлProgramFiles.Существует() Тогда
		ФайлProgramFiles = Новый Файл(КаталогПрограмм_64);
		Если Не ФайлProgramFiles.Существует() Тогда
			ВызватьИсключение "Не обнаружено установленных версий платформы 1С";
		КонецЕсли;
	КонецЕсли;
	    
	МассивПутей.Добавить(ОбъединитьПути(ФайлProgramFiles.ПолноеИмя, "1Cv8"));
	
КонецПроцедуры // ДополнитьМассивРасположенийИзСтандартныхПутей()

// Функция возвращает массив возможных путей расположения платформы 1С
//   
// Возвращаемое значение:
//    Массив - массив расположений платформы 1С
//
Функция СобратьВозможныеКаталогиУстановкиПлатформыWindows()
	
	// Ищем в расположениях для Vista и выше.
	// Желающие поддержать пути в Windows XP - welcome
	КаталогВсеПользователи = ПолучитьПеременнуюСреды("ALLUSERSPROFILE");
	КаталогТекущегоПользователя = ПолучитьПеременнуюСреды("APPDATA");
	
	МассивПутей = Новый Массив;
	СуффиксРасположения = "1C\1CEStart\1CEStart.cfg";
	
	ОбщийКонфиг = ОбъединитьПути(КаталогВсеПользователи, СуффиксРасположения);
	ДополнитьМассивРасположенийИзКонфигурационногоФайла(ОбщийКонфиг, МассивПутей);
	
	ПользовательскийКонфиг = ОбъединитьПути(КаталогТекущегоПользователя, СуффиксРасположения);
	ДополнитьМассивРасположенийИзКонфигурационногоФайла(ПользовательскийКонфиг, МассивПутей);
	
	Если МассивПутей.Количество() = 0 Тогда
		Лог.Отладка("В конфигах стартера не найдены пути установки. Пробую стандартные пути наугад.");
		ДополнитьМассивРасположенийИзСтандартныхПутей(МассивПутей);
	КонецЕсли;

	Возврат МассивПутей;
	
КонецФункции // СобратьВозможныеКаталогиУстановкиПлатформыWindows()

// Функция возвращает путь к каталогу платформы 1С в ОС Windows, соответствующей маске версии
//   
// Параметры:
//   Версия         - Строка        - маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//    Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформыWindows(Знач Версия)
	
	КаталогиУстановкиПлатформы = СобратьВозможныеКаталогиУстановкиПлатформыWindows();
	
	МассивКаталогов1С = НайтиПодкаталоги1СПоМаскеВерсии(КаталогиУстановкиПлатформы, Версия);

	НужныйФайлПлатформы = Неопределено;

	МассивКаталоговВерсий = Новый Массив;
	Для Каждого ОписаниеКаталога Из МассивКаталогов1С Цикл
		ПравыйСимвол = Прав(ОписаниеКаталога.Версия, 1);
		Если ПравыйСимвол < "0" ИЛИ ПравыйСимвол > "9" Тогда
			Продолжить;
		КонецЕсли;
		МассивКаталоговВерсий.Добавить(ОписаниеКаталога);
	КонецЦикла;

	Если МассивКаталоговВерсий.Количество() > 0 Тогда
		ОписаниеМаксВерсии = МассивКаталоговВерсий[0];
		Для Сч = 1 По МассивКаталоговВерсий.ВГраница() Цикл
			Если СтроковыеФункции.СравнитьВерсии(МассивКаталоговВерсий[Сч].Версия, ОписаниеМаксВерсии.Версия) > 0 Тогда
				ОписаниеМаксВерсии = МассивКаталоговВерсий[Сч];
			КонецЕсли;     
		КонецЦикла;
		НужныйФайлПлатформы = ОписаниеМаксВерсии.ФайлУтилитыАдминистрирования;
		ВерсияУтилитыАдминистрирования = ОписаниеМаксВерсии.Версия;
		Лог.Отладка("Утилита RAC: %1", НужныйФайлПлатформы.ПолноеИмя);

	КонецЕсли;
	
	Если НужныйФайлПлатформы = Неопределено Тогда
		ВызватьИсключение "Не найден путь к платформе 1С <" + Версия + ">";
	КонецЕсли;

	Если Не НужныйФайлПлатформы.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <" + НужныйФайлПлатформы.ПолноеИмя + "> не существует";
	КонецЕсли;

	Возврат НужныйФайлПлатформы.ПолноеИмя;

КонецФункции // ПолучитьПутьКВерсииПлатформыWindows()

// Функция возвращает путь к каталогу платформы 1С в ОС Linux, соответствующей маске версии
//   
// Параметры:
//   Версия         - Строка        - маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//    Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформыLinux(Знач Версия)
	
	// help wanted: на Линукс конфиг стартера лежит в ~/.1C/1cestart.
	КорневойПуть1С = ОбъединитьПути("/opt", "1C", "v8.3");
	КаталогУстановки = Новый Файл(ОбъединитьПути(КорневойПуть1С, "i386"));
	Если НЕ КаталогУстановки.Существует() Тогда
		КаталогУстановки = Новый Файл(ОбъединитьПути(КорневойПуть1С, "x86_64"));
	КонецЕсли;
	// Определим версию приложения
	НужныйФайлПлатформы = Новый Файл(ОбъединитьПути(КаталогУстановки.ПолноеИмя, "rac"));
	Попытка
		ВерсияУтилитыАдминистрирования = ПолучитьВерсиюУтилитыАдминистрирования(НужныйФайлПлатформы.ПолноеИмя);
	Исключение
		Лог.Предупреждение("Не удалось прочитать версию 1С %1, %2.
		|" + ОписаниеОшибки(), Версия, НужныйФайлПлатформы.ПолноеИмя);
	КонецПопытки;

	Если Не НужныйФайлПлатформы.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <" + НужныйФайлПлатформы.ПолноеИмя + "> не существует";
	КонецЕсли;

	Возврат НужныйФайлПлатформы.ПолноеИмя;

КонецФункции // ПолучитьПутьКВерсииПлатформыLinux()

// Функция возвращает путь к каталогу платформы 1С, соответствующей маске версии
//   
// Параметры:
//   Версия         - Строка        - маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//    Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформы(Знач Версия)
	
	ШаблонПроверки = "8.";
	Если Лев(Версия, СтрДлина(ШаблонПроверки)) <> ШаблонПроверки Тогда
		ВызватьИсключение "Неверная версия платформы <" + Версия + ">";
	КонецЕсли;
	
	КоличествоЦифрВерсии = 2;

	СписокСтрок = СтрРазделить(Версия, ".");
	Если СписокСтрок.Количество() < КоличествоЦифрВерсии Тогда
		ВызватьИсключение "Маска версии платформы должна содержать,
	                        |как минимум, минорную и мажорную версию, т.е. Maj.Min[.Release][.Build]";
	КонецЕсли;
	
	Если ЭтоWindows Тогда
	    
		Возврат ПолучитьПутьКВерсииПлатформыWindows(Версия);

	Иначе

		Возврат ПолучитьПутьКВерсииПлатформыLinux(Версия);

	КонецЕсли;
	
КонецФункции // ПолучитьПутьКВерсииПлатформы()

// Функция получает версию утилиты RAC по переданному пути
//   
// Параметры:
//   Путь         - Строка        - путь к утилите RAC
//
// Возвращаемое значение:
//    Строка - версия утилиты RAC
//
Функция ПолучитьВерсиюУтилитыАдминистрирования(Знач Путь)

	Команда = Новый Команда;
	СтрокаЗапуска = Служебный.ОбернутьВКавычки(Путь) + " -v ";
	Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
	Команда.УстановитьПравильныйКодВозврата(0);
	Попытка
		Команда.Исполнить();
		Возврат СокрЛП(Команда.ПолучитьВывод());
	Исключение
		Лог.Предупреждение("Не удалось прочитать версию 1С %1.
		|" + ОписаниеОшибки(), СтрокаЗапуска);
	КонецПопытки;

	Возврат "";

КонецФункции // ПолучитьВерсиюУтилитыАдминистрирования()

///////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции выполнения команд системы
///////////////////////////////////////////////////////////////////////////////////

// Функция запускает выполнение команды ОС с указанными параметрами и ожидает завершения
//   
// Параметры:
//   Параметры         - Массив        - параметры выполняемой команды
//
// Возвращаемое значение:
//    Число - код возврата команды ОС
//
Функция ЗапуститьИПодождать(Знач Параметры)

	СтрокаДляЛога = "";
	Для Каждого Параметр Из Параметры Цикл

		Если Найти(Параметр, "-pwd") = 0 Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;

	КонецЦикла;

	КодВозврата = 0;

	Приложение = Служебный.ОбернутьВКавычки(ПутьКУтилитеАдминистрирования());
	Лог.Отладка(Приложение + СтрокаДляЛога);

	Команда = Новый Команда;
	
	Команда.УстановитьКоманду(Приложение);
	Команда.УстановитьКодировкуВывода(КодировкаТекста.OEM);
	Команда.ДобавитьПараметры(Параметры);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	Команда.ПоказыватьВыводНемедленно(Ложь);
	КодВозврата = Команда.Исполнить();
	
	ВыводКоманды = Команда.ПолучитьВывод();

	Лог.Отладка("Получен код возврата %1", КодВозврата);
	
	Возврат КодВозврата;

КонецФункции // ЗапуститьИПодождать()    

Лог = Логирование.ПолучитьЛог("oscript.lib.irac");
