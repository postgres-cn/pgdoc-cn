@echo off

REM src/tools/msvc/builddoc.bat
REM all the logic for this now belongs in builddoc.pl. This file really
REM only exists so you don't have to type "perl builddoc.pl"
REM Resist any temptation to add any logic here.
set DOCROOT=%~dp0..\..\..\..\docbook
@perl builddoc.pl %*
