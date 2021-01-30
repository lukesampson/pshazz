function global:pshazz_time {
    return (Get-Date -DisplayHint Time -Format T)
}

function global:pshazz_dir {
    $h = (Get-PsProvider 'FileSystem').Home
    if ($PWD -like $h) {
        return '~'
    }

    $dir = Split-Path $PWD -Leaf
    if ($dir -imatch '[a-z]:\\') {
        return '\'
    }
    return $dir
}

function global:pshazz_two_dir {
    $h = (Get-PsProvider 'FileSystem').Home
    if ($PWD -like $h) {
        return '~'
    }

    $dir = Split-Path $PWD -Leaf
    $parent_pwd = Split-Path $PWD -Parent
    if ($dir -imatch '[a-z]:\\') {
        return '\'
    }

    if ($parent_pwd) {
        if ($parent_pwd -like $h) {
            $parent = '~'
        } else {
            $parent = Split-Path $parent_pwd -Leaf
        }

        if ( $parent -imatch '[a-z]:\\') {
            $dir = "\$dir"
        } else {
            $dir = "$parent\$dir"
        }
    }

    return $dir
}

function global:pshazz_path {
    # Replace $HOME with '~'
    return $PWD -replace [Regex]::Escape((Get-PsProvider 'FileSystem').Home), "~"
}

function global:pshazz_rightarrow {
    return ([char]0xe0b0)
}

# Based on posh-git
function global:pshazz_local_or_parent_path($path) {
    $check_in = Get-Item -Force .
    if ($check_in.PSProvider.Name -ne 'FileSystem') {
        return $null
    }
    while ($null -ne $check_in) {
        $path_to_test = [System.IO.Path]::Combine($check_in.FullName, $path)
        if (Test-Path -LiteralPath $path_to_test) {
            return $check_in.FullName
        } else {
            $check_in = $check_in.Parent
        }
    }
    return $null
}


function global:pshazz_write_prompt($prompt, $vars) {
    $vars.keys | ForEach-Object { set-variable $_ $vars[$_] }
    function eval($str) {
        $executionContext.invokeCommand.expandString($str)
    }

    $fg_default = $Host.UI.RawUI.ForegroundColor
    $bg_default = $Host.UI.RawUI.BackgroundColor

    # write each element of the prompt, stripping out portions
    # that evaluate to blank strings
    $prompt | ForEach-Object {
        $str = eval $_[2]

        # check if there is additional conditional parameter for prompt part
        if ($_.Count -ge 4) {
            $cond = eval $_[3]
            $condition = ([String]::IsNullOrWhiteSpace($_[3]) -or $cond)
        } else {
            $condition = $true
        }

        # empty up the prompt part if condition fails
        if (!$condition) {
            $str = ""
        }

        if (![String]::IsNullOrWhiteSpace($str)) {
            $fg = eval $_[0]; $bg = eval $_[1]
            if (!$fg) { $fg = $fg_default }
            if (!$bg) { $bg = $bg_default }
            Write-Host $str -NoNewline -ForegroundColor $fg -BackgroundColor $bg
        }
    }
}

if (!$global:pshazz.theme.prompt) { return } # no prompt specified, keep existing

function global:prompt {
    $saved_lastoperationstatus = $? # status of win32 AND powershell command (False on interrupts)
    $saved_lastexitcode = $lastexitcode

    $global:pshazz.prompt_vars = @{
        time     = pshazz_time;
        dir      = pshazz_dir;
        two_dir  = pshazz_two_dir;
        path     = pshazz_path;
        user     = $env:username;
        hostname = $env:computername;
        rightarrow = pshazz_rightarrow;
    }

    # get plugins to populate prompt vars
    $global:pshazz.theme.plugins | ForEach-Object {
        $prompt_fn = "pshazz:$_`:prompt"
        if (Test-Path "function:\$prompt_fn") {
            & $prompt_fn
        }
    }

    pshazz_write_prompt $global:pshazz.theme.prompt $global:pshazz.prompt_vars

    $global:lastexitcode = $saved_lastexitcode
    " "
}
