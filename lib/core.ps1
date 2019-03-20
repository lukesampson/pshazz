function fullpath($path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

# checks if the current theme's prompt will use a variable
function prompt_uses($varname) {
    foreach($item in $global:pshazz.theme.prompt) {
        if ($item[2] -match "\`$$varname\b") {
            return $true
        }
    }
    return $false
}
