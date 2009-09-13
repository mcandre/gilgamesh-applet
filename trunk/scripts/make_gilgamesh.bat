@echo off

REM Ignore the following warning:
REM
REM Math::BigInt: couldn't load specified math lib(s),
REM fallback to Math::BigInt::FastCalc at C:/Perl/lib/Win32API/File.pm line 20

pp -o bin\gilgamesh.exe -B -M Error -M YAML -M Crypt::SSLeay -M WWW::Mechanize -M HTML::TokeParser gilgamesh.pl
