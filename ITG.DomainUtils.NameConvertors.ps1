Function ConvertTo-ADSIPath {
<#
.Synopsis
	Конвертирует идентификатор переданного объекта безопасности в ADSI путь. 
.Description
	Конвертирует идентификатор переданного объекта безопасности в ADSI путь.
.Inputs
	System.DirectoryServices.DirectoryEntry
	Учётные записи и группы, идентификатор которых следует проверить / преобразовать.
.Inputs
	Microsoft.ActiveDirectory.Management.ADUser
	Учётные записи и группы AD, DN которых следует преобразовать.
.Outputs
	System.String
	ADSI путь к указанным объектам безопасности.
.Link
	https://github.com/IT-Service/ITG.DomainUtils.Printers#ConvertTo-ADSIPath
.Link
    [ADS_NAME_TYPE_ENUM]: <http://msdn.microsoft.com/en-us/library/windows/desktop/aa772267.aspx>
.Example
	Get-ADUser 'admin-sergey.s.betke' | ConvertTo-ADSIPath;
	В результате получим `WinNT://CSM/admin-sergey.s.betke`.
#>
	[CmdletBinding(
		DefaultParameterSetName = 'ADSIPath'
		, HelpUri = 'https://github.com/IT-Service/ITG.DomainUtils.Printers#ConvertTo-ADSIPath'
	)]

	param (
		# ADSI путь, преобразование не требуется
		[Parameter(
			ParameterSetName = 'ADSIPath'
			, Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		$Path
	,
		# DN для преобразования в ADSI Path
		[Parameter(
			ParameterSetName = 'DistinguishedName'
			, Mandatory = $true
			, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		$DistinguishedName
	)

	begin {
		try {
			$NameTranslator = New-Object -ComObject 'NameTranslate';
			$null = $NameTranslator.GetType().InvokeMember( 'Init', [System.Reflection.BindingFlags]::InvokeMethod, $null, $NameTranslator, (
				3, '' ## ADS_NAME_INITTYPE_GC
			) );
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	process {
		try {
			switch ( $PsCmdlet.ParameterSetName ) {
				'ADSIPath' {
					if ( $Path -match '(?:WinNT://)(<domain>.*?)/(<name>.*)' ) {
						$null = $NameTranslator.GetType().InvokeMember( 'Set', [System.Reflection.BindingFlags]::InvokeMethod, $null, $NameTranslator, (
							3, "$( $Matches['domain'] )\$( $Matches['name'] )" ## ADS_NAME_TYPE_NT4
						) );
					};
				}
				'DistinguishedName' {
					$null = $NameTranslator.GetType().InvokeMember( 'Set', [System.Reflection.BindingFlags]::InvokeMethod, $null, $NameTranslator, (
						1, $DistinguishedName ## ADS_NAME_TYPE_1779
					) );
				}
				default {
					$null = $NameTranslator.GetType().InvokeMember( 'Set', [System.Reflection.BindingFlags]::InvokeMethod, $null, $NameTranslator, (
						8, $Path ## ADS_NAME_TYPE_UNKNOWN
					) );
				}
			};
			$NewName = $NameTranslator.GetType().InvokeMember( 'Get', [System.Reflection.BindingFlags]::InvokeMethod, $null, $NameTranslator, (
				3 ## $ADS_NAME_TYPE_NT4
			) );
			return "WinNT://$( $NewName -replace '\\', '/' )";
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
	end {
		try {
			$null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject( $NameTranslator );
		} catch {
			Write-Error `
				-ErrorRecord $_ `
			;
		};
	}
}
