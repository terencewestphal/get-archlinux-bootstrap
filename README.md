[![Build Status](https://travis-ci.org/terencewestphal/get-archlinux-bootstrap.svg?branch=master)](https://travis-ci.org/terencewestphal/get-archlinux-bootstrap)

# Get Arch Linux Bootstrap
<img src="archlinux-logo.png" alt="Arch Linux" width="350">

Get the latest version of Arch Linux Bootstrap.  
Designed for use in automated build scripts and container images.

## Features

* Source: https://archive.archlinux.org
* Download the Bootstrap archive and signature
* Get latest version or any versions (with option)
* Support both architectures: x86_64 and i686
* Verify the signature with GPG
* Cache for faster builds (optional)
* Remove prefix directory from archive (optional)
* Works on Linux and Mac

## Requirements

Make sure your build server has these commandline utilities installed.

* awk
* bash
* cat 
* curl
* date
* gpg
* tail
* type
* uname

## Usage

Default:

* Latest version
* Arch: x86_64
* Verify signature

```
./get-archlinux-bootstrap.sh
```

Bash One-Liner:

```
curl -sL https://raw.githubusercontent.com/terencewestphal/get-archlinux-bootstrap/master/get-archlinux-bootstrap.sh | bash -
```

Options:  

```
Usage: ./get-archlinux-bootstrap.sh [options...]
  
Options:
-v [version]  Download a specific version. Format: YYYY.MM.DD
-a [arch]     Download a specific architecture. Supported: x86_64, i686
-c            Use local cache. If found skip download
-r            Remove old files before downloading
-t            Trust the signature. Skip verifying the signature
-f            Fix archive. Removes prefix directory from archive (needs Python 3.5+)
-l            Show latest version
-h            Show this help
```

## Tar Fix 
By default the Bootstrap tarbal has its content prefixed with ```root.x86_64``` or ```root.i686``` depending 
on the architecture. This fix removes the tarball's top-level directory from its component paths:

```
./get-archlinux-bootstrap.sh -f
```

* tar_fix.py needs Python 3.5. (It will fail with Python 2, and even with 3.4)
* Credits for this fix go to [Maciej Sieczka](https://github.com/czka/archlinux-docker)
