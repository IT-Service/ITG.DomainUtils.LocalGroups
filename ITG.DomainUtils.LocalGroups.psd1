#
# Манифест модуля для модуля "ITG.DomainUtils.LocalGroups".
#
# Создано: Sergey S. Betke
#
# Дата создания: 27.11.2013
#
# Архив проекта: https://github.com/IT-Service/ITG.DomainUtils.LocalGroups
#

@{

# Файл модуля скрипта или двоичного модуля, связанный с данным манифестом
RootModule = 'ITG.DomainUtils.LocalGroups.psm1'

# Номер версии данного модуля.
ModuleVersion = '2.0.0'

# Уникальный идентификатор данного модуля
GUID = '820B6CFA-3D70-42E4-8C6E-276742D0CC4B'

# Автор данного модуля
Author = 'Sergey S. Betke'

# Компания, создавшая данный модуль, или его поставщик
CompanyName = 'IT-Service.Nov.RU'

# Заявление об авторских правах на модуль
Copyright = '(c) 2013 Sergey S. Betke. All rights reserved.'

# Описание функций данного модуля
Description = @'
Данный модуль предоставляет набор командлет для автоматизации ряда операций с локальными группами безопасности.

Тестирование модуля и подготовка к публикации
---------------------------------------------

Для сборки модуля использую проект [psake](https://github.com/psake/psake). Для инициирования сборки используйте сценарий `build.ps1`.
Для модульных тестов использую проект [pester](https://github.com/pester/pester).

'@

# Минимальный номер версии обработчика Windows PowerShell, необходимой для работы данного модуля
PowerShellVersion = '3.0'

# Имя узла Windows PowerShell, необходимого для работы данного модуля
PowerShellHostName = ''

# Минимальный номер версии узла Windows PowerShell, необходимой для работы данного модуля
PowerShellHostVersion = ''

# Минимальный номер версии компонента .NET Framework, необходимой для данного модуля
DotNetFrameworkVersion = '4.0'

# Минимальный номер версии среды CLR (общеязыковой среды выполнения), необходимой для работы данного модуля
CLRVersion = '4.0'

# Архитектура процессора (нет, X86, AMD64, IA64), необходимая для работы модуля
ProcessorArchitecture = ''

# Модули, которые необходимо импортировать в глобальную среду перед импортированием данного модуля
RequiredModules = @(
)

# Сборки, которые должны быть загружены перед импортированием данного модуля
RequiredAssemblies = @(
	'System.DirectoryServices.AccountManagement'
)

# Файлы скрипта (.ps1), которые запускаются в среде вызывающей стороны перед импортированием данного модуля
ScriptsToProcess = @()

# Файлы типа (.ps1xml), которые загружаются при импорте данного модуля
TypesToProcess = @()

# Файлы формата (PS1XML-файлы), которые загружаются при импорте данного модуля
FormatsToProcess = @()

# Модули для импортирования в модуль, указанный в параметре ModuleToProcess, в качестве вложенных модулей
NestedModules = @()

# Функции для экспорта из данного модуля
FunctionsToExport = '*'

# Командлеты для экспорта из данного модуля
CmdletsToExport = '*'

# Переменные для экспорта из данного модуля
VariablesToExport = '*'

# Псевдонимы для экспорта из данного модуля
AliasesToExport = '*'

# Список всех модулей, входящих в пакет данного модуля
ModuleList = @()

# Список всех файлов, входящих в пакет данного модуля
FileList = `
	'ITG.DomainUtils.LocalGroups.psm1' `
,   'ITG.DomainUtils.LocalGroups.psd1' `
,	'ITG.DomainUtils.LocalGroups.ps1' `
;

# Личные данные, передаваемые в модуль, указанный в параметре ModuleToProcess
PrivateData = @{
	ReadmeURL = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups';
}

}