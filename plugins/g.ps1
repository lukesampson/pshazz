Import-Module "$plugindir\g"

Set-Alias g Set-Bookmark -opt allscope -scope global

function pshazz:g:init {
	$global:pshazz.completions.g = resolve-path "$psscriptroot\..\libexec\g-complete.ps1"
}
