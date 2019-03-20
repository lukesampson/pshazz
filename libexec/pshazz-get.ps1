# Usage: pshazz get <url>
# Summary: Get a pshazz theme from a URL

param($url)

if (!$url) {
    my_usage
    exit 1
}

if ($url -notmatch '.json$') {
    "pshazz: error: only URLs ending in .json are allowed"
}

$file = $url | Select-String '/([^/]+)$' | ForEach-Object { $_.matches.groups[1].value }
$url | Select-String '/[^/]+$' | ForEach-Object { $_.matches.groups[1] }
$name = $file | Select-String '[^\.]+' | ForEach-Object { $_.matches.groups[0].value }

if (!$name) {
    "pshazz: error: empty theme name"
    exit 1
}

$path = fullpath "$user_themedir\$file"

Write-Host "downloading '$name' theme..." -nonewline
try {
    (new-object net.webclient).downloadfile($url, $path)
} catch {
    exit 1
}

write-host "done."

"use 'pshazz use $name' to use"
