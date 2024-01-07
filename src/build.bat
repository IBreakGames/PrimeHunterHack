Rem This requires a C environment set up already, this will not work without it.
Rem Be sure to use the correct version (x86/x64) of gcc for the version of DeSmuME you intend to play on
gcc -I./lua5.1 mouseControl.c -c -fPIC
gcc -L./ -llua51 mouseControl.o -shared -o mouseControl.dll

gcc -I./lua5.1 windowProperties.c -c -fPIC
gcc -L./ -llua51 windowProperties.o -shared -o windowProperties.dll