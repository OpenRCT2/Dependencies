# Dependencies
Repository for packaging OpenRCT2 library dependencies together.

Builds and packages all the libraries used by the OpenRCT2 Build scripts.

Please keep in mind that this repository does not contain all of the build scripts as some processing and packaging is done in the build server config. If there is a new library dependency added to the OpenRCT2 project, please let IntelOrca and mzmiric5 know as soon as possible as this repo and build system will have to be updated. It is possible that the remainder of the scripts will be stored here later, and the whole process will be more automated (since contributors will be able to just add setps to the build process), but at teh moment, it has to be handled internally.
If you think some of the dependencies should be updated to a newer version, again just let IntelOrca and mzmiric5 know. This is especially important in case of a libcurl update as the project configuration for the build is quite involved.

The VS build script has a dependency on PSCX [https://pscx.codeplex.com/] and having VS 2013 installed.
