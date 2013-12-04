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

Function Get-GroupMember {
<#
.Synopsis
	���������� ������ ��������� ������ ������������. 
.Description
	Get-GroupMember ���������� ������ ��������� ��������� ������ ������������.
	� ��� ����� - � � ������ �������������� ��� �������� ����� `-Recursive`
.Inputs
	System.DirectoryServices.AccountManagement.GroupPrincipal
	������ ������������.
.Outputs
	System.DirectoryServices.AccountManagement.Principal
	����� ��������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-GroupMember
.Example
	Get-Group -Name ������������ | Get-LocalGroupMember -Recursive;
	���������� ���� ������ ������ ������������ � ������ ��������������.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Get-GroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# ��������� ������ ������ � ������ ��������������
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
	��������� ������� ������� ������� � ��������� ��������� ������ ������������. 
.Description
	Test-GroupMember ��������� ������� ������� ������� � ���������
	��������� ������ ������������.
	� ��� ����� - � � ������ �������������� ��� �������� ����� `-Recursive`
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	������� ������ � ������, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	������� ������ AD, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������ ADSI, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Outputs
	Bool
	������� ( `$true` ) ��� ���������� ( `$false` ) ��������� �������� � ��������� ������
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Test-GroupMember -Group ( Get-Group -Name ������������ ) -Recursive;
	���������, �������� �� ������������ `username` ������ ��������� ������ ������������
	������������ � ������ ��������������.
.Example
	Test-GroupMember -Group ( Get-Group -Name ������������ ) -Member (Get-ADUser 'admin-sergey.s.betke');
	���������, �������� �� ������������ `username` ������ ��������� ������ ������������
	������������.
.Example
	( [ADSI]'WinNT://csm/admin-sergey.s.betke' ) | Test-GroupMember -Group ( Get-Group -Name ������������ );
	���������, �������� �� ������������ `username` ������ ��������� ������ ������������
	������������ � ������ ��������������.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Sid'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Test-GroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# ������ ������������ ��� �������� �������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		$Member
	,
		# ������ ������������ AD ��� �������� �������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# ������ ������������ ADSI ��� �������� �������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# ������ ������������ � ����� �� ��� ���� ��������� ����� ��� �������� �������� � ������.
		# ������������ ������ �������� ����� ������ ��� ����������� ������������� ��� ��������
		# �� ������������� ������ ������ ������� � �������.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'UnknownTypeMember'
		)]
		[Array]
		$OtherMember
	,
		# ��������� ������ ������ � ������ ��������������
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
	��������� ������� ������ �/��� ������ � ��������� ��������� ������ ������������. 
.Description
	��������� ������� ������ �/��� ������ � ��������� ��������� ������ ������������. 
	� �������� ����������� ������� ������� � ����� ����� ���� ������������ ��� ���������
	������� ������ / ������, ��� � �������� ������� ������ / ������ (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	������� ������ � ������, ������� ���������� �������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	������� ������ AD, ������� ���������� �������� � ��������� ������ ������������.
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������ ADSI, ������� ���������� �������� � ��������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Add-GroupMember -Group ( Get-Group -Name ������������ );
	��������� ���������� ������������ ������ � ��������� ������ ������������
	"������������".
.Example
	Get-ADGroup '��������������' | Add-GroupMember -Group ( Get-Group -Name ������������ );
	��������� ���������� ���������� ������������ � ��������� ������ ������������
	"������������".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Low'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Add-GroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# ������ ������������ ��� ���������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		$Member
	,
		# ������ ������������ AD ��� ���������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# ������ ������������ ADSI ��� ���������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# ������ ������������ � ����� �� ��� ���� ��������� ����� ��� ���������� � ������
		# ������������ ������ �������� ����� ������ ��� ����������� ������������� ��� ��������
		# �� ������������� ������ ������ ������� � �������.
		[Parameter(
			Mandatory = $true
			, ParameterSetName = 'UnknownTypeMember'
		)]
		[Array]
		$OtherMember
	,
		# ���������� �� ������� ������ ����� �� ���������
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
	������� ������� ������ �/��� ������ �� ��������� ��������� ������ ������������. 
.Description
	������� ������� ������ �/��� ������ �� ��������� ��������� ������ ������������. 
	� �������� ��������� ������ ����� ���� ������������ ��� ���������
	������� ������ / ������, ��� � �������� ������� ������ / ������ (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.AccountManagement.Principal
	������� ������ � ������, ������� ���������� ������� �� ��������� ������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADAccount
	������� ������ AD, ������� ���������� ������� �� ��������� ������ (����������
	����� `Get-ADUser`, `Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������, ������� ���������� ������� �� ��������� ������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-GroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Remove-GroupMember -Group ( Get-LocalGroup -Name ������������ ) -Verbose;
	������� ���������� ������������ ������ �� ��������� ������ ������������	"������������".
.Example
	Remove-GroupMember -Group ( Get-LocalGroup -Name ������������ ) -OtherMember ( Get-ADUser 'admin-sergey.s.betke' ) -Verbose;
	������� ���������� ������������ ������ �� ��������� ������ ������������	"������������".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.LocalGroups#Remove-GroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
		)]
		[System.DirectoryServices.AccountManagement.GroupPrincipal]
		$Group
	,
		# ������ ������������ ��� �������� �� ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'Member'
		)]
		[System.DirectoryServices.AccountManagement.Principal[]]
		[Alias( 'User' )]
		$Member
	,
		# ������ ������������ AD ��� �������� �� ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADMember'
		)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]
		$ADMember
	,
		# ������ ������������ ADSI ��� ���������� � ������
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
			, ParameterSetName = 'ADSIMember'
		)]
		[System.DirectoryServices.DirectoryEntry[]]
		$ADSIMember
	,
		# ������ ������������ � ����� �� ��� ���� ��������� ����� ��� ���������� � ������
		# ������������ ������ �������� ����� ������ ��� ����������� ������������� ��� ��������
		# �� ������������� ������ ������ ������� � �������.
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