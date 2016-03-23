$plugindir = fullpath "$psscriptroot\..\plugins"

function plugin:init($name) {
    $path = "$plugindir\$name.ps1"
    if(!(test-path $path)) {
        "couldn't find plugin '$name' at $path"; return
    }
    . $path

    $initfn = "pshazz:$name`:init"
    if(test-path "function:\$initfn") {
        & $initfn
    }
}