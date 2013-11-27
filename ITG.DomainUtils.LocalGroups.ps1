Function New-LocalGroup {
<#
.Synopsis
	������ ��������� ������ ������������. 
.Description
	New-LocalGroup ������ ��������� ������ ������������ � ���������� �����������.
.Outputs
	System.DirectoryServices.DirectoryEntry
	��������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#New-LocalGroup
.Example
	New-LocalGroup -Name 'MyUsers' -Description 'Users of my application';
	������ ��������� ������ ������������.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#New-LocalGroup'
	)]

	param (
		# ������������� ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
			, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		[Alias( 'Identity' )]
		$Name
	,
		# �������� ������ ������������
		[Parameter(
			Mandatory = $false
			, ValueFromPipeline = $false
			, ValueFromPipelineByPropertyName = $true
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
				$Group = $Computer.Create( 'Group', $Name );
				$Group.SetInfo();
				$Group.Description = $Description;
				$Group.SetInfo();
				if ( $PassThru ) { return $Group };
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Get-LocalGroup {
<#
.Synopsis
	���������� ��������� ������ ������������. 
.Description
	Get-LocalGroup ���������� ��������� ������ (��� ������) ������������ � ���������� �����������.
.Outputs
	System.DirectoryServices.DirectoryEntry
	ADSI ������, �������������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Get-LocalGroup
.Example
	Get-LocalGroup;
	���������� ��� ��������� ������ ������������.
.Example
	Get-LocalGroup -Name '������������';
	���������� ������ ������������ ������������.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'Filter'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Get-LocalGroup'
	)]

	param (
		# ������������� ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
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
			switch ( $PsCmdlet.ParameterSetName ) {
				'Identity' {
					[System.DirectoryServices.DirectoryEntry] $Group = $Computer.Children.Find( $Name, 'Group' );
					if ( $Group.Path ) {
						return $Group;
					} else {
						Write-Error `
							-Message ( [String]::Format( $loc.LocalGroupNotFound, $Name ) ) `
							-Category ObjectNotFound `
						;
					};
				}
				'Filter' {
					$Computer.Children `
					| ? { $_.SchemaClassName -eq 'Group' } `
					;
				}
			};
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}

Function Test-LocalGroup {
<#
.Synopsis
	��������� ������� ��������� ������ ������������. 
.Outputs
	System.Bool
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Test-LocalGroup
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Test-LocalGroup'
	)]

	param (
		# ������������� ������ ������������
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
	������� ��������� ������ ������������. 
.Description
	Remove-LocalGroup ������� ��������� ������ (��� ������) ������������, ���������� �� ���������.
.Inputs
	System.DirectoryServices.DirectoryEntry
	������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Remove-LocalGroup
.Example
	Get-LocalGroup -Name '������������' | Remove-LocalGroup;
	������� ������ ������������ '������������'.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Remove-LocalGroup'
	)]

	param (
		# ������ ������������ � ��������
		# ������������� ������ ������������
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
	���������� ������ ��������� ������ ������������. 
.Description
	Get-LocalGroupMember ���������� ������ ��������� ��������� ������ ������������.
	� ��� ����� - � � ������ �������������� ��� �������� ����� `-Recursive`
.Inputs
	System.DirectoryServices.DirectoryEntry
	������ ������������.
.Outputs
	System.DirectoryServices.DirectoryEntry
	����� ��������� ������ ������������.
.Outputs
	PSObject
	��� ����� ���� `NT AUTHORITY/�������������` ��������� ����� ������,
	���������� �������� `Path`, `Name`, `objectSid`, `groupType`.
	`SchemaClassName` ����� ���������� � `Group`, `AuthenticationType` � `Secure`.
	������������� ����� ���������� �������� `NtAuthority` � `$true`.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Get-LocalGroupMember
.Example
	Get-LocalGroup -Name ������������ | Get-LocalGroupMember -Recursive;
	���������� ���� ������ ������ ������������ � ������ ��������������.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Get-LocalGroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $true
		)]
		[System.DirectoryServices.DirectoryEntry]
		[Alias( 'Group' )]
		$Identity
	,
		# ��������� ������ ������ � ������ ��������������
		[Switch]
		$Recursive
	)

	process {
		try {
			$Members = @(
				$Identity.PSBase.Invoke( 'Members' ) `
				| % { 
					$Member = [ADSI]( $_.GetType().InvokeMember( 'ADsPath', 'GetProperty', $null, $_, $null ) );
					if ( $Member.Path ) { # ������ �� ���� NT AUTHORITY/�������������
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
	��������� ������� ������� ������� � ��������� ��������� ������ ������������. 
.Description
	Get-LocalGroupMember ��������� ������� ������� ������� � ���������
	��������� ������ ������������.
	� ��� ����� - � � ������ �������������� ��� �������� ����� `-Recursive`
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	������� ������ AD, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	������ AD, �������� ������� ���������� ��������� � ��������� ������ ������������.
.Outputs
	Bool
	������� ( `$true` ) ��� ���������� ( `$false` ) ��������� �������� � ��������� ������
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Test-LocalGroupMember
.Example
	Test-LocalGroupMember -Group ( Get-LocalGroup -Name ������������ ) -Member ( Get-ADUser 'admin-sergey.s.betke' ) -Recursive;
	���������, �������� �� ������������ `username` ������ ��������� ������ ������������
	������������ � ������ ��������������.
#>
	[CmdletBinding(
		HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Test-LocalGroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# ������ ������������ ��� �������� �������� � ��������� ������
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# ��������� ������ ������ � ������ ��������������
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
	��������� ������� ������ �/��� ������ � ��������� ��������� ������ ������������. 
.Description
	��������� ������� ������ �/��� ������ � ��������� ��������� ������ ������������. 
	� �������� ����������� ������� ������� � ����� ����� ���� ������������ ��� ���������
	������� ������ / ������, ��� � �������� ������� ������ / ������ (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������, ������� ���������� �������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	������� ������ AD, ������� ���������� �������� � ��������� ������ ������������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	������ AD, ������� ���������� �������� � ��������� ������ ������������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Add-LocalGroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Add-LocalGroupMember -Group ( Get-LocalGroup -Name ������������ );
	��������� ���������� ������������ ������ � ��������� ������ ������������
	"������������".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'Medium'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Add-LocalGroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# ������ ������������ ��� ���������� � ������
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# ���������� �� ������� ������ ����� �� ���������
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
	������� ������� ������ �/��� ������ �� ��������� ��������� ������ ������������. 
.Description
	������� ������� ������ �/��� ������ �� ��������� ��������� ������ ������������. 
	� �������� ��������� ������ ����� ���� ������������ ��� ���������
	������� ������ / ������, ��� � �������� ������� ������ / ������ (`Get-ADUser`,
	`Get-ADGroup`).
.Inputs
	System.DirectoryServices.DirectoryEntry
	������� ������ � ������, ������� ���������� ������� �� ��������� ������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	������� ������ AD, ������� ���������� ������� �� ��������� ������.
.Inputs
	Microsoft.ActiveDirectory.Management.ADGroup
	������ AD, ������� ���������� ������� �� ��������� ������.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#Remove-LocalGroupMember
.Example
	Get-ADUser 'admin-sergey.s.betke' | Remove-LocalGroupMember -Group ( Get-LocalGroup -Name ������������ );
	������� ���������� ������������ ������ �� ��������� ������ ������������	"������������".
#>
	[CmdletBinding(
		SupportsShouldProcess = $true
		, ConfirmImpact = 'High'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#Remove-LocalGroupMember'
	)]

	param (
		# ������ ������������
		[Parameter(
			Mandatory = $true
			, Position = 1
			, ValueFromPipeline = $false
		)]
		[System.DirectoryServices.DirectoryEntry]
		$Group
	,
		# ������ ������������ ��� �������� �� ������
		[Parameter(
			Mandatory = $true
			, Position = 2
			, ValueFromPipeline = $true
		)]
		[Alias( 'Member' )]
		[Alias( 'User' )]
		$Identity
	,
		# ���������� �� ������� ������ ����� �� ���������
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
