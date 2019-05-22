# Usage: pshazz use <theme>
# Summary: Change the current theme
# Help: This command will configure pshazz to use the specified theme.
#
# To revert to the default theme, use 'default'. E.g.:
#     pshazz use default
#
# To use a random theme for each session, use 'random'. E.g.:
#     pshazz use random

param($name)

if (!$name) {
    my_usage
    Write-Output "`npshazz currently using '$($global:pshazz.theme_name)' theme."
    return
}

if ("random" -ne $name) {
    # make sure valid theme
    $theme = theme $name
    if (!$theme) {
        Write-Output "pshazz: couldn't use the theme named '$name'."
        exit 1
    }
}

# save theme
set_config 'theme' $name

# re-init
pshazz init
