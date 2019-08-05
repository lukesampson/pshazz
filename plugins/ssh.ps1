# Based on scripts from here:
# https://help.github.com/articles/working-with-ssh-key-passphrases#platform-windows
# https://github.com/dahlbyk/posh-sshell

# Note: the agent env file is for non win32-openssh (like, cygwin/msys openssh),
#       win32-openssh doesn't need this, it runs as system service.
$agentEnvFile = "$env:USERPROFILE/.ssh/agent.env.ps1"

function Import-AgentEnv() {
    if (Test-Path $agentEnvFile) {
        # Source the agent env file
        . $agentEnvFile | Out-Null
    }
}

# Retrieve the current SSH agent PID (or zero).
# Can be used to determine if there is a running agent.
function Get-SshAgent() {
    $cygwinId = $env:SSH_AGENT_PID
    if ($cygwinId) {
        if ($Verbose) {
            Write-Host "Agent found with Cygwin ID: $cygwinId"
        }
        (& ssh-add -l) | Out-Null
        if ($LASTEXITCODE -lt 2) {
            if ($Verbose) {
                Write-Host "Using existing agent."
            }
            return $cygwinId
        } else {
            if ($Verbose) {
                Write-Host "Cannot reach existing agent, removing Environment variables."
            }
           $env:SSH_AGENT_PID = $null
           $env:SSH_AUTH_SOCK = $null
        }
    }

    # We cannot reach non win32-openssh ssh-agent processes. SSH_AUTH_SOCK is invalid. 
    # Kill these processes and remove the agentEnvFile.
    if (Test-Path $agentEnvFile) {
        if ($Verbose) {
            Write-Host "Killing stale ssh agents."
        }
        if (Test-Administrator) {
            Get-Process -IncludeUserName `
              | Where-Object { $_.Name -eq 'ssh-agent' `
              -and $_.UserName -eq ([Security.Principal.WindowsIdentity]::GetCurrent().Name)} `
              | Stop-Process
        } else {
            Get-Process | Where-Object { $_.Name -eq 'ssh-agent' } | Stop-Process
        }
        Remove-Item $agentEnvFile
    }

    return 0
}

function Add-SshKey([switch]$Verbose) {
    # Check to see if any keys have been added. Only add keys if it's empty.
    (& ssh-add -l) | Out-Null
    if ($LASTEXITCODE -eq 0) {
        # Keys have already been added
        if ($Verbose) {
            Write-Host "Keys have already been added to the ssh-agent."
        }
        return
    }

    # Run ssh-add, add the keys
    & ssh-add
}

function Test-Administrator {
    return ([Security.Principal.WindowsPrincipal]`
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-NativeSshAgent() {
    # Only works on Windows. PowerShell < 6 must be Windows PowerShell,
    # $IsWindows is defined in PS Core.
    if (($PSVersionTable.PSVersion.Major -lt 6) -or $IsWindows) {
        # Native Windows ssh-agent service
        $service = Get-Service "ssh-agent" -ErrorAction Ignore
        # Native ssh.exe binary version must include "OpenSSH"
        $nativeSsh = Get-Command "ssh.exe" -ErrorAction Ignore `
            | ForEach-Object FileVersionInfo `
            | Where-Object ProductVersion -match OpenSSH

        # hack for Scoop broken shims, the shim lost the information of the binary
        if (!$nativeSsh) {
            $shim = Get-Command "ssh.shim" -ErrorAction Ignore
            if ($shim) {
                $value = (Get-Content $shim.Source) -creplace 'path = '
                # Check original ssh.exe binary
                $nativeSsh = Get-Command $value -ErrorAction Ignore `
                    | ForEach-Object FileVersionInfo `
                    | Where-Object ProductVersion -match OpenSSH
            }
        }

        # Output error if native ssh.exe exists but without ssh-agent.service
        if ($nativeSsh -and !$service) {
            Write-Host "You have Win32-OpenSSH binaries installed but missed the ssh-agent service. Please fix it." -f DarkRed
        }

        $result = @{}
        $result.service = $service
        $result.nativeSsh = $nativeSsh
        return $result
    }
}

function Start-NativeSshAgent([switch]$Verbose) {
    $result = Get-NativeSshAgent
    $service = $result.service
    $nativeSsh = $result.nativeSsh

    if (!$service) {
        if ($nativeSsh) {
            # ssh-agent service doesn't exist, but native ssh.exe found,
            # exit with true so Start-SshAgent doesn't try to do any other work.
            return $true
        } else {
            return $false
        }
    }

    # Native ssh doesn't need agentEnvFile, remove it.
    if (Test-Path $agentEnvFile) {
        Remove-Item $agentEnvFile
    }

    # Enable the servivce if it's disabled and we're an admin
    if ($service.StartType -eq "Disabled") {
        if (Test-Administrator) {
            Set-Service "ssh-agent" -StartupType 'Manual'
        } else {
            Write-Host "The ssh-agent service is disabled. Please enable the service and try again." -f DarkRed
            Write-Host "You can enable it by running 'Set-Service ssh-agent -StartupType Manual'" -f Cyan
            # Exit with true so Start-SshAgent doesn't try to do any other work.
            return $true
        }
    }

    # Start the service
    if ($service.Status -ne "Running") {
        if ($Verbose) {
            Write-Host "Starting ssh-agent service."
        }
        Start-Service "ssh-agent"
    }

    Add-SshKey -Verbose:$Verbose

    return $true
}

function Start-SshAgent([switch]$Verbose) {
    # If we're using the native OpenSSH, we can just interact with the service directly.
    if (Start-NativeSshAgent -Verbose:$Verbose) {
        return
    }

    # Import old ssh-agent envs if it exists
    Import-AgentEnv

    [int]$cygwinId = Get-SshAgent
    if ($cygwinId -gt 0) {
        if ($Verbose) {
            if (Test-Administrator) {
                $agentPid = Get-Process -IncludeUserName `
                  | Where-Object { $_.Name -eq 'ssh-agent' `
                  -and $_.UserName -eq ([Security.Principal.WindowsIdentity]::GetCurrent().Name)} `
                  | Select-Object -ExpandProperty Id
            } else {
                $agentPid = Get-Process | Where-Object { $_.Name -eq 'ssh-agent' } `
                  | Select-Object -ExpandProperty Id
            }
            Write-Host "ssh-agent(s) already running (pid $($agentPid))"
        }
        return
    }

    # Start ssh-agent and get output, translate to
    # powershell type and write into agent env file
    (& ssh-agent) `
        -creplace '([A-Z_]+)=([^;]+).*', '$$env:$1="$2"' `
        -creplace 'echo ([^;]+);' `
        -creplace 'export ([^;]+);' `
        | Out-File -FilePath $agentEnvFile -Encoding ascii -Force
    # And then import new ssh-agent envs
    Import-AgentEnv

    Add-SshKey -Verbose:$Verbose
}

function Test-IsSshBinaryMissing([switch]$Verbose) {
    # ssh-add
    $sshAdd = Get-Command "ssh-add.exe" -TotalCount 1 -ErrorAction SilentlyContinue
    if (!$sshAdd) {
        if ($Verbose) {
            Write-Warning 'Could not find ssh-add.'
        }
        return $true
    }

    # ssh-agent
    $sshAgent = Get-Command "ssh-agent.exe" -TotalCount 1 -ErrorAction SilentlyContinue
    if (!$sshAgent) {
        if ($Verbose) {
            Write-Warning 'Could not find ssh-agent.'
        }
        return $true
    }
}

# pshazz plugin entry point
function pshazz:ssh:init {
    if (!(Test-Path "$env:USERPROFILE/.ssh")) {
        New-Item "$env:USERPROFILE/.ssh" -ItemType Directory | Out-Null
    }

    $ssh = $global:pshazz.theme.ssh
    $Verbose = $false
    if ($ssh.verbose -eq "true") {
        $Verbose = $true
    }
    if (Test-IsSshBinaryMissing -Verbose:$Verbose) { return }
    Start-SshAgent -Verbose:$Verbose

    # ssh TabExpansion
    $global:pshazz.completions.ssh = resolve-path "$psscriptroot\..\libexec\ssh-complete.ps1"
}
