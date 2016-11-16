try { gcm hg -ea stop > $null } catch { return }

function pshazz:hg:init {
	$hg = $global:pshazz.theme.hg

	$dirty = $hg.prompt_dirty

	if(!$dirty) { $dirty = "*" } # default

	$show_bookmark = prompt_uses 'hg_bookmark'

	$global:pshazz.hg = @{
		prompt_dirty    = $dirty;
		prompt_lbracket = $hg.prompt_lbracket;
		prompt_rbracket = $hg.prompt_rbracket;
		show_bookmark = $show_bookmark;
	}

	$global:pshazz.completions.hg = resolve-path "$psscriptroot\..\libexec\hg-complete.ps1"
}

function global:pshazz:hg:prompt {
	$vars = $global:pshazz.prompt_vars

	try { $branch = hg branch } catch { }
	if($branch) {
		$vars.hg_lbracket = $global:pshazz.hg.prompt_lbracket
		$vars.hg_rbracket = $global:pshazz.hg.prompt_rbracket

		$vars.is_hg = $true;

		$vars.hg_branch = $branch
		try { $status = hg status } catch { }
		if($status) {
			$vars.hg_dirty = $global:pshazz.hg.prompt_dirty
		}

		if($global:pshazz.hg.show_bookmark) {
			$bookmark = hg bookmarks | sls "\* ([^\s]+)" | % { $_.matches.groups[1].value }
			if($bookmark) { $vars.hg_bookmark = " at $bookmark" }
		}
	}
}