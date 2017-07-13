$cfgpath = "$env:USERPROFILE/.gconfig"

function Set-Bookmark (
    [string]$Key,
    [string]$SelectedPath = "",
    [switch]$Add,
    [switch]$Remove,
    [switch]$Clear,
    [switch]$Show,
    [switch]$List
    )
{
    <#
    .SYNOPSIS
        Navigate to specific directory paths in a quick and easy way.
    .DESCRIPTION
        The Set-Bookmark function uses to save location in bookmarks. Once a bookmark is added,
        you can easily go to one the directory by using the bookmark's name.
        Bookmarks are saved in teh $Env:USERPROFILE/.gconfig file.
    .EXAMPLE
        Set-Bookmark key
        Change current directory to a predefined bookmark
    .EXAMPLE
        Set-Bookmark key [PathToSave] -Add
        Add a bookmark
    .EXAMPLE
        Set-Bookmark key -Remove
        Remove a bookmark
    .EXAMPLE
        Set-Bookmark key -Show
        Show the path for a particular bookmark
    .EXAMPLE
        Set-Bookmark -List
        List all bookmarks
    .EXAMPLE
        Set-Bookmark -Clear
        Clear all bookmarks
    #>

    #------------------------------------Check Setup------------------------------------
    if(-not (Test-Path $cfgpath))
    {
        $doNothing = New-item $cfgpath -type file
    }

    #------------------------------------Show all keys------------------------------------
    if($List)
    {
        $directoryContent = Get-Content $cfgpath

        if($directoryContent)
        {
            $longestCount = 0
            $directoryArray = @{}

            foreach($item in $directoryContent)
            {
                $keys = $item.Split("|")
                $keyLength = $keys[0].Length

                if($longestCount -eq 0)
                {
                    $longestCount = $keyLength
                }

                if($keyLength -gt $longestCount)
                {
                    $longestCount = $keyLength
                }
            }

            if($longestCount -gt 0)
            {
                $lineBreak = ""
                $dashLine = ""

                for($index = 0; $index -lt $longestCount; $index++)
                {
                    if ($index -lt ($longestCount - 2)) {
                        $lineBreak += " ";
                    }
                    $dashLine += "-"
                }


                Write-Host
                Write-Host "Key" $lineBreak "Value"
                Write-Host $dashLine "  ------------------"

                foreach($item in $directoryContent)
                {
                    $keys = $item.Split("|")
                    $subCount = $longestCount - $keys[0].Length
                    $middleBreak = " "

                    for($index = 0; $index -lt $subCount; $index++)
                    {
                        $middleBreak += " "
                    }

                    Write-Host $keys[0] $middleBreak $keys[1]
                }

                Write-Host
            }
        }
        return
    }

    #------------------------------------Show key------------------------------------
    if($Show)
    {
        if($Key)
        {
            $directoryContent = Get-Content $cfgpath

            if($directoryContent)
            {
                $specificValue = @{}

                foreach($item in $directoryContent)
                {
                    $keys = $item.Split("|")

                    if($keys[0] -eq $Key.ToLower())
                    {
                        $specificValue = $keys

                        break
                    }
                }

                if($specificValue.Count -ne 0)
                {
                    $dashLine = ""
                    $lineBreak = ""

                    for($index = 0; $index-lt $specificValue[0].Length; $index++)
                    {
                        $lineBreak += " ";
                        $dashLine += "-"
                    }

                    Write-Host
                    Write-Host "Key" $lineBreak "Value"
                    Write-Host $dashLine "    ------------------" -ForegroundColor Yellow
                    Write-Host $specificValue[0] "    " $specificValue[1]
                    Write-Host
                }
            }
        }

        return
    }

    #------------------------------------Clear all keys------------------------------------
    if($Clear)
    {
        $response = Read-Host "Are you sure you want to clear? [Y] or [N]"

        Write-Host $val

        if($response -and $response.ToLower() -eq "y")
        {
            Clear-Content $cfgpath
        }

        return
    }

    #------------------------------------Delete Key------------------------------------
    if($Remove)
    {
        if($Key)
        {
            $directoryContent = Get-Content $cfgpath

            if($directoryContent)
            {
                $keyToDelete = ""

                foreach($item in $directoryContent)
                {
                    $keys = $item.Split("|")

                    if($keys[0] -eq $Key.ToLower())
                    {
                        $keyToDelete = $item

                        break
                    }
                }

                if($keyToDelete -ne "")
                {
                    $directoryContent = $directoryContent |? {$_ -ne $keyToDelete}

                    Clear-Content $cfgpath

                    Add-Content -Value $directoryContent -Path $cfgpath
                }
            }
        }

        return
    }

    #------------------------------------Add key------------------------------------

    if($Add)
    {
        if($Key)
        {
            $directoryContent = Get-Content $cfgpath
            $isDuplicate = $false

            if($cfgpath)
            {
                foreach($item in $directoryContent)
                {
                    $keys = $item.Split('|')

                    if($keys[0] -eq $Key.ToLower())
                    {
                        $isDuplicate = $true;

                        break;
                    }
                }
            }

            if(!$isDuplicate)
            {
                $compositeKey = $Key.ToLower() + "|"

                if($SelectedPath)
                {
                    $compositeKey += $SelectedPath
                }
                else
                {
                    $compositeKey += $pwd
                }

                Add-Content -value $compositeKey -Path $cfgpath
            }
        }

        return
    }

    #------------------------------------Push key------------------------------------
    if($Key)
    {
        $directoryContent = Get-Content $cfgpath
        $bookmark = ""

        if($directoryContent)
        {
            foreach($item in $directoryContent)
            {
                $keys = $item.Split("|")

                if($keys[0] -eq $Key.ToLower())
                {
                    $bookmark = $keys[1]

                    break
                }
            }

            if($bookmark)
            {
                Push-Location $bookmark
            }
        }
    }
}