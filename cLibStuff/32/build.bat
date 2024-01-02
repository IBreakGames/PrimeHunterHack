gcc -I./lua5.1 mouseControl.c -c -fPIC
gcc -L./ -llua51 mouseControl.o -shared -o mouseControl.dll

gcc -I./lua5.1 windowIdentifier.c -c -fPIC
gcc -L./ -llua51 windowIdentifier.o -shared -o windowIdentifier.dll