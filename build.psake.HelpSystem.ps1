$psake.use_exit_on_error = $true;

properties {
	$ModuleName = Split-Path -Path '.' -Leaf -Resolve;
}

task default -depends BuildHelpSystem;
task BuildHelpSystem -depends BuildReadme, BuildModuleAboutFile, BuildUpdatableHelp;

Import-Module `
	-Name 'ITG.Readme' `
	-Force `
	-Global `
;


task BuildReadme -description "Build readme.md file for module $ModuleName" {
	Import-Module $ModuleName -Global -Force;
	Get-Module $ModuleName `
	| Set-Readme -Verbose `
	;
	Remove-Module $ModuleName;
};

task BuildModuleAboutFile -description "Build about_$ModuleName.help.txt file for module $ModuleName" {
	Import-Module $ModuleName -Global -Force;
	Get-Module $ModuleName `
	| Set-AboutModule -Verbose `
	;
	Remove-Module $ModuleName;
};

task BuildUpdatableHelp -description "Build updatable help files for module $ModuleName" {
	Import-Module $ModuleName -Global -Force;
	Get-Module $ModuleName `
	| Set-HelpXML -PassThru -Cab -Verbose `
	| Set-HelpInfo -Verbose `
	;
	Remove-Module $ModuleName;
};
