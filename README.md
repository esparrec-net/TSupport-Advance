# TSupport-Advance ( TSP-A )

This is magisk module DO NOT FLASH FROM RECOVERY!

Merge version of TSupport and CITadvance. Might lose some feature from TSupport but its not a problem the main objective is working better than TSupport or CITadvance.

This module support for older and newer version of Magisk/KSU/APATCH. `Action button` only available for Magisk 27008+ so dont ask me why there is no `Action button`.

## Installation

Install from Magisk/KernelSU/Apatch Manager.

About PIF Generator configuration, you can hold your screen for a second and it will automatically set to default settings. Useful if your VOL+ and VOL- having issue. ( Its time to buy new phone! )

Auto add app to `target.txt` every 1 minutes. This can be disable, add/create new file `stop-tspa-auto-target` in Internal Storage ( `/sdcard` or `/storage` ).

You can add `exclude.txt` to Internal Storage `/sdcard` or `/storage` to exclude package name from added to `target.txt`, If you add package name with `!` at the end of the package name in `exclude.txt` then that package name will be added to `target.txt` without `!`. More info about `!` you can read from Tricky Store description. ( No link! find your own! )

spoofProvider - Set to False/No if youre using PlayIntegrityFix Fork

spoofSignature - Set to True/Yes if your ROM Sign is Testkey.

## Requirements

- Magisk/KernelSU/Apatch ( Recommended to use Magisk 27008+ )
- Tricky Store
- PlayIntegrityFix

## Acknowledgements

This repository incorporates code from the osm0sis project ([PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)). I acknowledge that the original authors and contributors have created valuable work, and I encourage users to respect the licensing terms of the original project.
