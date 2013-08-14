function pshazz:git:init {
    $git = $global:pshazz.theme.git

    $dirty = $git.prompt_dirty

    if(!$dirty) { $dirty = "*" } # default

    $global:pshazz.git = @{
        prompt_dirty = $dirty
    }
}