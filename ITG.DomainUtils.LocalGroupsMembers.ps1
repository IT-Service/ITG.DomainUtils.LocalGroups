Function Get-GroupMember {
<#
.Synopsis
	Возвращает членов локальной группы безопасности. 
.Description
	Get-GroupMember возвращает членов указанной локальной группы безопасности.
	В том числе - и с учётом транзитивности при указании флага `-Recursive`
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Группа безопасности.
.Outputs
	System.DirectoryServices.AccountManagement.Principal
	Члены указанной группы безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-GroupMember
.Example
	Get-Group -Name Пользователи | Get-LocalGroupMember -Recursive;
	Возвращает всех членов группы Пользователи с учётом транзитивности.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-GroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# Запросить членов группы с учётом транзитивности
		[Switch]
		$Recursive
	)

	process {
		try {
			$Members = @( $Group.Members );
			if ( -not $Recursive ) {
				return $Members;
			} else {
				(
					$Members `
					| ? { $_ -is [System.DirectoryServices.AccountManagement.GroupPrincipal] } `
					| Get-GroupMember `
						-Recursive `
						-Verbose:$VerbosePreference `
				) `
				+ $Members `
				| Sort-Object `
					-Property Sid `
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

New-Alias -Name Get-LocalGroupMember -Value Get-GroupMember -Force;

Function Test-GroupMember {
<#
.Synopsis
	Проверяет наличие учётных записей в указанной локальной группе безопасности. 
.Description
	Test-GroupMember проверяет наличие учётных записей в указанной
	локальной группе безопасности.
	В том числе - и с учётом транзитивности при указании флага `-Recursive`
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	Учётные записи и группы, членство которых необходимо проверить в локальной группе безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	Учётные записи AD, членство которых необходимо проверить в локальной группе безопасности.
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы ADSI, членство которых необходимо проверить в локальной группе безопасности.
.Outputs
	Bool
	Наличие ( `$true` ) или отсутствие ( `$false` ) указанных объектов в указанной группе
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Test-GroupMember -Group ( Get-Group -Name Пользователи ) -Recursive;
	Проверяем, является ли пользователь `username` членом локальной группы безопасности
	Пользователи с учётом транзитивности.
.Example
	Test-GroupMember -Group ( Get-Group -Name Пользователи ) -Member (Get-ADUser 'admin-sergey.s.betke');
	Проверяем, является ли пользователь `username` членом локальной группы безопасности
	Пользователи.
.Example
	( [ADSI]'WinNT://csm/admin-sergey.s.betke' ) | Test-GroupMember -Group ( Get-Group -Name Пользователи );
	Проверяем, является ли пользователь `username` членом локальной группы безопасности
	Пользователи с учётом транзитивности.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-GroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# Объект безопасности для проверки членства в группе
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		$Member
	,
		# Объект безопасности AD для проверки членства в группе
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# Объект безопасности ADSI для проверки членства в группе
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# Объект безопасности в любом из трёх выше указанных типов для проверки членства в группе.
		# Использовать данный параметр стоит только для обеспечения совместимости при переходе
		# от использования одного набора классов к другому.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'UnknownTypeMember'
		)]
		[Array]
		$OtherMember
	,
		# Запросить членов группы с учётом транзитивности
		[Switch]
		$Recursive
	)

	begin {
		$MembersSids = @(
			Get-GroupMember `
				-Group $Group `
				-Recursive:$Recursive `
			| Select-Object -ExpandProperty Sid `
		);
	}
	process {
		try {
   			switch ( $PsCmdlet.ParameterSetName ) {
				'UnknownTypeMember' {
					$OtherMember `
					| Test-GroupMember `
						-Group $Group `
						-Recursive:$Recursive `
						-Verbose:$VerbosePreference `
					;
					break;
				}
				'Member' {
					$Member `
					| % {
						$MembersSids -contains ( $_.Sid );
					};
					break;
				}
				'ADMember' {
					$ADMember `
					| % {
						$MembersSids -contains ( $_.Sid );
					};
					break;
				}
				'ADSIMember' {
					$ADSIMember `
					| % {
						$MembersSids -contains ( New-Object -Type System.Security.Principal.SecurityIdentifier -ArgumentList ( [Byte[]] $_.objectSid[0] ), 0 );
					};
					break;
				}
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

New-Alias -Name Test-LocalGroupMember -Value Test-GroupMember -Force;

Function Add-GroupMember {
<#
.Synopsis
	Добавляет учётные записи и/или группы в указанную локальную группу безопасности. 
.Description
	Добавляет учётные записи и/или группы в указанную локальную группу безопасности. 
	В качестве добавляемых учётных записей и групп могут быть использованы как локальные
	учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	Учётные записи и группы, которые необходимо включить в локальную группу безопасности.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	Учётные записи AD, которые необходимо включить в локальную группу безопасности.
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы ADSI, которые необходимо включить в локальную группу безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Add-GroupMember -Group ( Get-Group -Name Пользователи );
	Добавляем указанного пользователя домена в локальную группы безопасности
	"Пользователи".
.Example
	Get-ADGroup 'Администраторы' | Add-GroupMember -Group ( Get-Group -Name Пользователи );
	Добавляем указанного локального пользователя в локальную группы безопасности
	"Пользователи".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Low'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-GroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# Объект безопасности для добавления в группу
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		$Member
	,
		# Объект безопасности AD для добавления в группу
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# Объект безопасности ADSI для добавления в группу
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# Объект безопасности в любом из трёх выше указанных типов для добавления в группу
		# Использовать данный параметр стоит только для обеспечения совместимости при переходе
		# от использования одного набора классов к другому.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'UnknownTypeMember'
		)]
		[Array]
		$OtherMember
	,
		# Передавать ли учётную запись далее по конвейеру
		[Switch]
		$PassThru
	)

	begin {
		try {
			[System.DirectoryServices.DirectoryEntry] $ADSIGroup = $Group.GetUnderlyingObject();
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
   			switch ( $PsCmdlet.ParameterSetName ) {
				'UnknownTypeMember' {
					$OtherMember `
					| Add-GroupMember `
						-Group $Group `
						-Verbose:$VerbosePreference `
					;
					break;
				}
				'Member' {
					$Member `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_.Name ) => $( $Group.Name )" ) ) {
							$Group.Members.Add( $_ );
							$Group.Save();
						};
					};
					break;
				}
				'ADMember' {
					$ADMember `
					| ConvertTo-ADSIPath `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_ ) => $( $Group.Name )" ) ) {
							$ADSIGroup.PSBase.Invoke( 'Add', $_ );
						};
					};
					break;
				}
				'ADSIMember' {
					$ADSIMember `
					| ConvertTo-ADSIPath `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_ ) => $( $Group.Name )" ) ) {
							$ADSIGroup.PSBase.Invoke( 'Add', $_ );
						};
					};
					break;
				}
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
		if ( $PassThru ) { return $input; };
	}
}

New-Alias -Name Add-LocalGroupMember -Value Add-GroupMember -Force;

Function Remove-GroupMember {
<#
.Synopsis
	Удаляет учётные записи и/или группы из указанной локальной группы безопасности. 
.Description
	Удаляет учётные записи и/или группы из указанной локальной группы безопасности. 
	В качестве удаляемых членов могут быть использованы как локальные
	учётные записи / группы, так и доменные учётные записи / группы (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	Учётные записи и группы, которые необходимо удалить из указанной группы.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	Учётные записи AD, которые необходимо удалить из указанной группы (полученные
	через `Get-ADUser`, `Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы, которые необходимо удалить из указанной группы.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Remove-GroupMember -Group ( Get-LocalGroup -Name Пользователи ) -Verbose;
	Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".
.Example
	Remove-GroupMember -Group ( Get-LocalGroup -Name Пользователи ) -OtherMember ( Get-ADUser 'admin-sergey.s.betke' ) -Verbose;
	Удаляем указанного пользователя домена из локальной группы безопасности	"Пользователи".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-GroupMember'
	)]

	param (
		# Группа безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# Объект безопасности для удаления из группы
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		[Alias( 'User' )]
		$Member
	,
		# Объект безопасности AD для удаления из группы
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# Объект безопасности ADSI для добавления в группу
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# Объект безопасности в любом из трёх выше указанных типов для добавления в группу
		# Использовать данный параметр стоит только для обеспечения совместимости при переходе
		# от использования одного набора классов к другому.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'UnknownTypeMember'
		)]
		[Array]
		$OtherMember
	)

	begin {
		try {
			[System.DirectoryServices.DirectoryEntry] $ADSIGroup = $Group.GetUnderlyingObject();
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
   			switch ( $PsCmdlet.ParameterSetName ) {
				'UnknownTypeMember' {
					$OtherMember `
					| Remove-GroupMember `
						-Group $Group `
						-Verbose:$VerbosePreference `
					;
					break;
				}
				'Member' {
					$Member `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_.Name ) => $( $Group.Name )" ) ) {
							$Group.Members.Remove( $_ );
							$Group.Save();
						};
					};
					break;
				}
				'ADMember' {
					$ADMember `
					| ConvertTo-ADSIPath `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_ ) => $( $Group.Name )" ) ) {
							$ADSIGroup.PSBase.Invoke( 'Remove', $_ );
						};
					};
					break;
				}
				'ADSIMember' {
					$ADSIMember `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_.Name ) => $( $Group.Name )" ) ) {
							$ADSIGroup.PSBase.Invoke( 'Remove', $_.Path );
						};
					};
					break;
				}
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

New-Alias -Name Remove-LocalGroupMember -Value Remove-GroupMember -Force;