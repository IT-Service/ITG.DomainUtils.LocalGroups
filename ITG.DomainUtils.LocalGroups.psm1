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
Export-ModuleMember -Function Test-Group -Alias Test-LocalGroup;
Export-ModuleMember -Function Remove-Group -Alias Remove-LocalGroup;
Export-ModuleMember -Function Rename-Group -Alias Rename-LocalGroup;

Export-ModuleMember -Function Get-GroupMember -Alias Get-LocalGroupMember;
Export-ModuleMember -Function Test-GroupMember -Alias Test-LocalGroupMember;
Export-ModuleMember -Function Add-GroupMember -Alias Add-LocalGroupMember;
Export-ModuleMember -Function Remove-GroupMember -Alias Remove-LocalGroupMember;
