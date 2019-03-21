﻿# Imports [z.ps](https://github.com/JannesMeyer/z.ps)

Import-Module "$pluginDir\z"
Set-Alias z Search-NavigationHistory -Scope "global"
function global:pshazz:z:prompt {
    Update-NavigationHistory $pwd.Path
}
