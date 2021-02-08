function pshazz:k8s:init {
    $theme = $global:pshazz.theme.k8s
    $global:pshazz.k8s = @{
		prompt_lbracket    = $theme.prompt_lbracket;
		prompt_rbracket    = $theme.prompt_rbracket;
	}
}

function global:pshazz:k8s:prompt {
    $vars = $global:pshazz.prompt_vars
    $k8s_context=$(Get-Content ~/.kube/config | grep "current-context:" | sed "s/current-context: //")

    If ($k8s_context) {
        $vars.git_lbracket = $global:pshazz.k8s.prompt_lbracket
        $vars.git_rbracket = $global:pshazz.k8s.prompt_rbracket

        $vars.k8s_context = $k8s_context
    }
}
