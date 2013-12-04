Function New-Group {
<#
.Synopsis
	������ ��������� ������ ������������. 
.Description
	New-Group ������ ��������� ������ ������������ � ���������� �����������.
.Outputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	��������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#New-Group
.Example
	New-Group -Name 'MyUsers' -Description 'Users of my application';
	������ ��������� ������ ������������.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#New-Group'
	)]

	param (
		# ������������� ������ ������������
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
		# �������� ������ ������������
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'GroupProperties'
		)]
		[String]
		$Description
	,
		# ���������� �� ��������� ������ ����� �� ���������
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
	���������� ��������� ������ ������������. 
.Description
	Get-Group ���������� ��������� ������ (��� ������) ������������ � ���������� �����������.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	������, ������������ ��������� ������.
.Inputs
	System.DirectoryServices.DirectoryEntry
	������ ADSI, ��� �������� ���������� �������� ������������� � ������ System.DirectoryServices.AccountManagement.GroupPrincipal
.Outputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	������, �������������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-Group
.Example
	Get-Group -Filter '*';
	���������� ��� ��������� ������ ������������.
.Example
	Get-Group -Name '������������';
	���������� ������ ������������ ������������.
.Example
	Get-Group -Filter '���*';
	���������� ��������� ������ ������������: �������������� � ������, ����� ������� ���������� �� '���'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-Group'
	)]

	param (
		# ������������� ������ ������������
		[Parameter(
			Mandatory = $false
			, Position = 1
			, ParameterSetName = 'CustomSearch'
		)]
		[String]
		$Filter = '*'
	,
		# �������� ������� ������ ������������
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'CustomSearch'
		)]
		[String]
		$Description
	,
		# ������������� ������ ������������
		[Parameter(
			Mandatory = $false
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# ������������� ������������ ������� ������ ������������
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		## [System.Security.Principal.SecurityIdentifier]
		[Alias( 'objectSid' )]
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
				'Sid' {
					if ( $Sid -is [System.Security.Principal.SecurityIdentifier] ) {
						[System.Security.Principal.SecurityIdentifier] $SecurityIdentifier = $Sid;
					} else {
						[System.Security.Principal.SecurityIdentifier] $SecurityIdentifier = New-Object `
							-Type System.Security.Principal.SecurityIdentifier `
							-ArgumentList ( [Byte[]] $Sid[0] ), 0 `
						;
					};
					$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Sid )
						, $SecurityIdentifier
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
	��������� ������� ��������� ������ ������������. 
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
		# ������������� ������ ������������
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
		# ������������� ������������ ������� ������ ������������
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		## [System.Security.Principal.SecurityIdentifier]
		[Alias( 'objectSid' )]
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
				'Sid' {
					if ( $Sid -is [System.Security.Principal.SecurityIdentifier] ) {
						[System.Security.Principal.SecurityIdentifier] $SecurityIdentifier = $Sid;
					} else {
						[System.Security.Principal.SecurityIdentifier] $SecurityIdentifier = New-Object `
							-Type System.Security.Principal.SecurityIdentifier `
							-ArgumentList ( [Byte[]] $Sid[0] ), 0 `
						;
					};
					$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Sid )
						, $SecurityIdentifier
					);
					break;
				}
				default {
					$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity(
						$ComputerContext
						, ( [System.DirectoryServices.AccountManagement.IdentityType]::Parse( [System.DirectoryServices.AccountManagement.IdentityType], $PsCmdlet.ParameterSetName ) )
						, ( $PSBoundParameters.( $PsCmdlet.ParameterSetName ) )
					);
					break;
				}
			};
			return [bool] $Group.SamAccountName; # ���������� ��������� ������ SamAccountName, ������ ��� ������ ������������ � ��� ��������������� Sid
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
	������� ��������� ������ ������������. 
.Description
	Remove-Group ������� ��������� ������ (��� ������) ������������, ���������� �� ���������.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	������ ������������, ������� ������� �������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-Group
.Example
	Get-Group -Filter 'test*' | Remove-Group -Verbose;
	������� ������ ������������, ����� ������� ���������� � 'test'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-Group'
	)]

	param (
		# ������������� ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# ������������� ������������ ������� ������ ������������
		[Parameter(
			Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Sid'
		)]
		[System.Security.Principal.SecurityIdentifier]
		$Sid
	,
		# ������ ������������ � ��������
		# ������������� ������ ������������
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
	��������������� ��������� ������ ������������. 
.Description
	Rename-Group ��������������� ��������� ������ ������������, ���������� �� ���������.
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	������ ������������, ������� ������� �������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Rename-Group
.Example
	Get-Group 'test' | Rename-Group -NewName 'test2' -Verbose;
	����������� ������ 'test' � 'test2'.
.Example
	Rename-Group -Identity (Get-Group 'test') -NewName 'test2' -WhatIf;
	����������� ������ 'test' � 'test2'.
.Example
	Rename-Group 'test' 'test2' -Verbose;
	����������� ������ 'test' � 'test2'.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Identity'
		, SupportsShouldProcess = $true
		, ConfirmImpact = 'Low'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Rename-Group'
	)]

	param (
		# ������������� ������ ������������ � ��������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipelineByPropertyName = $true
			, ParameterSetName = 'Name'
		)]
		[String]
		$Name
	,
		# ������ ������������ � ��������������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Identity'
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Identity
	,
		# ����� ������������� ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 2
		)]
		[String]
		$NewName
	,
		# ���������� �� ��������������� ������ ����� �� ���������
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
