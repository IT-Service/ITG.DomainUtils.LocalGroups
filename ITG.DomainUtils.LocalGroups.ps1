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

Function Rename-Group {
<#
.Synopsis
	Переименовывает локальную группу безопасности. 
.Description
	Rename-Group переименовывает локальную группу безопасности, переданную по конвейеру.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	Группа безопасности, которую следует переименовать.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Rename-Group
.Example
	Get-Group 'test' | Rename-Group -NewName 'test2' -Verbose;
	Переименуем группу 'test' в 'test2'.
.Example
	Rename-Group -Identity (Get-Group 'test') -NewName 'test2' -WhatIf;
	Переименуем группу 'test' в 'test2'.
.Example
	Rename-Group 'test' 'test2' -Verbose;
	Переименуем группу 'test' в 'test2'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Identity'
		, SupportsShouldProcess = $true
		, ConfirmImpact = 'Low'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Rename-Group'
	)]

	param (
		# Идентификатор группы безопасности к переименованию
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# Группа безопасности к переименованию
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Identity'
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Identity
	,
		# Новый идентификатор группы безопасности
		[Parameter(
			Mandatory = $true
			, Position = 2
		)]
		[String]
		$NewName
	,
		# Передавать ли переименованные группы далее по конвейеру
		[Switch]
		$PassThru
	)

	process {
		try {
			switch ( $PsCmdlet.ParameterSetName ) {
				'Identity' {
					$OldName = $Identity.Name;
					$Identity.SamAccountName = $NewName;
					$Identity.Name = $NewName;
					if ( $PSCmdlet.ShouldProcess( "$( $OldName )" ) ) {
						[System.DirectoryServices.DirectoryEntry] $ADSIObject = $Identity.GetUnderlyingObject();
						$ADSIObject.Rename( $NewName );
						$ADSIObject.CommitChanges();
					};
					if ( $PassThru ) { return $Identity; };
					break;
				}
				'Name' {
					Get-Group `
						-Name $Name `
						-Verbose:$VerbosePreference `
					| Rename-Group `
						-NewName $NewName `
						-Verbose:$VerbosePreference `
						-PassThru:$PassThru `
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

New-Alias -Name Rename-LocalGroup -Value Rename-Group -Force;
