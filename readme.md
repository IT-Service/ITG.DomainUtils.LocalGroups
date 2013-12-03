﻿ITG.DomainUtils.LocalGroups
===========================

Данный модуль предоставляет набор командлет для автоматизации ряда операций с локальными группами безопасности.

Тестирование модуля и подготовка к публикации
---------------------------------------------

Для сборки модуля использую проект [psake](https://github.com/psake/psake). Для инициирования сборки используйте сценарий `build.ps1`.
Для модульных тестов использую проект [pester](https://github.com/pester/pester).


Версия модуля: **2.0.0**

ПОДДЕРЖИВАЮТСЯ КОМАНДЛЕТЫ
-------------------------

### ADSIPath

#### КРАТКОЕ ОПИСАНИЕ [ConvertTo-ADSIPath][]

Конвертирует идентификатор переданного объекта безопасности в ADSI путь.

	ConvertTo-ADSIPath -Path <String> <CommonParameters>

	ConvertTo-ADSIPath -DistinguishedName <String> <CommonParameters>

	ConvertTo-ADSIPath -SID <String> <CommonParameters>

### Group

#### КРАТКОЕ ОПИСАНИЕ [Get-Group][]

Возвращает локальную группу безопасности.

	Get-Group -Sid <SecurityIdentifier> <CommonParameters>

	Get-Group [[-Filter] <String>] [-Description <String>] [-DisplayName <String>] <CommonParameters>

	Get-Group [-Name <String>] <CommonParameters>

	Get-Group [-UserPrincipalName <String>] <CommonParameters>

	Get-Group [-SamAccountName <String>] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [New-Group][]

Создаёт локальную группу безопасности.

	New-Group [-Name] <String> [-Description <String>] [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

### LocalGroup

#### КРАТКОЕ ОПИСАНИЕ [Remove-LocalGroup][]

Удаляет локальную группу безопасности.

	Remove-LocalGroup [-Name] <String> [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Test-LocalGroup][]

Проверяет наличие локальной группы безопасности.

	Test-LocalGroup [-Name] <String> <CommonParameters>

### LocalGroupMember

#### КРАТКОЕ ОПИСАНИЕ [Add-LocalGroupMember][]

Добавляет учётные записи и/или группы в указанную локальную группу безопасности.

	Add-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Get-LocalGroupMember][]

Возвращает членов локальной группы безопасности.

	Get-LocalGroupMember [-Identity] <DirectoryEntry> [-Recursive] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Remove-LocalGroupMember][]

Удаляет учётные записи и/или группы из указанной локальной группы безопасности.

	Remove-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Test-LocalGroupMember][]

Проверяет наличие учётных записей в указанной локальной группе безопасности.

	Test-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-Recursive] <CommonParameters>

ОПИСАНИЕ
--------

#### ConvertTo-ADSIPath

Конвертирует идентификатор переданного объекта безопасности в ADSI путь.

##### СИНТАКСИС

	ConvertTo-ADSIPath -Path <String> <CommonParameters>

	ConvertTo-ADSIPath -DistinguishedName <String> <CommonParameters>

	ConvertTo-ADSIPath -SID <String> <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Учётные записи и группы, идентификатор которых следует проверить / преобразовать.
- [Microsoft.ActiveDirectory.Management.ADUser][]
Учётные записи и группы AD, DN которых следует преобразовать.

##### ВЫХОДНЫЕ ДАННЫЕ

- [System.String][]
ADSI путь к указанным объектам безопасности.

##### ПАРАМЕТРЫ

- `[String] Path`
	ADSI путь, преобразование не требуется
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] DistinguishedName`
	DN для преобразования в ADSI Path
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] SID`
	SID
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. В результате получим `WinNT://CSM/admin-sergey.s.betke`.

		Get-ADUser 'admin-sergey.s.betke' | ConvertTo-ADSIPath;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#ConvertTo-ADSIPath)
- [ADS_NAME_TYPE_ENUM][]

#### Get-Group

[Get-Group][] возвращает локальную группу (или группы) безопасности с указанными параметрами.

##### ПСЕВДОНИМЫ

Get-LocalGroup

##### СИНТАКСИС

	Get-Group -Sid <SecurityIdentifier> <CommonParameters>

	Get-Group [[-Filter] <String>] [-Description <String>] [-DisplayName <String>] <CommonParameters>

	Get-Group [-Name <String>] <CommonParameters>

	Get-Group [-UserPrincipalName <String>] <CommonParameters>

	Get-Group [-SamAccountName <String>] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Объект, определяющий параметры поиска.

##### ВЫХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Объект, представляющий группу безопасности.

##### ПАРАМЕТРЫ

- `[String] Filter`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? 2
	* Значение по умолчанию `*`
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[String] Description`
	Описание искомой группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] DisplayName`
	Отображаемое имя искомой группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] Name`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] UserPrincipalName`
	Имя участника-пользователя искомой группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] SamAccountName`
	Имя учетной записи искомой группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[SecurityIdentifier] Sid`
	Идентификатор безопасности искомой группы безопасности
	* Тип: [System.Security.Principal.SecurityIdentifier][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Возвращает все локальные группы безопасности.

		Get-Group -Filter '*';

2. Возвращает группу безопасности Пользователи.

		Get-Group -Name 'Пользователи';

3. Возвращает локальные группы безопасности: Администраторы и другие, имена которых начинаются на 'Адм'.

		Get-Group -Filter 'Адм*';

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-Group)

#### New-Group

[New-Group][] создаёт локальную группу безопасности с указанными аттрибутами.

##### ПСЕВДОНИМЫ

New-LocalGroup

##### СИНТАКСИС

	New-Group [-Name] <String> [-Description <String>] [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### ВЫХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Созданная группа безопасности.

##### ПАРАМЕТРЫ

- `[String] Name`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Псевдонимы: SamAccountName
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByValue, ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[String] Description`
	Описание группы безопасности
	* Тип: [System.String][]
	* Требуется? нет
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] PassThru`
	Передавать ли созданные группы далее по конвейеру
	

- `[SwitchParameter] WhatIf`
	* Псевдонимы: wi

- `[SwitchParameter] Confirm`
	* Псевдонимы: cf

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Создаёт локальную группу безопасности.

		New-Group -Name 'MyUsers' -Description 'Users of my application';

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#New-Group)

#### Remove-LocalGroup

[Remove-LocalGroup][] удаляет локальную группу (или группы) безопасности, переданные по конвейеру.

##### СИНТАКСИС

	Remove-LocalGroup [-Name] <String> [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Группа безопасности.

##### ПАРАМЕТРЫ

- `[String] Name`
	Группа безопасности к удалению
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Псевдонимы: Identity
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] WhatIf`
	* Псевдонимы: wi

- `[SwitchParameter] Confirm`
	* Псевдонимы: cf

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Удаляет группу безопасности 'Пользователи'.

		Get-LocalGroup -Name 'Пользователи' | Remove-LocalGroup;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroup)

#### Test-LocalGroup

Проверяет наличие локальной группы безопасности.

##### СИНТАКСИС

	Test-LocalGroup [-Name] <String> <CommonParameters>

##### ВЫХОДНЫЕ ДАННЫЕ

- System.Bool

##### ПАРАМЕТРЫ

- `[String] Name`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Псевдонимы: Identity
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByValue, ByPropertyName)
	* Принимать подстановочные знаки? нет

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroup)

#### Add-LocalGroupMember

Добавляет учётные записи и/или группы в указанную локальную группу безопасности.
В качестве добавляемых учётных записей и групп могут быть использованы как локальные
учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
`Get-ADGroup`).

##### СИНТАКСИС

	Add-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Учётные записи и группы, которые необходимо включить в локальную группу безопасности.
- [Microsoft.ActiveDirectory.Management.ADUser][]
Учётные записи AD, которые необходимо включить в локальную группу безопасности.
- [Microsoft.ActiveDirectory.Management.ADGroup][]
Группы AD, которые необходимо включить в локальную группу безопасности.

##### ПАРАМЕТРЫ

- `[DirectoryEntry] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.DirectoryEntry
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Object] Identity`
	Объект безопасности для добавления в группу
	* Тип: [System.Object][]
	* Псевдонимы: User, Member
	* Требуется? да
	* Позиция? 3
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] PassThru`
	Передавать ли учётную запись далее по конвейеру
	

- `[SwitchParameter] WhatIf`
	* Псевдонимы: wi

- `[SwitchParameter] Confirm`
	* Псевдонимы: cf

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Добавляем указанного пользователя домена в локальную группы безопасности
"Пользователи".

		Get-ADUser 'admin-sergey.s.betke' | Add-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи );

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-LocalGroupMember)

#### Get-LocalGroupMember

[Get-LocalGroupMember][] возвращает членов указанной локальной группы безопасности.
В том числе - и с учётом транзитивности при указании флага `-Recursive`

##### СИНТАКСИС

	Get-LocalGroupMember [-Identity] <DirectoryEntry> [-Recursive] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Группа безопасности.

##### ВЫХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Члены указанной группы безопасности.
- PSObject
Для групп типа `NT AUTHORITY/ИНТЕРАКТИВНЫЕ` возвращён будет объект,
содержащий свойства `Path`, `Name`, `objectSid`, `groupType`.
`SchemaClassName` будет установлен в `Group`, `AuthenticationType` в `Secure`.
Дополнительно будет установлен аттрибут `NtAuthority` в `$true`.

##### ПАРАМЕТРЫ

- `[DirectoryEntry] Identity`
	Группа безопасности
	* Тип: System.DirectoryServices.DirectoryEntry
	* Псевдонимы: Group
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] Recursive`
	Запросить членов группы с учётом транзитивности
	

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Возвращает всех членов группы Пользователи с учётом транзитивности.

		Get-LocalGroup -Name Пользователи | Get-LocalGroupMember -Recursive;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-LocalGroupMember)

#### Remove-LocalGroupMember

Удаляет учётные записи и/или группы из указанной локальной группы безопасности.
В качестве удаляемых членов могут быть использованы как локальные
учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
`Get-ADGroup`).

##### СИНТАКСИС

	Remove-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Учётные записи и группы, которые необходимо удалить из указанной группы.
- [Microsoft.ActiveDirectory.Management.ADUser][]
Учётные записи AD, которые необходимо удалить из указанной группы.
- [Microsoft.ActiveDirectory.Management.ADGroup][]
Группы AD, которые необходимо удалить из указанной группы.

##### ПАРАМЕТРЫ

- `[DirectoryEntry] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.DirectoryEntry
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Object] Identity`
	Объект безопасности для удаления из группы
	* Тип: [System.Object][]
	* Псевдонимы: User, Member
	* Требуется? да
	* Позиция? 3
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] PassThru`
	Передавать ли учётную запись далее по конвейеру
	

- `[SwitchParameter] WhatIf`
	* Псевдонимы: wi

- `[SwitchParameter] Confirm`
	* Псевдонимы: cf

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".

		Get-ADUser 'admin-sergey.s.betke' | Remove-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи );

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroupMember)

#### Test-LocalGroupMember

[Get-LocalGroupMember][] проверяет наличие учётных записей в указанной
локальной группе безопасности.
В том числе - и с учётом транзитивности при указании флага `-Recursive`

##### СИНТАКСИС

	Test-LocalGroupMember [-Group] <DirectoryEntry> [-Identity] <Object> [-Recursive] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.DirectoryEntry
Учётные записи и группы, членство которых необходимо проверить в локальной группе безопасности.
- [Microsoft.ActiveDirectory.Management.ADUser][]
Учётные записи AD, членство которых необходимо проверить в локальной группе безопасности.
- [Microsoft.ActiveDirectory.Management.ADGroup][]
Группы AD, членство которых необходимо проверить в локальной группе безопасности.

##### ВЫХОДНЫЕ ДАННЫЕ

- Bool
Наличие ( `$true` ) или отсутствие ( `$false` ) указанных объектов в указанной группе

##### ПАРАМЕТРЫ

- `[DirectoryEntry] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.DirectoryEntry
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Object] Identity`
	Объект безопасности для проверки членства в указанной группе
	* Тип: [System.Object][]
	* Псевдонимы: User, Member
	* Требуется? да
	* Позиция? 3
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] Recursive`
	Запросить членов группы с учётом транзитивности
	

- `<CommonParameters>`
	Этот командлет поддерживает общие параметры: Verbose, Debug,
	ErrorAction, ErrorVariable, WarningAction, WarningVariable,
	OutBuffer и OutVariable. Для получения дополнительных сведений см. раздел
	[about_CommonParameters][].


##### ПРИМЕРЫ

1. Проверяем, является ли пользователь `username` членом локальной группы безопасности
Пользователи с учётом транзитивности.

		Test-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи ) -Member ( Get-ADUser 'admin-sergey.s.betke' ) -Recursive;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroupMember)


[about_CommonParameters]: <http://go.microsoft.com/fwlink/?LinkID=113216> "Describes the parameters that can be used with any cmdlet."
[Add-LocalGroupMember]: <#add-localgroupmember> "Добавляет учётные записи и/или группы в указанную локальную группу безопасности."
[ADS_NAME_TYPE_ENUM]: <http://msdn.microsoft.com/en-us/library/windows/desktop/aa772267.aspx> 
[ConvertTo-ADSIPath]: <#convertto-adsipath> "Конвертирует идентификатор переданного объекта безопасности в ADSI путь."
[Get-Group]: <#get-group> "Возвращает локальную группу безопасности."
[Get-LocalGroupMember]: <#get-localgroupmember> "Возвращает членов локальной группы безопасности."
[Microsoft.ActiveDirectory.Management.ADGroup]: <http://msdn.microsoft.com/ru-ru/library/microsoft.activedirectory.management.adgroup.aspx> "ADGroup Class (Microsoft.ActiveDirectory.Management)"
[Microsoft.ActiveDirectory.Management.ADUser]: <http://msdn.microsoft.com/ru-ru/library/microsoft.activedirectory.management.aduser.aspx> "ADUser Class (Microsoft.ActiveDirectory.Management)"
[New-Group]: <#new-group> "Создаёт локальную группу безопасности."
[Remove-LocalGroup]: <#remove-localgroup> "Удаляет локальную группу безопасности."
[Remove-LocalGroupMember]: <#remove-localgroupmember> "Удаляет учётные записи и/или группы из указанной локальной группы безопасности."
[System.Object]: <http://msdn.microsoft.com/ru-ru/library/system.object.aspx> "Object Class (System)"
[System.Security.Principal.SecurityIdentifier]: <http://msdn.microsoft.com/ru-ru/library/system.security.principal.securityidentifier.aspx> "SecurityIdentifier Class (System.Security.Principal)"
[System.String]: <http://msdn.microsoft.com/ru-ru/library/system.string.aspx> "String Class (System)"
[Test-LocalGroup]: <#test-localgroup> "Проверяет наличие локальной группы безопасности."
[Test-LocalGroupMember]: <#test-localgroupmember> "Проверяет наличие учётных записей в указанной локальной группе безопасности."

---------------------------------------

Генератор: [ITG.Readme](https://github.com/IT-Service/ITG.Readme "Модуль PowerShell для генерации readme для модулей PowerShell").

