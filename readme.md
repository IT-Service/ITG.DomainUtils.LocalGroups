ITG.DomainUtils.LocalGroups
===========================

Данный модуль предоставляет набор командлет для автоматизации ряда операций с локальными группами безопасности.

Тестирование модуля и подготовка к публикации
---------------------------------------------

Для сборки модуля использую проект [psake](https://github.com/psake/psake). Для инициирования сборки используйте сценарий `build.ps1`.
Для модульных тестов использую проект [pester](https://github.com/pester/pester).


Версия модуля: **2.0.0**

ПОДДЕРЖИВАЮТСЯ КОМАНДЛЕТЫ
-------------------------

### Group

#### КРАТКОЕ ОПИСАНИЕ [Get-Group][]

Возвращает локальную группу безопасности.

	Get-Group -Sid <SecurityIdentifier> <CommonParameters>

	Get-Group [[-Filter] <String>] [-Description <String>] <CommonParameters>

	Get-Group [-Name <String>] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [New-Group][]

Создаёт локальную группу безопасности.

	New-Group [-Name] <String> [-Description <String>] [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Remove-Group][]

Удаляет локальную группу безопасности.

	Remove-Group -Sid <SecurityIdentifier> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-Group [-Name] <String> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-Group -Identity <GroupPrincipal> [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Rename-Group][]

Переименовывает локальную группу безопасности.

	Rename-Group -Identity <GroupPrincipal> [-NewName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Rename-Group [-Name] <String> [-NewName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Test-Group][]

Проверяет наличие локальной группы безопасности.

	Test-Group -Sid <SecurityIdentifier> <CommonParameters>

	Test-Group [-Name] <String> <CommonParameters>

### GroupMember

#### КРАТКОЕ ОПИСАНИЕ [Add-GroupMember][]

Добавляет учётные записи и/или группы в указанную локальную группу безопасности.

	Add-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Get-GroupMember][]

Возвращает членов локальной группы безопасности.

	Get-GroupMember [-Group] <GroupPrincipal> [-Recursive] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Remove-GroupMember][]

Удаляет учётные записи и/или группы из указанной локальной группы безопасности.

	Remove-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-WhatIf] [-Confirm] <CommonParameters>

#### КРАТКОЕ ОПИСАНИЕ [Test-GroupMember][]

Проверяет наличие учётных записей в указанной локальной группе безопасности.

	Test-GroupMember [-Group] <GroupPrincipal> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-Recursive] <CommonParameters>

ОПИСАНИЕ
--------

#### Get-Group

[Get-Group][] возвращает локальную группу (или группы) безопасности с указанными параметрами.

##### ПСЕВДОНИМЫ

Get-LocalGroup

##### СИНТАКСИС

	Get-Group -Sid <SecurityIdentifier> <CommonParameters>

	Get-Group [[-Filter] <String>] [-Description <String>] <CommonParameters>

	Get-Group [-Name <String>] <CommonParameters>

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

- `[String] Name`
	Идентификатор группы безопасности
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

#### Remove-Group

[Remove-Group][] удаляет локальную группу (или группы) безопасности, переданную по конвейеру.

##### ПСЕВДОНИМЫ

Remove-LocalGroup

##### СИНТАКСИС

	Remove-Group -Sid <SecurityIdentifier> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-Group [-Name] <String> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-Group -Identity <GroupPrincipal> [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Группа безопасности, которую следует удалить.

##### ПАРАМЕТРЫ

- `[String] Name`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[SecurityIdentifier] Sid`
	Идентификатор безопасности искомой группы безопасности
	* Тип: [System.Security.Principal.SecurityIdentifier][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[GroupPrincipal] Identity`
	Группа безопасности к удалению
	Идентификатор группы безопасности
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
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

1. Удаляет группы безопасности, имена которых начинаются с 'test'.

		Get-Group -Filter 'test*' | Remove-Group -Verbose;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-Group)

#### Rename-Group

[Rename-Group][] переименовывает локальную группу безопасности, переданную по конвейеру.

##### ПСЕВДОНИМЫ

Rename-LocalGroup

##### СИНТАКСИС

	Rename-Group -Identity <GroupPrincipal> [-NewName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Rename-Group [-Name] <String> [-NewName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Группа безопасности, которую следует переименовать.

##### ПАРАМЕТРЫ

- `[String] Name`
	Идентификатор группы безопасности к переименованию
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByPropertyName)
	* Принимать подстановочные знаки? нет

- `[GroupPrincipal] Identity`
	Группа безопасности к переименованию
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[String] NewName`
	Новый идентификатор группы безопасности
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? 3
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[SwitchParameter] PassThru`
	Передавать ли переименованные группы далее по конвейеру
	

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

1. Переименуем группу 'test' в 'test2'.

		Get-Group 'test' | Rename-Group -NewName 'test2' -Verbose;

2. Переименуем группу 'test' в 'test2'.

		Rename-Group -Identity (Get-Group 'test') -NewName 'test2' -WhatIf;

3. Переименуем группу 'test' в 'test2'.

		Rename-Group 'test' 'test2' -Verbose;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Rename-Group)

#### Test-Group

Проверяет наличие локальной группы безопасности.

##### ПСЕВДОНИМЫ

Test-LocalGroup

##### СИНТАКСИС

	Test-Group -Sid <SecurityIdentifier> <CommonParameters>

	Test-Group [-Name] <String> <CommonParameters>

##### ВЫХОДНЫЕ ДАННЫЕ

- System.Bool

##### ПАРАМЕТРЫ

- `[String] Name`
	Идентификатор группы безопасности
	* Тип: [System.String][]
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? true (ByValue, ByPropertyName)
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


##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-Group)

#### Add-GroupMember

Добавляет учётные записи и/или группы в указанную локальную группу безопасности.
В качестве добавляемых учётных записей и групп могут быть использованы как локальные
учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
`Get-ADGroup`).

##### ПСЕВДОНИМЫ

Add-LocalGroupMember

##### СИНТАКСИС

	Add-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

	Add-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.Principal
Учётные записи и группы, которые необходимо включить в локальную группу безопасности.
- [Microsoft.ActiveDirectory.Management.ADAccount][]
Учётные записи AD, которые необходимо включить в локальную группу безопасности.
- System.DirectoryServices.DirectoryEntry
Учётные записи и группы ADSI, которые необходимо включить в локальную группу безопасности.

##### ПАРАМЕТРЫ

- `[GroupPrincipal] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Principal[]] Member`
	Объект безопасности для добавления в группу
	* Тип: System.DirectoryServices.AccountManagement.Principal[]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[ADAccount[]] ADMember`
	Объект безопасности AD для добавления в группу
	* Тип: [Microsoft.ActiveDirectory.Management.ADAccount][][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[DirectoryEntry[]] ADSIMember`
	Объект безопасности ADSI для добавления в группу
	* Тип: System.DirectoryServices.DirectoryEntry[]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[Array] OtherMember`
	Объект безопасности в любом из трёх выше указанных типов для добавления в группу
	Использовать данный параметр стоит только для обеспечения совместимости при переходе
	от использования одного набора классов к другому.
	* Тип: [System.Array][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? false
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

		Get-ADUser 'admin-sergey.s.betke' | Add-GroupMember -Group ( Get-Group -Name Пользователи );

2. Добавляем указанного локального пользователя в локальную группы безопасности
"Пользователи".

		Get-ADGroup 'Администраторы' | Add-GroupMember -Group ( Get-Group -Name Пользователи );

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-GroupMember)

#### Get-GroupMember

[Get-GroupMember][] возвращает членов указанной локальной группы безопасности.
В том числе - и с учётом транзитивности при указании флага `-Recursive`

##### ПСЕВДОНИМЫ

Get-LocalGroupMember

##### СИНТАКСИС

	Get-GroupMember [-Group] <GroupPrincipal> [-Recursive] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.GroupPrincipal
Группа безопасности.

##### ВЫХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.Principal
Члены указанной группы безопасности.

##### ПАРАМЕТРЫ

- `[GroupPrincipal] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
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

		Get-Group -Name Пользователи | Get-LocalGroupMember -Recursive;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-GroupMember)

#### Remove-GroupMember

Удаляет учётные записи и/или группы из указанной локальной группы безопасности.
В качестве удаляемых членов могут быть использованы как локальные
учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
`Get-ADGroup`).

##### ПСЕВДОНИМЫ

Remove-LocalGroupMember

##### СИНТАКСИС

	Remove-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-WhatIf] [-Confirm] <CommonParameters>

	Remove-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-WhatIf] [-Confirm] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.Principal
Учётные записи и группы, которые необходимо удалить из указанной группы.
- [Microsoft.ActiveDirectory.Management.ADAccount][]
Учётные записи AD, которые необходимо удалить из указанной группы (полученные
через `Get-ADUser`, `Get-ADGroup`).
- System.DirectoryServices.DirectoryEntry
Учётные записи и группы, которые необходимо удалить из указанной группы.

##### ПАРАМЕТРЫ

- `[GroupPrincipal] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Principal[]] Member`
	Объект безопасности для удаления из группы
	* Тип: System.DirectoryServices.AccountManagement.Principal[]
	* Псевдонимы: User
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[ADAccount[]] ADMember`
	Объект безопасности AD для удаления из группы
	* Тип: [Microsoft.ActiveDirectory.Management.ADAccount][][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[DirectoryEntry[]] ADSIMember`
	Объект безопасности ADSI для добавления в группу
	* Тип: System.DirectoryServices.DirectoryEntry[]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[Array] OtherMember`
	Объект безопасности в любом из трёх выше указанных типов для добавления в группу
	Использовать данный параметр стоит только для обеспечения совместимости при переходе
	от использования одного набора классов к другому.
	* Тип: [System.Array][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? false
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

1. Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".

		Get-ADUser 'admin-sergey.s.betke' | Remove-GroupMember -Group ( Get-LocalGroup -Name Пользователи ) -Verbose;

2. Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".

		Remove-GroupMember -Group ( Get-LocalGroup -Name Пользователи ) -OtherMember ( Get-ADUser 'admin-sergey.s.betke' ) -Verbose;

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-GroupMember)

#### Test-GroupMember

[Test-GroupMember][] проверяет наличие учётных записей в указанной
локальной группе безопасности.
В том числе - и с учётом транзитивности при указании флага `-Recursive`

##### ПСЕВДОНИМЫ

Test-LocalGroupMember

##### СИНТАКСИС

	Test-GroupMember [-Group] <GroupPrincipal> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -Member <Principal[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -ADMember <ADAccount[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -ADSIMember <DirectoryEntry[]> [-Recursive] <CommonParameters>

	Test-GroupMember [-Group] <GroupPrincipal> -OtherMember <Array> [-Recursive] <CommonParameters>

##### ВХОДНЫЕ ДАННЫЕ

- System.DirectoryServices.AccountManagement.Principal
Учётные записи и группы, членство которых необходимо проверить в локальной группе безопасности.
- [Microsoft.ActiveDirectory.Management.ADAccount][]
Учётные записи AD, членство которых необходимо проверить в локальной группе безопасности.
- System.DirectoryServices.DirectoryEntry
Учётные записи и группы ADSI, членство которых необходимо проверить в локальной группе безопасности.

##### ВЫХОДНЫЕ ДАННЫЕ

- Bool
Наличие ( `$true` ) или отсутствие ( `$false` ) указанных объектов в указанной группе

##### ПАРАМЕТРЫ

- `[GroupPrincipal] Group`
	Группа безопасности
	* Тип: System.DirectoryServices.AccountManagement.GroupPrincipal
	* Требуется? да
	* Позиция? 2
	* Принимать входные данные конвейера? false
	* Принимать подстановочные знаки? нет

- `[Principal[]] Member`
	Объект безопасности для проверки членства в группе
	* Тип: System.DirectoryServices.AccountManagement.Principal[]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[ADAccount[]] ADMember`
	Объект безопасности AD для проверки членства в группе
	* Тип: [Microsoft.ActiveDirectory.Management.ADAccount][][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[DirectoryEntry[]] ADSIMember`
	Объект безопасности ADSI для проверки членства в группе
	* Тип: System.DirectoryServices.DirectoryEntry[]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? true (ByValue)
	* Принимать подстановочные знаки? нет

- `[Array] OtherMember`
	Объект безопасности в любом из трёх выше указанных типов для проверки членства в группе.
	Использовать данный параметр стоит только для обеспечения совместимости при переходе
	от использования одного набора классов к другому.
	* Тип: [System.Array][]
	* Требуется? да
	* Позиция? named
	* Принимать входные данные конвейера? false
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

		Get-ADUser 'admin-sergey.s.betke' | Test-GroupMember -Group ( Get-Group -Name Пользователи ) -Recursive;

2. Проверяем, является ли пользователь `username` членом локальной группы безопасности
Пользователи.

		Test-GroupMember -Group ( Get-Group -Name Пользователи ) -Member (Get-ADUser 'admin-sergey.s.betke');

3. Проверяем, является ли пользователь `username` членом локальной группы безопасности
Пользователи с учётом транзитивности.

		( [ADSI]'WinNT://csm/admin-sergey.s.betke' ) | Test-GroupMember -Group ( Get-Group -Name Пользователи );

##### ССЫЛКИ ПО ТЕМЕ

- [Интернет версия](https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-GroupMember)


[about_CommonParameters]: <http://go.microsoft.com/fwlink/?LinkID=113216> "Describes the parameters that can be used with any cmdlet."
[Add-GroupMember]: <#add-groupmember> "Добавляет учётные записи и/или группы в указанную локальную группу безопасности."
[Get-Group]: <#get-group> "Возвращает локальную группу безопасности."
[Get-GroupMember]: <#get-groupmember> "Возвращает членов локальной группы безопасности."
[Microsoft.ActiveDirectory.Management.ADAccount]: <http://msdn.microsoft.com/ru-ru/library/microsoft.activedirectory.management.adaccount.aspx> "ADAccount Class (Microsoft.ActiveDirectory.Management)"
[New-Group]: <#new-group> "Создаёт локальную группу безопасности."
[Remove-Group]: <#remove-group> "Удаляет локальную группу безопасности."
[Remove-GroupMember]: <#remove-groupmember> "Удаляет учётные записи и/или группы из указанной локальной группы безопасности."
[Rename-Group]: <#rename-group> "Переименовывает локальную группу безопасности."
[System.Array]: <http://msdn.microsoft.com/ru-ru/library/system.array.aspx> "Array Class (System)"
[System.Security.Principal.SecurityIdentifier]: <http://msdn.microsoft.com/ru-ru/library/system.security.principal.securityidentifier.aspx> "SecurityIdentifier Class (System.Security.Principal)"
[System.String]: <http://msdn.microsoft.com/ru-ru/library/system.string.aspx> "String Class (System)"
[Test-Group]: <#test-group> "Проверяет наличие локальной группы безопасности."
[Test-GroupMember]: <#test-groupmember> "Проверяет наличие учётных записей в указанной локальной группе безопасности."

---------------------------------------

Генератор: [ITG.Readme](https://github.com/IT-Service/ITG.Readme "Модуль PowerShell для генерации readme для модулей PowerShell").

