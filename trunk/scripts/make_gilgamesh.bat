@echo off

echo Ignore the following warning:
echo.
echo "Math::BigInt: couldn't load specified math lib(s),
echo fallback to Math::BigInt::FastCalc at C:/Perl/lib/Win32API/File.pm line 20"
echo.
echo Error:
echo.

pp -o bin\gilgamesh.exe -B -M Error -M YAML -M Crypt::SSLeay -M WWW::Mechanize -M HTML::TokeParser gilgamesh.pl