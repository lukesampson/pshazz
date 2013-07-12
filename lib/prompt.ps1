function global:git_prompt_info {
    $ref = try { git symbolic-ref HEAD } catch { }
    if($ref) {
        $ref = $ref -replace '^refs/heads/', ''
        write-host " ($ref)" -f red -nonewline
    }
}

function global:prompt {
    write-host "$(split-path $pwd -leaf)" -f cyan -nonewline
    git_prompt_info
    write-host ' $' -nonewline
    " "
}