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