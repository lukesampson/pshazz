param($fragment) # everything after ^g\s*

$cfgpath = "$env:USERPROFILE/.gconfig"

$textContent = Get-Content $cfgpath
$inputKeys = $fragment.Split(' ')
$matchingKey = $inputKeys[$inputKeys.length - 1]

if($textContent)
{
    $fileHash = @{}

    $textContent | ForEach-Object {
        $keys = $_.Split("|")

        if($keys[0] -ne $matchingKey)
        {
            $fileHash.Add($keys[0], $keys[1])
        }
    }

    if($fileHash.Count -gt 0)
    {
        $fileHash.Keys | ForEach-Object {
            if($_.StartsWith($matchingKey))
            {
                #this will output the auto filled key to the screen.
                $_ | sort
            }
        }
    }
}
