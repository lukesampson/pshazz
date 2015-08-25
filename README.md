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

	scoop install pshazz

### On the shoulders of giants...
Pshazz borrows heavily from:

* [Posh-Git](https://github.com/dahlbyk/posh-git) by [Keith Dahlby](http://lostechies.com/keithdahlby/) for Git completions
* [Posh-Hg](https://github.com/JeremySkinner/posh-hg) by [Jeremy Skinner](http://www.jeremyskinner.co.uk/) for Mercurial completions
* [git-credential-winstore](http://gitcredentialstore.codeplex.com/) by [Andrew Nurse](http://vibrantcode.com/) and others, for saving SSH passwords.
* [z.ps](https://github.com/JannesMeyer/z.ps) by [Jannes Meyer](https://github.com/JannesMeyer) for rapid system navigation

Inspired by [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh).
