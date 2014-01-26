# Imports [z.ps](https://github.com/JannesMeyer/z.ps)

$path = "$plugindir\z"
Import-Module $path
Set-Alias z Search-NavigationHistory -Scope "global"
function Prompt {
    Update-NavigationHistory $pwd.Path
}