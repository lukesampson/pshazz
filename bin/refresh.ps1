$src = resolve-path "$psscriptroot\.."
$dest = resolve-path "$(split-path (scoop which pshazz))\.."

# make sure not running from the installed directory
if("$src" -eq "$dest") { abort "$(strip_ext $myinvocation.mycommand.name) is for development only" }

'copying files...'
robocopy $src $dest /mir /njh /njs /nfl /ndl /xd .git /xf .DS_Store manifest.json install.json

'reloading pshazz'
pshazz init