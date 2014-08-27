function pshazz:dircolors:init {
	New-CommandWrapper Out-Default -Process {
	  if(($_ -is [System.IO.DirectoryInfo]) -or ($_ -is [System.IO.FileInfo])) {
	  	$item = $_

	    if(-not ($notfirst)) {
	      Write-Host
	      Write-Host "Mode  Last Write Time                Size Name"
	      Write-Host "----  ---------------                ---- ----"
	      #           d---- 2013-08-24 11:06:41 AM     1,000 MB foo.dat
	      $notfirst=$true
	    }

	    $config = $global:pshazz.theme.dircolors.files
	    if ($item -is [System.IO.DirectoryInfo]) {
	      $config = $global:pshazz.theme.dircolors.dirs
        }
        
        $colors = $config |? { $item.Name -match $_[0] } | select -first 1
        if ($colors) { pshazz:dircolors:write_item $item $colors[1] $colors[2] }
        else { pshazz:dircolors:write_item $item }

	    # prevent default output
	    $_ = $null
	  }
	} -End {
	  Write-Host
	}
}

function global:pshazz:dircolors:write_item($item, $fg = $Host.ui.RawUI.ForegroundColor, $bg = $Host.ui.RawUI.BackgroundColor)
{
  if (!$fg) { $fg = $Host.ui.RawUI.ForegroundColor }
  if (!$bg) { $bg = $Host.ui.RawUI.BackgroundColor }

  if ($item -is [System.IO.DirectoryInfo]) {
    write-host `
    ( `
      "{0,-5} {1,22} {2,12} {3}" -f `
      $item.Mode, `
      ([String]::Format("{0,10} {1,11}", $item.LastWriteTime.ToString("yyyy-MM-dd"), $item.LastWriteTime.ToString("hh:mm:ss tt"))), `
      "", `
      $item.Name + "/" `
    ) -ForegroundColor $fg -BackgroundColor $bg
  } 
  elseif ($item -is [System.IO.FileInfo]) {
    write-host `
    ( `
      "{0,-5} {1,22} {2,12} {3}" -f `
      $item.Mode, `
      ([String]::Format("{0,10} {1,11}", $item.LastWriteTime.ToString("yyyy-MM-dd"), $item.LastWriteTime.ToString("hh:mm:ss tt"))), `
      (pshazz:dircolors:format_size $item), `
      $item.Name `
    ) -ForegroundColor $fg -BackgroundColor $bg
  }
}

function global:pshazz:dircolors:format_size($item) {
  if ($item -is [System.IO.DirectoryInfo]) {
    ""
  }
  elseif ($item.Length -lt 1KB) {
    (($item.Length.ToString("n0")) + " B ")
  }
  elseif ($item.Length -lt 1MB ) {
    ((($item.Length/1KB).ToString("n0")) + " KB")
  }
  elseif ($item.Length -lt 1GB ) {
    ((($item.Length/1MB).ToString("n0")) + " MB")
  }
  else {
    ((($item.Length/1GB).ToString("n0")) + " GB")
  }
}