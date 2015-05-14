@echo off
set CRUDIR=%cd%
set DOCROOT=%~dp0docbook
set PGSRCROOT=%~dp0postgresql
set OPENJADE=%DOCROOT%\openjade-1.3.1
set DSSSL=%DOCROOT%\docbook-dsssl-1.79

cd %PGSRCROOT%\doc\src\sgml
if not exist html md html

set SGML_CATALOG_FILES=%OPENJADE%\dsssl\catalog;%DOCROOT%\docbook\docbook.cat

echo Running Docs build...
%OPENJADE%\bin\openjade -wall -wno-unused-param -wno-empty -D . -c %DSSSL%\catalog -d stylesheet.dsl -i output-html -i include-index -t sgml postgres.sgml 2>&1 | findstr /V "DTDDECL catalog entries are not supported"

if not exist "html\stylesheet.css" copy "stylesheet.css" "html\stylesheet.css"
echo Docs build complete.

cd %CRUDIR%
