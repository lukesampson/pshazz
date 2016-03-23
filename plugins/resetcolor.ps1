# resets the console foreground color if a program changes it
function pshazz:resetcolor:init {
	$global:pshazz:resetcolor:fg = $host.ui.rawui.foregroundcolor
	$global:pshazz:resetcolor:bg = $host.ui.rawui.backgroundcolor
}

function global:pshazz:resetcolor:prompt {
	$fg = $global:pshazz:resetcolor:fg
	if($host.ui.rawui.foregroundcolor -ne $fg) {
		$host.ui.rawui.foregroundcolor = $fg
	}
	$bg = $global:pshazz:resetcolor:bg
	if($host.ui.rawui.backgroundcolor -ne $bg) {
		$host.ui.rawui.backgroundcolor = $bg
	}
}
