rmdir /s /q build
perl .\tools\encoding_convert.pl
cd build\src\tools\msvc
.\builddoc.bat
