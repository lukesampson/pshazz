# fixes some insane powershell aliases that interfere with real programs
# also adds some commonly used aliases
# you can specify more aliases to add and remove in the theme under aliases.rm and aliases.add
function pshazz:aliases:init {
    # remove default/theme aliases
    $remove = @($global:pshazz.theme.aliases.rm) + ('curl', 'wget', 'r') | Where-Object { $_ } # theme overrides
    $remove | ForEach-Object {
        # may need to execute the rm many times in parent scopes until really removed
        # (set-alias -option allscope copies the alias to child scopes)
        while (test-path "alias:$_") {
            Remove-Item "alias:\$_" -Force
        }
    }

    # Add default aliases
    Set-PAlias 'll' 'ls'

    # Theme aliases
    $global:pshazz.theme.aliases.add.psobject.Properties | ForEach-Object {
        Set-PAlias $_.Name $_.Value
    }
}

function Set-PAlias($alias, $cmd) {
    if (($alias -match '\(') -or ($cmd -match ' ')) {
        Set-InterpolatedPAlias $alias $cmd # with params
    }
    else {
        Set-Alias $alias $cmd -opt allscope -scope global # without params
    }
}

function Set-InterpolatedPAlias($alias, $cmd) {
    # alias with extra parameters, based on
    # http://huddledmasses.org/powershell-power-user-tips-bash-style-alias-command/
    $m = $alias | Select-String '([^\(]+)(\([^\)]+\))' | Select-Object -First 1
    $in_param = $null

    if ($m) {
        # has input parameters
        $alias, $in_param = $m.Matches.Groups[1..2] | ForEach-Object { $_.Value }
    }

    $fn_body = $cmd
    if ($in_param) {
        $fn_body = "param$in_param $fn_body"
    }

    $null = New-Item -Path function: -Name "global:pshazz.alias_$alias" -Options allscope -Value $fn_body -Force
    Set-Alias $alias "pshazz.alias_$alias" -Opt allscope -Scope global
}
