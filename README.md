# mipt-llvm
## MyLang

### Build
##### Requirements 

* SFML
* CMake

##### Configure

```bash 
mkdir build 
cd build 
cmake ../ 
make all
```

##### Compilation

```bash 
./Bas file.ba >> file.ll
clang++ ../std/lib.cc -c 
clang++ file.ll lib.o -lsfml-graphics -lsfml-window -lsfml-system
./a.out
```
