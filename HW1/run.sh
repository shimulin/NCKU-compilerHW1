rm a.out
flex scanner.l
gcc -Wall -o myscanner lex.yy.c -lfl
./myscanner test.rs >> test.out