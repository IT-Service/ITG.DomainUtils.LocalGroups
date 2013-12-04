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
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
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
					if ( $Groups ) {
						return $Groups;
					} else {
						Write-Error `
							-Message ( [String]::Format( $loc.LocalGroupNotFound, $Name ) ) `
							-Category ObjectNotFound `
						;
					};
					break;
				}
				default {
					$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Parse( [System.DirectoryServices.AccountManagement.IdentityType], $PsCmdlet.ParameterSetName ) )
						, ( $PSBoundParameters.( $PsCmdlet.ParameterSetName ) )
					);
					if ( $Group.SamAccountName ) {
						return $Group;
					} else {
						Write-Error `
							-Message ( [String]::Format( $loc.LocalGroupNotFound, $Name ) ) `
							-Category ObjectNotFound `
						;
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

New-Alias -Name Get-LocalGroup -Value Get-Group -Force;

Function Test-Group {
<#
.Synopsis
	Проверяет наличие локальной группы безопасности. 
.Outputs
	System.Bool
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-Group
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-Group'
	)]

	param (
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
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
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
			switch ( $PsCmdlet.ParameterSetName ) {
				default {
					$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Parse( [System.DirectoryServices.AccountManagement.IdentityType], $PsCmdlet.ParameterSetName ) )
						, ( $PSBoundParameters.( $PsCmdlet.ParameterSetName ) )
					);
					break;
				}
			};
			return [bool] $Group.SamAccountName; # приходится проверять именно SamAccountName, потому как группа возвращается и для несуществующего Sid
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

New-Alias -Name Test-LocalGroup -Value Test-Group -Force;

Function Remove-Group {
<#
.Synopsis
	Удаляет локальную группу безопасности. 
.Description
	Remove-Group удаляет локальную группу (или группы) безопасности, переданную по конвейеру.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Группа безопасности, которую следует удалить.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-Group
.Example
	Get-Group -Filter 'test*' | Remove-Group -Verbose;
	Удаляет группы безопасности, имена которых начинаются с 'test'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-Group'
	)]

	param (
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# Идентификатор безопасности искомой группы безопасности
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		[System.Security.Principal.SecurityIdentifier]
		$Sid
	,
		# Группа безопасности к удалению
		# Идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Identity'
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Identity
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
			switch ( $PsCmdlet.ParameterSetName ) {
				'Identity' {
					if ( $PSCmdlet.ShouldProcess( "$( $Identity.Name )" ) ) {
						$Identity.Delete();
					};
					break;
				}
				default {
					$Params = @{};
					$Params.Add( $PsCmdlet.ParameterSetName, $PSBoundParameters.( $PsCmdlet.ParameterSetName ) );
					Get-Group `
						@Params `
						-Verbose:$VerbosePreference `
					| Remove-Group `
						-Verbose:$VerbosePreference `
					;
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

New-Alias -Name Remove-LocalGroup -Value Remove-Group -Force;

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
		# Объект безопасности для проверки членства в указанной группе, точнее - его Sid.
		# При передаче по конвейеру принимает Sid как локальных учётных записей, так и объектов AD.
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		[System.Security.Principal.SecurityIdentifier[]]
		$Sid
	,
		# Объект безопасности для проверки членства в указанной группе.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'Member'
		)]
		[Alias( 'User' )]
		$Member
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
				'Sid' {
					$Sid `
					| % {
						$MembersSids -contains $_;
					};
					break;
				}
				'Member' {
					Member `
					| Test-GroupMember `
						-Group $Group `
						-Recursive:$Recursive `
						-Verbose:$VerbosePreference `
					;
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
					| ConvertTo-ADSIPath `
					| % {
						if ( $PSCmdlet.ShouldProcess( "$( $_ ) => $( $Group.Name )" ) ) {
							$ADSIGroup.PSBase.Invoke( 'Remove', $_ );
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