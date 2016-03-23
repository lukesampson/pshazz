@{
	ModuleVersion = '1.0'
	Author = 'Jannes Meyer'
	Description = 'Jump to your favorite directories'
	Copyright  =  'WTFPL'

	ModuleToProcess = 'z.psm1'
	FunctionsToExport = @('Update-NavigationHistory', 'Search-NavigationHistory', 'Optimize-NavigationHistory')
}