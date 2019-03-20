# Usage: pshazz config [name] [val]
# Summary: Get or set pshazz config
param($name, $val)

if ($name) {
    if ($val) {
        set_config $name $val
    } else {
        get_config $name
    }
} else {
    $cfg
}
