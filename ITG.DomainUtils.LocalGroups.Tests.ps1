$ModuleName = Split-Path -Path '.' -Leaf -Resolve;
$ModuleDir = Resolve-Path -Path '.';

Describe 'ITG.DomainUtils.LocalGroups module' {

	It 'must be imported without errors' {
		{
			Import-Module `
				-Name "$ModuleDir\$ModuleName.psd1" `
				-Force `
			;
		} `
		| Should Not Throw;
	};

};

. "$ModuleDir\$ModuleName.ps1";
