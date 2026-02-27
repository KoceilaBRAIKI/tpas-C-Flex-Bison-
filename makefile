CC = gcc
CFLAGS = -Wall -g -Iobj -Isrc

#1 fichier final
all: bin/tpcas

#6 La liste des fichiers nécessaires
bin/tpcas: obj/tpcas.tab.o obj/lex.yy.o obj/tree.o
	$(CC) $(CFLAGS) -o bin/tpcas obj/tpcas.tab.o obj/lex.yy.o obj/tree.o

#3 crée obj/tpcas.tab.o
obj/tpcas.tab.o: obj/tpcas.tab.c
	$(CC) $(CFLAGS) -c -o obj/tpcas.tab.o obj/tpcas.tab.c

#4 crée obj/lex.yy.o 
obj/lex.yy.o: obj/lex.yy.c
	$(CC) $(CFLAGS) -c -o obj/lex.yy.o obj/lex.yy.c

#5 crée obj/tree.o 
obj/tree.o: src/tree.c src/tree.h
	$(CC) $(CFLAGS) -c -o obj/tree.o src/tree.c

#2 crée le .c et le .h à partir du .y
obj/tpcas.tab.c: src/tpcas.y
	bison -d -o obj/tpcas.tab.c src/tpcas.y

#3 crée obj/lex.yy.c 
obj/lex.yy.c: src/tpcas.l obj/tpcas.tab.c
	flex -o obj/lex.yy.c src/tpcas.l

clean:
	rm -f obj/* bin/tpcas