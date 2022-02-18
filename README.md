# Pshazz
##### Give your powershell some pizazz.

Pshazz extends your powershell profile to add things like

* A nicer prompt, including Git and Mercurial info
* Git and Mercurial tab completion
* An SSH helper that lets you never enter your private key password again
* Sensible aliases, and an easy way to add your own aliases and remove ones you don't like

Pshazz is designed to work with themes, so you can create your own [theme](https://github.com/lukesampson/pshazz/wiki/Themes) if the defaults aren't quite what you want. Make sure to send a pull request to include your theme with pshazz if you come up with something cool!

### Installation
Using [Scoop](http://scoop.sh):

```
scoop install pshazz
```

If you don't have Scoop installed, you can download a zip of this
repository, and add `bin\pshazz.ps1` to your PATH.

### The SSH helper
When
- you don't have admin rights
- and, the native OpenSSH client is installed,
- and the native ssh-agent service is disabled

using the SSH helper is not straight forward and needs to be worked around.

#### Short version:

- `scoop install openssh`
- Add the scoop shims folder as the *first* `$PATH` item in your `$Profile`: 
  ```$env:PATH=$HOME+"\scoop\shims;"+$env:PATH```

#### Long version:

It is possible to install openssh with `scoop install openssh` as a
normal user and start the ssh-agent as a background process.

However `ssh.exe`, `ssh-agent.exe`, `ssh-add.exe` will be the ones of the native OpenSSH client. The is because user path PATH, which included the scoop openssh binaries is always appended to the systems PATH. The OpenSSH binaries are found first and used. 

To solve this issue you can add the following line to your `$Profile`. Which is in my case:

```
$HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
```

```
$env:PATH=$HOME+"\scoop\shims;"+$env:PATH
```

You can check these registry keys for the system and the user paths:
- System: `req query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v path` 
- User: `req query "HKCU\Environment" /v path`


### On the shoulders of giants...
Pshazz borrows heavily from:

* [Posh-Git](https://github.com/dahlbyk/posh-git) by [Keith Dahlby](http://lostechies.com/keithdahlby/) for Git completions
* [Posh-Hg](https://github.com/JeremySkinner/posh-hg) by [Jeremy Skinner](http://www.jeremyskinner.co.uk/) for Mercurial completions
* [git-credential-winstore](http://gitcredentialstore.codeplex.com/) by [Andrew Nurse](http://vibrantcode.com/) and others, for saving SSH passwords.
* [z.ps](https://github.com/JannesMeyer/z.ps) by [Jannes Meyer](https://github.com/JannesMeyer) for rapid system navigation

Inspired by [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh).

### License

Public Domain
