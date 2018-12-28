# Funky

Funky is a status bar utility which allows you to easily toggle the function key on your Mac on a per app basis.

## Usage 

Funky maintains a list of apps for which it will set the function key to standard F1, F2, etc. In order to edit the list, follow the steps below:

1. From the status bar icon trigger the *Preferences* dialog and navigate to *Apps*. 
2. Use the `+` sign to add a new app bundle.

## Bugs / Feature Requests

Use GitHub's [issue tracker](https://github.com/thecatalinstan/Funky/issues) to submit bug reports feature requests, or just to say hi.

## Pre-Built Binaries

You can download pre-built binaries of Funky from two sources:

- **GitHub:** see the [Releases](https://github.com/thecatalinstan/Funky/releases) section. [https://github.com/thecatalinstan/Funky/releases](https://github.com/thecatalinstan/Funky/releases)
- **Mac AppStore:** free to download from the [Mac AppStore](https://itunes.apple.com/app/funky/id1210707379) at [https://itunes.apple.com/app/funky/id1210707379](https://itunes.apple.com/app/funky/id1210707379).

## Building

Building should be straightforward, except for one little caveat: Funky is also distributed through the Mac AppStore, therefore it performs a [MAS receipt validation](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1). 

This means that if you try to run a *release* build, it will fail to start as there is no actual Mac AppStore receipt present.

In order to disable the check, simply set the `DEVELOPMENT` variable to `1`, either in the `main.m` file or through a compile-time define.

---

## Contributors Welcome

Since my time is fairly limited, contributions are more than welcome to, well, *contribute*. If you think Funky is a useful tool and your macOS kung-fu is strong, feel free to fork and submit a pull request.

## Privacy Policy

Please carefully read the [Privacy Policy](https://github.com/thecatalinstan/Funky/blob/master/Privacy.md).
