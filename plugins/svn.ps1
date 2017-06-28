try { Get-Command git -ea stop > $null } catch { return }

function pshazz:svn:init {
	$svn = $global:pshazz.theme.svn

	$dirty = $svn.prompt_dirty

	# defaults
	if(!$dirty) { $dirty = "*" }

	$global:pshazz.svn = @{
		prompt_dirty       = $dirty;
	}
}

function global:pshazz:svn:prompt {
	$vars = $global:pshazz.prompt_vars

	$svn_root = pshazz_local_or_parent_path .svn

	if ($svn_root) {

		$vars.yes_svn = ([char]0xe0b0);
		$vars.svn_branch = "svn";

        try { $status = svn status } catch {}

        if ($status) {
            $vars.svn_dirty = $global:pshazz.svn.prompt_dirty
        }

	} else {
		$vars.no_svn = ([char]0xe0b0);
	}
}
