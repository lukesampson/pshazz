# Pshazz
##### Give your powershell some pizazz.

Pshazz extends your powershell profile to add things like

* A nicer prompt, including Git info
* Git tab completion
* An SSH helper that lets you never enter your private key password again.

And it uses themes, so you can create your own [theme](wiki/Themes) if the defaults aren't quite what you want.

### Installation
Using [Scoop](http://scoop.sh):

	scoop install pshazz

### On the shoulders of giants...
Pshazz borrows from:

* [Posh-Git](https://github.com/dahlbyk/posh-git) by [Keith Dahlby](http://lostechies.com/keithdahlby/) for Git completions
* [git-credential-winstore](http://gitcredentialstore.codeplex.com/) by [Andrew Nurse](http://vibrantcode.com/) and others, for saving SSH passwords.
* [z.ps](https://github.com/JannesMeyer/z.ps) by [Jannes Meyer](https://github.com/JannesMeyer) for rapid system navigation

Inspired by [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh).