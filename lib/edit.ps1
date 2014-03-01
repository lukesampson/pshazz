$known_editors = "vim", "nano", "notepad2", "notepad++", "notepad"

function editor {
	$editor = get_config 'editor'
	if($editor) { return $editor }
	foreach($editor in $known_editors) {
		if(has_editor $editor) { return $editor }
	}
	return $null
}

function has_editor($name) {
	try { gcm $name -ea stop; $true } catch { $false }
}