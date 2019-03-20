# Usage: pshazz config [name] [val]
# Summary: Get or set pshazz config
param($name, $val)

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\help.ps1"
. "$PSScriptRoot\..\lib\config.ps1"

if ($name) {
    if ($val) {
        set_config $name $val
    } else {
        get_config $name
    }
} else {
    $cfg
}
