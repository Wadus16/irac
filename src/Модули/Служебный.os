#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать strings
#Использовать 1commands
#Использовать v8runner

Перем КаталогСборки;
Перем ВыводКоманды;
Перем ПутьКПлатформе1С;
Перем ЭтоWindows;
Перем ВерсияПлатформы;

Перем Лог;

// Функция добавляет кавычки в начале и в конце переданной строки
//   
// Параметры:
//   Строка	 	- Строка		- Строка для добавления кавычек
//
// Возвращаемое значение:
//	Строка - строка с добавленными кавычками
//
Функция ОбернутьВКавычки(Знач Строка) Экспорт
	Если Лев(Строка, 1) = """" И Прав(Строка, 1) = """" Тогда
		Возврат Строка;
	Иначе
		Возврат """" + Строка + """";
	КонецЕсли;
КонецФункции // ОбернутьВКавычки()
	
// Функция ищет существующие каталоги с установленной платформой 1С по списку возможных каталогов установки
// соответствующие переданной маске версии
//   
// Параметры:
//   КаталогиУстановкиПлатформы	 	- Массив		- возможные каталоги установки платформы
//   ВерсияПлатформы			 	- Строка		- маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//	Массив - массив каталогов с установленной платформой 1С
//
Функция НайтиПодкаталоги1СПоМаскеВерсии(КаталогиУстановкиПлатформы, Знач ВерсияПлатформы)

	МассивКаталогов1С = Новый Массив;
	Для Каждого ВозможныйПуть Из КаталогиУстановкиПлатформы Цикл
	
		Лог.Отладка("Выполняю попытку поиска версии в каталоге " + ВозможныйПуть);
		
		МассивФайлов = НайтиФайлы(ВозможныйПуть, ВерсияПлатформы + "*");
		Если МассивФайлов.Количество() = 0 Тогда
			Лог.Отладка("Не найдено ни одного каталога с версией в %1", ВозможныйПуть);
			Продолжить;
		КонецЕсли;
		Если МассивКаталогов1С = Неопределено Тогда
			МассивКаталогов1С = МассивФайлов;
			Продолжить;
		КонецЕсли;
		Для каждого Подкаталог1С Из МассивФайлов Цикл
			Файл1cv8 = Новый Файл(ОбъединитьПути(Подкаталог1С.ПолноеИмя, "bin", "rac.exe"));
			Если НЕ Файл1cv8.Существует() Тогда
				Лог.Отладка("Пропускаю каталог 1С %1", Подкаталог1С.Имя);
				Продолжить;
			КонецЕсли;	 
			ОписаниеКаталога = Новый Структура("Версия, ФайлКлиента1С", Подкаталог1С.Имя, Файл1cv8);
			МассивКаталогов1С.Добавить(ОписаниеКаталога);
			Лог.Отладка("Нашел платформу 1С %1", Подкаталог1С.Имя);
		КонецЦикла;
	КонецЦикла;

	Возврат МассивКаталогов1С;

КонецФункции // НайтиПодкаталоги1СПоМаскеВерсии()

// Функция возвращает путь к каталогу платформы 1С в ОС Windows, соответствующей маске версии
//   
// Параметры:
//   ВерсияПлатформы	 	- Строка		- маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//	Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформыWindows(Знач ВерсияПлатформы)
	
	КаталогиУстановкиПлатформы = СобратьВозможныеКаталогиУстановкиПлатформыWindows();
	
	МассивКаталогов1С = НайтиПодкаталоги1СПоМаскеВерсии(КаталогиУстановкиПлатформы, ВерсияПлатформы);

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
		НужныйФайлПлатформы = ОписаниеМаксВерсии.ФайлКлиента1С;
		ВерсияПлатформы = ОписаниеМаксВерсии.Версия;
		Лог.Отладка("Версия найдена: " + НужныйФайлПлатформы.ПолноеИмя);

	КонецЕсли;
	
	Если НужныйФайлПлатформы = Неопределено Тогда
		ВызватьИсключение "Не найден путь к платформе 1С <" + ВерсияПлатформы + ">";
	КонецЕсли;

	Если Не НужныйФайлПлатформы.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <" + НужныйФайлПлатформы.ПолноеИмя + "> не существует";
	КонецЕсли;

	Возврат НужныйФайлПлатформы.ПолноеИмя;

КонецФункции // ПолучитьПутьКВерсииПлатформыWindows()

// Функция возвращает путь к каталогу платформы 1С в ОС Linux, соответствующей маске версии
//   
// Параметры:
//   ВерсияПлатформы	 	- Строка		- маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//	Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформыLinux(Знач ВерсияПлатформы)
	
	// help wanted: на Линукс конфиг стартера лежит в ~/.1C/1cestart.
	КорневойПуть1С = ОбъединитьПути("/opt", "1C", "v8.3");
	КаталогУстановки = Новый Файл(ОбъединитьПути(КорневойПуть1С, "i386"));
	Если НЕ КаталогУстановки.Существует() Тогда
		КаталогУстановки = Новый Файл(ОбъединитьПути(КорневойПуть1С, "x86_64"));
	КонецЕсли;
	// Определим версию приложения
	ФайлРАК = Новый Файл(ОбъединитьПути(КаталогУстановки.ПолноеИмя, "rac"));
	Если ФайлРАК.Существует() Тогда
		Команда = Новый Команда;
		СтрокаЗапуска = ФайлРАК.ПолноеИмя + " -v ";
		Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
		Команда.УстановитьПравильныйКодВозврата(0);
		Попытка
			Команда.Исполнить();
			ВерсияПлатформы = СокрЛП(Команда.ПолучитьВывод());
		Исключение
			Лог.Предупреждение("Не удалось прочитать версию 1С %1, %2.
			|" + ОписаниеОшибки(), ВерсияПлатформы, СтрокаЗапуска);
		КонецПопытки;
	КонецЕсли;
	НужныйФайлПлатформы = Новый Файл(ОбъединитьПути(КаталогУстановки.ПолноеИмя, "rac"));
	
	Если Не НужныйФайлПлатформы.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <" + НужныйФайлПлатформы.ПолноеИмя + "> не существует";
	КонецЕсли;

	Возврат НужныйФайлПлатформы.ПолноеИмя;

КонецФункции // ПолучитьПутьКВерсииПлатформыLinux()

// Функция возвращает путь к каталогу платформы 1С, соответствующей маске версии
//   
// Параметры:
//   ВерсияПлатформы	 	- Строка		- маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
// Возвращаемое значение:
//	Строка - путь к версии платформы 1С
//
Функция ПолучитьПутьКВерсииПлатформы(Знач ВерсияПлатформы) Экспорт
	
	ПроверяемаяВерсия = "8.";
	Если Лев(ВерсияПлатформы, СтрДлина(ПроверяемаяВерсия)) <> ПроверяемаяВерсия Тогда
		ВызватьИсключение "Неверная версия платформы <" + ВерсияПлатформы + ">";
	КонецЕсли;
	
	КоличествоЦифрВерсии = 2;

	СписокСтрок = СтрРазделить(ВерсияПлатформы, ".");
	Если СписокСтрок.Количество() < КоличествоЦифрВерсии Тогда
		ВызватьИсключение "Маска версии платформы должна содержать,
							|как минимум, минорную и мажорную версию, т.е. Maj.Min[.Release][.Build]";
	КонецЕсли;
	
	Если ЭтоWindows Тогда
		
		Возврат ПолучитьПутьКВерсииПлатформыWindows(ВерсияПлатформы);

	Иначе

		Возврат ПолучитьПутьКВерсииПлатформыLinux(ВерсияПлатформы);

	КонецЕсли;
	
КонецФункции // ПолучитьПутьКВерсииПлатформы()

// Функция устанавливает переданную версию платформы 1С
//   
// Параметры:
//   Путь	 	- Строка		- новая версия платформы 1С
//
// Возвращаемое значение:
//	Строка - старая (текущая) версия платформы 1С
//
Функция ВерсияПлатформы(Знач Путь) Экспорт

	Команда = Новый Команда;
	СтрокаЗапуска = ОбернутьВКавычки(Путь) + " -v ";
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

КонецФункции // ВерсияПлатформы()

// Функция возвращает массив возможных путей расположения платформы 1С
//   
// Возвращаемое значение:
//	Массив - массив расположений платформы 1С
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

// Процедура добавляет в массив расположений пути расположения платформы 1С из файла настройки платформы 1С
//   
// Параметры:
//   ИмяФайла		 	- Строка		- путь к файлу настройки платформы 1С
//   МассивПутей	 	- Массив		- массив расположений платформы 1С
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
//   МассивПутей	 	- Массив		- массив расположений платформы 1С
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

//////////////////////////////////////////////////
// Вспомогательные и настроечные функции

// Функция возвращает текст результата выполнения команды
//   
// Возвращаемое значение:
//	Строка - вывод команды
//
Функция ВыводКоманды() Экспорт
	Возврат ВыводКоманды;
КонецФункции // ВыводКоманды()

// Функция устанавливает переданный путь к каталогу сборки
//   
// Параметры:
//   Каталог	 	- Строка		- новый путь к каталогу сборки
//
// Возвращаемое значение:
//	Строка - старый (текущий) путь к каталогу сборки
//
Функция КаталогСборки(Знач Каталог = "") Экспорт

	Если КаталогСборки = Неопределено Тогда
		КаталогСборки = ТекущийКаталог();
	КонецЕсли;

	Если Каталог = "" Тогда
		Возврат КаталогСборки;
	Иначе
		ТекКаталог = КаталогСборки;
		КаталогСборки = Каталог;
		Возврат ТекКаталог;
	КонецЕсли;

КонецФункции // КаталогСборки()

// Функция устанавливает переданный путь к платформе 1С
//   
// Параметры:
//   Путь	 	- Строка		- новый путь к платформе 1С
//
// Возвращаемое значение:
//	Строка - старый (текущий) путь к платформе 1С
//
Функция ПутьКПлатформе1С(Знач Путь = "") Экспорт
	
	Если Путь = "" Тогда
		Возврат ПутьКПлатформе1С;
	Иначе
		ФайлПлатформы = Новый Файл(Путь);
		Если Не ФайлПлатформы.Существует() Тогда
			ВызватьИсключение "Нельзя установить несуществующий путь к платформе: " + ФайлПлатформы.ПолноеИмя;
		КонецЕсли;

		ТекЗначение = ПутьКПлатформе1С;
		ПутьКПлатформе1С = Путь;
		Возврат ТекЗначение;
	КонецЕсли;

КонецФункции // ПутьКПлатформе1С()

// Процедура устанавливает путь к платформе 1С в соответствии с маской версии
//   
// Параметры:
//   МаскаВерсии	 	- Строка		- маска версии платформы вида 8.*, 8.3.*, 8.3.5.*, 8.3.10.2561
//
Процедура ИспользоватьВерсиюПлатформы(Знач МаскаВерсии) Экспорт
	Путь = ПолучитьПутьКВерсииПлатформы(МаскаВерсии);
	ПутьКПлатформе1С(Путь);
КонецПроцедуры // ИспользоватьВерсиюПлатформы()

// Функция выполняет запуск утилиты администрирования кластера 1С (rac) с указанными параметрами
//   
// Параметры:
//	Параметры					- Масссив	 - список параметров запуска утилиты администрирования кластера 1С (rac)
//	ОшибкаПри0КодеВозврата		- Булево	 - Истина - вызывать исключение при коде возврата команды отличном от 0
//
// Возвращаемое значение:
//	Число - код возврата команды
//
Функция ВыполнитьКоманду(Знач Параметры, ОшибкаПри0КодеВозврата = Истина) Экспорт

	КодВозврата = ЗапуститьИПодождать(Параметры);

	Если КодВозврата <> 0 И ОшибкаПри0КодеВозврата Тогда
		Лог.Ошибка("Получен ненулевой код возврата %1. Выполнение скрипта остановлено!", КодВозврата);
		ВызватьИсключение ВыводКоманды();
	ИначеЕсли КодВозврата = 0 Тогда
		Лог.Отладка("Код возврата равен 0");
	Иначе
		Лог.Отладка("Код возврата равен %1: %2 ", КодВозврата, ВыводКоманды());
	КонецЕсли;

	Возврат КодВозврата;

КонецФункции // ВыполнитьКоманду()

// Функция запускает выполнение команды ОС с указанными параметрами и ожидает завершения
//   
// Параметры:
//   Параметры	 	- Массив		- параметры выполняемой команды
//
// Возвращаемое значение:
//	Число - код возврата команды ОС
//
Функция ЗапуститьИПодождать(Знач Параметры)

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из Параметры Цикл

		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;

		Если Найти(Параметр, "--agent-pwd") = 0
			 И Найти(Параметр, "--cluster-pwd") = 0
			 И Найти(Параметр, "--infobase-pwd") = 0
			 И Найти(Параметр, "--pwd") = 0 Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;

	КонецЦикла;

	КодВозврата = 0;

	Приложение = ОбернутьВКавычки(ПутьКПлатформе1С());
	Лог.Отладка(Приложение + СтрокаДляЛога);

	Команда = Новый Команда;
	
	Команда.УстановитьКоманду(Приложение);
	//Команда.УстановитьКодировкуВывода("Windows-1251");
	Команда.УстановитьКодировкуВывода(КодировкаТекста.OEM);
	//Команда.ДобавитьЛогВыводаКоманды("ktb.lib.irac");
	Команда.ДобавитьПараметры(Параметры);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	Команда.ПоказыватьВыводНемедленно(Ложь);
	КодВозврата = Команда.Исполнить();
	
	ВыводКоманды = Команда.ПолучитьВывод();

	Лог.Отладка("Получен код возврата %1", КодВозврата);
	
	Возврат КодВозврата;

КонецФункции // ЗапуститьИПодождать()

// Процедура добавляет описание параметра в соответствие
//   
// Параметры:
//   СтруктураПараметров 	- Соответствие	- коллекция для добавления описания параметра
//   ИмяПоляКлюча 			- Строка		- имя поля, значение которого будет использовано
//											  в качестве ключа возвращаемого соответствия
//   ИмяПараметра 			- Строка		- имя параметра объекта
//   ИмяПоляРАК 			- Строка		- имя поля, как оно возвращается утилитой администрирования кластера 1С
//   ЗначениеПоУмолчанию	- Произвольный	- значение поля объекта по умолчанию
//   ПараметрКоманды		- Строка		- строка параметра команды запуска утилиты администрирования кластера 1С
//   
Процедура ДобавитьПараметрОписанияОбъекта(СтруктураПараметров
										, Знач ИмяПоляКлюча
										, Знач ИмяПараметра
										, Знач ИмяПоляРАК
										, Знач ЗначениеПоУмолчанию = ""
										, Знач ПараметрКоманды = "") Экспорт

	Если НЕ ТипЗнч(СтруктураПараметров) = Тип("Соответствие") Тогда
		СтруктураПараметров = Новый Соответствие();
	КонецЕсли;

	ОписаниеПоля = Новый Структура();
	ОписаниеПоля.Вставить("ИмяПараметра"		, ИмяПараметра);
	ОписаниеПоля.Вставить("ИмяПоляРак"			, ИмяПоляРак);
	ОписаниеПоля.Вставить("ПараметрКоманды"		, ПараметрКоманды);
	ОписаниеПоля.Вставить("ЗначениеПоУмолчанию"	, ЗначениеПоУмолчанию);

	Если НЕ ЗначениеЗаполнено(ПараметрКоманды) Тогда
		ОписаниеПоля.ПараметрКоманды = "--" + ОписаниеПоля.ИмяПоляРАК;
	КонецЕсли;

	СтруктураПараметров.Вставить(ОписаниеПоля[ИмяПоляКлюча], ОписаниеПоля);

КонецПроцедуры // ДобавитьПараметрОписанияОбъекта()

// Функция возвращает значение указанного поля структуры/соответствия или значение по умолчанию
//   
// Параметры:
//   ПарамСтруктура			- Структура, Соответствие	- коллекция из которой возвращается значение
//   Ключ		 			- Произвольный				- значение ключа коллекции для получения значения
//   ЗначениеПоУмолчанию	- Произвольный				- значение, возвращаемое в случае,
//														  когда ключ отсутствует в коллекции
//   
// Возвращаемое значение:
//	Произвольный - значение элемента коллекции или значение по умолчанию
//
Функция ПолучитьЗначениеИзСтруктуры(ПарамСтруктура, Ключ, ЗначениеПоУмолчанию = Неопределено) Экспорт

	Если ТипЗнч(ПарамСтруктура) = Тип("Структура") Тогда
		Если ПарамСтруктура.Свойство("Ключ") Тогда
			Возврат ПарамСтруктура[Ключ];
		КонецЕсли;
	ИначеЕсли ТипЗнч(ПарамСтруктура) = Тип("Соответствие") Тогда
		Если НЕ ПарамСтруктура.Получить(Ключ) = Неопределено Тогда
			ПарамСтруктура.Получить(Ключ);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоУмолчанию;
			
КонецФункции // ПолучитьЗначениеИзСтруктуры()

// Функция преобразует переданный текст вывода команды в массив соответствий
// элементы массива создаются по блокам текста, разделенным пустой строкой
// пары <ключ, значение> структуры получаются для каждой строки с учетом разделителя ":"
//   
// Параметры:
//   ВыводКоманды			- Строка			- текст для разбора
//   
// Возвращаемое значение:
//	Массив (Структура) - результат разбора
//
Функция РазобратьВыводКоманды(Знач ВыводКоманды) Экспорт
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ВыводКоманды);

	МассивРезультатов = Новый Массив();
	Описание = Новый Соответствие();

	Для й = 1 По Текст.КоличествоСтрок() Цикл
		ТекстСтроки = Текст.ПолучитьСтроку(й);
		
		Если НЕ ЗначениеЗаполнено(ТекстСтроки) Тогда
			Если й = 1 Тогда
				Продолжить;
			КонецЕсли;
			МассивРезультатов.Добавить(Описание);
			Описание = Новый Соответствие();
			Продолжить;
		ИначеЕсли СтрНайти(ТекстСтроки, ":") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		СодержимоеСтроки = СтрРазделить(ТекстСтроки, ":");
		
		Описание.Вставить(СокрЛП(СодержимоеСтроки[0]), СокрЛП(СодержимоеСтроки[1]));

	КонецЦикла;

	Возврат МассивРезультатов;

КонецФункции // РазобратьВыводКоманды()
	
// Функция преобразует массив соответствий в иерархию соответствий в соответствии с указанным порядком полей
// копирования данных не происходят, в результирующее соответствие помещаются исходные элементы массива
//   
// Параметры:
//   МассивСоответствий 		- Массив(Соответствие)		- Данные для преобразования
//			<имя поля>				- Произвольный				- Значение элемента соответствия
//   ПоляУпорядочивания 		- Строка					- Список полей для упорядочивания данных (создания иерархии)
//															разделенных ","
//
// Возвращаемое значение:
//	Соответствие - иерархия соответствий по значениям полей упорядочивания
//		<значение поля упорядочивания>	- Соответствие,			- подчиненные данные по значениям
//										Массив(Соответствие)	следующего поля упорядочивания
//																или элементы исходного массива
//																на последнем уровне иерархии
//
Функция ИерархическоеПредставлениеМассиваСоответствий(МассивСоответствий, ПоляУпорядочивания) Экспорт

	МассивУпорядочивания = СтрРазделить(ПоляУпорядочивания, ",", Ложь);

	Если МассивУпорядочивания.Количество() = 0 Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Результат = Новый Соответствие();

	Для Каждого ТекЭлемент Из МассивСоответствий Цикл
		ЗаполняемыйСписок = Результат;
		Для Каждого ИмяПоля Из МассивУпорядочивания Цикл
			ЗначениеПоля = ТекЭлемент[ИмяПоля];
			ТекСписок = ЗаполняемыйСписок.Получить(ЗначениеПоля);
			Если ТекСписок = Неопределено Тогда
				ЗаполняемыйСписок.Вставить(ЗначениеПоля, Новый Соответствие());
				ТекСписок = ЗаполняемыйСписок[ЗначениеПоля];
			КонецЕсли;
			ЗаполняемыйСписок = ТекСписок;
		КонецЦикла;
		Если НЕ ТипЗнч(ТекСписок[ЗначениеПоля]) = Тип("Массив") Тогда
			ТекСписок[ЗначениеПоля] = Новый Массив();
		КонецЕсли;
		ТекСписок[ЗначениеПоля].Добавить(ТекЭлемент);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ИерархическоеПредставлениеМассиваСоответствий()

// Функция возвращает массив элементов (соответствий), отвечающих заданному отбору
//   
// Параметры:
//   МассивСоответствий	 	- Массив(Соответствие)		- Обрабатываемый массив
//   Отбор				 	- Соответствие				- Структура отбора вида <поле>:<значение>
//
// Возвращаемое значение:
//	Массив(Соответствие) - массив описание сеанса или массив описаний сеансов, соответствующие отбору
//
Функция ПолучитьЭлементыИзМассиваСоответствий(МассивСоответствий, Отбор) Экспорт

	Если НЕ ТипЗнч(Отбор) = Тип("Соответствие") Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Если Отбор.Количество() = 0 Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Результат = Новый Массив();

	Для Каждого ТекЭлемент Из МассивСоответствий Цикл
		ЭлементСоответствуетОтбору = Истина;
		Для Каждого ТекЭлементОтбора Из Отбор Цикл
			Если НЕ ТекЭлемент[ТекЭлементОтбора.Ключ] = ТекЭлементОтбора.Значение Тогда
				ЭлементСоответствуетОтбору = Ложь;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если НЕ ЭлементСоответствуетОтбору Тогда
			Продолжить;
		КонецЕсли;
		Результат.Добавить(ТекЭлемент);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ПолучитьЭлементыИзМассиваСоответствий()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   ОбъектДанных		 	- Произвольный	- данные для обновления
//   МоментАктуальности	 	- Число			- момент актуальности данных (мсек)
//   ПериодОбновления	 	- Число			- периодичность обновления (мсек)
//   ОбновитьПринудительно 	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(ОбъектДанных, МоментАктуальности, ПериодОбновления, ОбновитьПринудительно = Ложь) Экспорт

	Возврат (ОбновитьПринудительно
		ИЛИ ОбъектДанных = Неопределено
		ИЛИ НЕ (ПериодОбновления < (МоментАктуальности - ТекущаяУниверсальнаяДатаВМиллисекундах())));

КонецФункции // ТребуетсяОбновление()

// Диагностическая процедура для вывода списка полей объекта
//   
// Параметры:
//   ОбъектДанных		 	- Произвольный	- объект, поля которого требуется вывести
//
Процедура ВывестиПоляОбъекта(Знач ОбъектДанных) Экспорт

	Коллекция = "";
	Если ТипЗнч(ОбъектДанных) = Тип("Массив") Тогда
		Если ОбъектДанных.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;

		Коллекция = СокрЛП(ТипЗнч(ОбъектДанных)) + "\";
		ОбъектДанных = ОбъектДанных[0];
	КонецЕсли;

	Лог.Информация("Поля объекта ""%1%2"":", Коллекция, СокрЛП(ТипЗнч(ОбъектДанных)));

	Для Каждого ТекПоле Из ОбъектДанных Цикл
		Сообщить(СокрЛП(ТекПоле.Ключ) + ":" + СокрЛП(ТекПоле.Значение));
	КонецЦикла;

КонецПроцедуры // ВывестиПоляОбъекта()

// Процедура инициализации переменных модуля
//   
Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог("ktb.lib.irac");

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

	ВерсияПлатформы = "";

	ПутьКПлатформе1С(ПолучитьПутьКВерсииПлатформы("8.3"));

КонецПроцедуры // Инициализация()

Инициализация();
