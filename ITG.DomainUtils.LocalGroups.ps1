Function New-Group {
<#
.Synopsis
	Создаёт локальную группу безопасности. 
.Description
	New-Group создаёт локальную группу безопасности с указанными аттрибутами.
.Outputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Созданная группа безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#New-Group
.Example
	New-Group -Name 'MyUsers' -Description 'Users of my application';
	Создаёт локальную группу безопасности.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#New-Group'
	)]

	param (
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'GroupProperties'
		)]
        [Alias( 'SamAccountName' )]
		[String]
		$Name
	,
		# Описание группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'GroupProperties'
		)]
		[String]
		$Description
	,
		# Передавать ли созданные группы далее по конвейеру
		[Switch]
		$PassThru
	)

	begin {
		try {
			$ComputerContext = New-Object -Type System.DirectoryServices.AccountManagement.PrincipalContext `
				-ArgumentList ( [System.DirectoryServices.AccountManagement.ContextType]::Machine )  `
			;
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
			$Params = @{};
			foreach( $Param in ( Get-Command New-Group ).Parameters.Values ) {
				if (
					$Param.ParameterSets.ContainsKey( 'GroupProperties' ) `
					-and $PSBoundParameters.ContainsKey( $Param.Name )
				) {
					$Params.( $Param.Name ) = $PSBoundParameters.( $Param.Name );
				};
			};
			[System.DirectoryServices.AccountManagement.GroupPrincipal] $Group = New-Object -Type System.DirectoryServices.AccountManagement.GroupPrincipal `
				-ArgumentList ( $ComputerContext ) `
				-Property $Params `
			;
			$Group.IsSecurityGroup = $true;
			if ( $PSCmdlet.ShouldProcess( "$Name" ) ) {
				$Group.Save();
			};
			if ( $PassThru ) { return $Group };
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

New-Alias -Name New-LocalGroup -Value New-Group -Force;

Function Get-Group {
<#
.Synopsis
	Возвращает локальную группу безопасности. 
.Description
	Get-Group возвращает локальную группу (или группы) безопасности с указанными параметрами.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Объект, определяющий параметры поиска.
.Outputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Объект, представляющий группу безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-Group
.Example
	Get-Group -Filter '*';
	Возвращает все локальные группы безопасности.
.Example
	Get-Group -Name 'Пользователи';
	Возвращает группу безопасности Пользователи.
.Example
	Get-Group -Filter 'Адм*';
	Возвращает локальные группы безопасности: Администраторы и другие, имена которых начинаются на 'Адм'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-Group'
	)]

	param (
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $false
			, Position = 1
			, ParameterSetName = 'CustomSearch'
		)]
		[String]
		$Filter = '*'
	,
		# Описание искомой группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'CustomSearch'
		)]
		[String]
		$Description
	,
		# Отображаемое имя искомой группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'CustomSearch'
		)]
		[String]
		$DisplayName
	,
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# Имя участника-пользователя искомой группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'UserPrincipalName'
		)]
		[String]
		$UserPrincipalName
	,
		# Имя учетной записи искомой группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'SamAccountName'
		)]
		[String]
		$SamAccountName
	,
		# Идентификатор безопасности искомой группы безопасности
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		[System.Security.Principal.SecurityIdentifier]
		$Sid
	)

	begin {
		try {
			$ComputerContext = New-Object -Type System.DirectoryServices.AccountManagement.PrincipalContext `
				-ArgumentList ( [System.DirectoryServices.AccountManagement.ContextType]::Machine )  `
			;
			$Searcher = New-Object -Type System.DirectoryServices.AccountManagement.PrincipalSearcher;
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
			switch ( $PsCmdlet.ParameterSetName ) {
				'CustomSearch' {
					$Params = @{};
					foreach( $Param in ( Get-Command Get-Group ).Parameters.Values.GetEnumerator() ) {
						if (
							$Param.ParameterSets.ContainsKey( 'CustomSearch' ) `
							-and $PSBoundParameters.ContainsKey( $Param.Name )
						) {
							switch ( $Param.Name ) {
								'Filter' {
									$Params.Name = $Filter;
									break;
								}
								default {
									$Params.( $Param.Name ) = $PSBoundParameters.( $Param.Name );
									break;
								};
							};
						};
					};
					$Searcher.QueryFilter = New-Object -Type System.DirectoryServices.AccountManagement.GroupPrincipal `
						-ArgumentList ( $ComputerContext ) `
						-Property $Params `
					;
					$Groups = @( $Searcher.FindAll() );
					break;
				}
				default {
					$Groups = @( [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Parse( [System.DirectoryServices.AccountManagement.IdentityType], $PsCmdlet.ParameterSetName ) )
						, ( $PSBoundParameters.( $PsCmdlet.ParameterSetName ) )
					) );
					break;
				}
			};
			if ( $Groups ) {
				return $Groups;
			} else {
				Write-Error `
					-Message ( [String]::Format( $loc.LocalGroupNotFound, $Name ) ) `
					-Category ObjectNotFound `
				;
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

New-Alias -Name Get-LocalGroup -Value Get-Group -Force;

Function Test-LocalGroup {
<#
.Synopsis
	Проверяет наличие локальной группы безопасности. 
.Outputs
	System.Bool
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroup
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroup'
	)]

	param (
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
			, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		[Alias( 'Identity' )]
		$Name
	)

	process {
		try {
			return [Bool] ( Get-LocalGroup -Name $Name -ErrorAction SilentlyContinue );
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Remove-LocalGroup {
<#
.Synopsis
	Удаляет локальную группу безопасности. 
.Description
	Remove-LocalGroup удаляет локальную группу (или группы) безопасности, переданные по конвейеру.
.Inputs
	System.DirectoryServices.DirectoryEntry
	Группа безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroup
.Example
	Get-LocalGroup -Name 'Пользователи' | Remove-LocalGroup;
	Удаляет группу безопасности 'Пользователи'.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroup'
	)]

	param (
		# Группа безопасности к удалению
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Identity'
		)]
		[String]
		[Alias( 'Identity' )]
		$Name
	)

	begin {
		try {
			[System.DirectoryServices.DirectoryEntry] $Computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer";
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
			if ( $PSCmdlet.ShouldProcess( "$Name" ) ) {
				$Computer.Delete( 'Group', $Name );
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Get-LocalGroupMember {
<#
.Synopsis
	Возвращает членов локальной группы безопасности. 
.Description
	Get-LocalGroupMember возвращает членов указанной локальной группы безопасности.
	В том числе - и с учётом транзитивности при указании флага `-Recursive`
.Inputs
	System.DirectoryServices.DirectoryEntry
	Группа безопасности.
.Outputs
	System.DirectoryServices.DirectoryEntry
	Члены указанной группы безопасности.
.Outputs
	PSObject
	Для групп типа `NT AUTHORITY/ИНТЕРАКТИВНЫЕ` возвращён будет объект,
	содержащий свойства `Path`, `Name`, `objectSid`, `groupType`.
	`SchemaClassName` будет установлен в `Group`, `AuthenticationType` в `Secure`.
	Дополнительно будет установлен аттрибут `NtAuthority` в `$true`.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-LocalGroupMember
.Example
	Get-LocalGroup -Name Пользователи | Get-LocalGroupMember -Recursive;
	Возвращает всех членов группы Пользователи с учётом транзитивности.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-LocalGroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
		)]
		[System.DirectoryServices.DirectoryEntry]
		[Alias( 'Group' )]
		$Identity
	,
		# Запросить членов группы с учётом транзитивности
		[Switch]
		$Recursive
	)

	process {
		try {
			$Members = @(
				$Identity.PSBase.Invoke( 'Members' ) `
				| % { 
					$Member = [ADSI]( $_.GetType().InvokeMember( 'ADsPath', 'GetProperty', $null, $_, $null ) );
					if ( $Member.Path ) { # объект не типа NT AUTHORITY/ИНТЕРАКТИВНЫЕ
						$Member;
					} else {
						New-Object PSObject -Property @{
							Path = ( $_.GetType().InvokeMember( 'ADsPath', 'GetProperty', $null, $_, $null ) );
							Name =  ( $_.GetType().InvokeMember( 'Name', 'GetProperty', $null, $_, $null ) );
							objectSid =  ( $_.GetType().InvokeMember( 'objectSid', 'GetProperty', $null, $_, $null ) );
							groupType = ( $_.GetType().InvokeMember( 'groupType', 'GetProperty', $null, $_, $null ) );
							SchemaClassName = 'Group';
							AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::Secure;
							NtAuthority = $true;
						};
					};
				} `
			);
			if ( -not $Recursive ) {
				return (
					$Members `
					| Sort-Object `
						-Property 'Path' `
						-Unique `
				);
			} else {
				$Members `
				| % {
					$_;
					if ( ( $_.SchemaClassName -eq 'Group' ) -and -not ( $_.NtAuthority -eq $true ) ) {
						$_ | Get-LocalGroupMember -Recursive;
					};
				} `
				| Sort-Object `
					-Property 'Path' `
					-Unique `
				;
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Test-LocalGroupMember {
<#
.Synopsis
	Проверяет наличие учётных записей в указанной локальной группе безопасности. 
.Description
	Get-LocalGroupMember проверяет наличие учётных записей в указанной
	локальной группе безопасности.
	В том числе - и с учётом транзитивности при указании флага `-Recursive`
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы, членство которых необходимо проверить в локальной группе безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	Учётные записи AD, членство которых необходимо проверить в локальной группе безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	Группы AD, членство которых необходимо проверить в локальной группе безопасности.
.Outputs
	Bool
	Наличие ( `$true` ) или отсутствие ( `$false` ) указанных объектов в указанной группе
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroupMember
.Example
	Test-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи ) -Member ( Get-ADUser 'admin-sergey.s.betke' ) -Recursive;
	Проверяем, является ли пользователь `username` членом локальной группы безопасности
	Пользователи с учётом транзитивности.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-LocalGroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# Объект безопасности для проверки членства в указанной группе
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# Запросить членов группы с учётом транзитивности
		[Switch]
		$Recursive
	)

	begin {
		$Members = @(
			Get-LocalGroupMember `
				-Identity $Group `
				-Recursive:$Recursive `
			| Select-Object -ExpandProperty Path `
		);
	}
	process {
		try {
			$Identity `
			| ConvertTo-ADSIPath `
			| % {
				$Members -contains $_;
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Add-LocalGroupMember {
<#
.Synopsis
	Добавляет учётные записи и/или группы в указанную локальную группу безопасности. 
.Description
	Добавляет учётные записи и/или группы в указанную локальную группу безопасности. 
	В качестве добавляемых учётных записей и групп могут быть использованы как локальные
	учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы, которые необходимо включить в локальную группу безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	Учётные записи AD, которые необходимо включить в локальную группу безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	Группы AD, которые необходимо включить в локальную группу безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-LocalGroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Add-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи );
	Добавляем указанного пользователя домена в локальную группы безопасности
	"Пользователи".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-LocalGroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# Объект безопасности для добавления в группу
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# Передавать ли учётную запись далее по конвейеру
		[Switch]
		$PassThru
	)

	process {
		try {
			$Identity `
			| ConvertTo-ADSIPath `
			| % {
				if ( $PSCmdlet.ShouldProcess( "$_ => $( $Group.Path )" ) ) {
					$Group.PSBase.Invoke( 'Add', $_ );
				};
			};
			if ( $PassThru ) { return $Identity; };
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Remove-LocalGroupMember {
<#
.Synopsis
	Удаляет учётные записи и/или группы из указанной локальной группы безопасности. 
.Description
	Удаляет учётные записи и/или группы из указанной локальной группы безопасности. 
	В качестве удаляемых членов могут быть использованы как локальные
	учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы, которые необходимо удалить из указанной группы.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	Учётные записи AD, которые необходимо удалить из указанной группы.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	Группы AD, которые необходимо удалить из указанной группы.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Remove-LocalGroupMember -Group ( Get-LocalGroup -Name Пользователи );
	Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-LocalGroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# Объект безопасности для удаления из группы
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# Передавать ли учётную запись далее по конвейеру
		[Switch]
		$PassThru
	)

	process {
		try {
			$Identity `
			| ConvertTo-ADSIPath `
			| % {
				if ( $PSCmdlet.ShouldProcess( "$_ => $( $Group.Path )" ) ) {
					$Group.PSBase.Invoke( 'Remove', $_ );
				};
			};
			if ( $PassThru ) { return $Identity; };
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}
