#!/bin/sh

[ ! -d build ] && mkdir build

if [ -f build/$1.exe ]; then
    rm build/$1.exe
fi

cp src/$1.asm lib/
if [ $? -ne 0 ]; then
    echo "Failed to copy $1.asm to lib directory."
    goto_cleanup_on_fail
fi

cd lib
if [ $? -ne 0 ]; then
    echo "Failed to change directory to lib."
    goto_cleanup_on_fail
fi

printf "\n----------------ASSEMBLING----------------\n\n"
wine aml.exe /c /Zd /coff $1.asm
if [ $? -ne 0 ]; then
    echo "Assembly of $1.asm failed."
    cd ..
    goto_cleanup_on_fail
fi

printf "\n----------------LINKING----------------\n\n"
wine alink.exe /SUBSYSTEM:CONSOLE $1.obj /OUT:"../build/$1.exe"
if [ $? -ne 0 ]; then
    echo "Linking $1.obj failed."
    cd ..
    goto_cleanup_on_fail
fi

cd ..

printf "\n----------------EXECUTING----------------\n\n"
wine build/$1.exe
if [ $? -ne 0 ]; then
    echo "Execution of $1.exe failed."
    goto_cleanup_on_fail
fi

goto_cleanup_on_success

goto_cleanup_on_fail() {
    if [ -f lib/$1.asm ]; then
        rm lib/$1.asm
    fi
    if [ -f lib/$1.obj ]; then
        rm lib/$1.obj
    fi
    if [ -f build/$1.exe ]; then
        rm build/$1.exe
    fi
    exit 1
}

goto_cleanup_on_success() {
    rm lib/$1.asm lib/$1.obj
    exit 0
}
