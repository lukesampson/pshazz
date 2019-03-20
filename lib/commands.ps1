function command_files {
    Get-ChildItem "$PSScriptRoot\..\libexec" | Where-Object {
        $_.Name -match 'pshazz-.*?\.ps1$'
    }
}

function commands {
    command_files | ForEach-Object { command_name $_ }
}

function command_name($filename) {
    $filename.Name | Select-String 'pshazz-(.*?)\.ps1$' | ForEach-Object {
        $_.matches[0].groups[1].Value
    }
}

function exec($cmd, $arguments) {
    & "$PSScriptRoot\..\libexec\pshazz-$cmd.ps1" @arguments
}
