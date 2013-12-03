$CurrentDir = `
	Split-Path `
		-Path $MyInvocation.MyCommand.Path `
		-Parent `
;

$loc = Import-LocalizedData;

. (	Join-Path -Path $CurrentDir -ChildPath 'ITG.DomainUtils.NameConvertors.ps1' );
. (	Join-Path -Path $CurrentDir -ChildPath 'ITG.DomainUtils.LocalGroups.ps1' );

Export-ModuleMember -Function New-Group -Alias New-LocalGroup;
Export-ModuleMember -Function Get-Group -Alias Get-LocalGroup;
Export-ModuleMember -Function Test-LocalGroup;
Export-ModuleMember -Function Remove-LocalGroup;

Export-ModuleMember -Function Get-LocalGroupMember;
Export-ModuleMember -Function Test-LocalGroupMember;
Export-ModuleMember -Function Add-LocalGroupMember;
Export-ModuleMember -Function Remove-LocalGroupMember;

Export-ModuleMember -Function ConvertTo-ADSIPath;
