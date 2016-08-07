@echo off

REM clean up main directory
git clean -fdX

REM clean up submodules
git submodule foreach "git clean -fdx && git checkout ."