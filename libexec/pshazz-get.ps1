# Usage: pshazz get <url>
# Summary: Get a pshazz theme from a URL

param($url)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\theme.ps1"

if(!$url) { "<url> is required"; my_usage; exit 1 }

if($url -notmatch '.json$') {
	"pshazz: error: only URLs ending in .json are allowed"
}

$file = $url | sls '/([^/]+)$' |% { $_.matches.groups[1].value }
$url | sls '/[^/]+$' |% { $_.matches.groups[1] }
$name = $file | sls '[^\.]+' |% { $_.matches.groups[0].value }

if(!$name) {
	"pshazz: error: empty theme name"; exit 1
}

$path = fullpath "$user_themedir\$file"

write-host "downloading '$name' theme..." -nonewline
try {
	(new-object net.webclient).downloadfile($url, $path)
} catch {
	exit 1
}

write-host "done."

"use 'pshazz use $name' to use"