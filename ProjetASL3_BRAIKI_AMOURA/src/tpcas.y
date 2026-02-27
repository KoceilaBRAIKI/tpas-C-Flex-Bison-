%{
#include <stdio.h>      
#include <stdlib.h>         
#include <string.h>       
#include <unistd.h>   //pour gérer -t/ -h
#include <getopt.h>   //pour gérer -t/ -h
#include "tree.h"

void yyerror(const char *s);    //implémenter tout en bas pour ecrire les messages d'erreurs 
int yylex(void);    //génerer par flex pour lire les mots 

Node *root = NULL;   //c'est la variable qui récupere l'arbre 
extern int yylineno;    //extern car on le recupere dans .l
extern int current_column;
%}


//la localisation exacte ligne/col
%locations

%union {
    char* sval; //texte
    int ival;   //int 
    char cval;  //caractere
    struct Node* node;  // morceaux de l'arbre 
}

%token <sval> IDENT TYPE
%token <ival> NUM
%token <cval> CHARACTER
%token VOID IF ELSE WHILE RETURN STRUCT   //pas besoin d'une valeur 
%token OR AND EQ ORDER ADDSUB DIVSTAR

//renvoyer un noeud d'arbre 
%type <node> Prog Declarations Declaration Declarateurs DeclFoncts DeclFonct EnTeteFonct
%type <node> Parametres ListTypVar Corps SuiteInstr Instr
%type <node> Exp TB FB M E T F Arguments ListExp Champs Champ Acces

%start Prog

%%


//on cree un noeud racine PROG ($$) 
//puis on lui ajoute les déclarations de variables ($1) comme 1er fils
//et on ajoute les fonctions ($2) comme 2ème fils

Prog:  
    Declarations DeclFoncts {        
        $$ = makeNode(PROG);
        addChild($$, $1); 
        addChild($$, $2); 
        root = $$;   //sauvegarde dans root (l'arbre final)
    }
    ;

Declarations:
        //Récursif (On ajoute à la liste existante ($1) le suivant ($2))
       Declarations Declaration {
           addChild($1, $2);  //On renvoie la liste mise à jour
           $$ = $1;  
       }
    |  {    
        $$ = makeNode(DECL_VARS);   //si ya rien on creer un liste vide 
    }
    ;



//gestion des déclaration STRUCT et VARS
Declaration:
        //variable simple 
       TYPE Declarateurs ';' {
           $$ = makeNode(NODE_LIST); 
           Node* typeNode = makeNodeVal(STRUCT_TYPE, $1);
           addChild($$, typeNode);
           addChild($$, $2);
       }
    |  //varibale de type struct 
    STRUCT IDENT Declarateurs ';' {           
           $$ = makeNode(NODE_LIST);
           Node* typeNode = makeNodeVal(STRUCT_TYPE, "struct");
           addChild(typeNode, makeNodeVal(IDENTIFIER, $2));
           addChild($$, typeNode);
           addChild($$, $3);
       }
    |  //définition de type struct 
    STRUCT IDENT '{' Champs '}' ';' {           
           $$ = makeNodeVal(STRUCT_DECL, $2);
           addChild($$, $4);
       }
    ;

Declarateurs:
       Declarateurs ',' IDENT {
           addChild($1, makeNodeVal(IDENTIFIER, $3));
           $$ = $1;
       }
    |  IDENT {
           $$ = makeNode(NODE_LIST);
           addChild($$, makeNodeVal(IDENTIFIER, $1));
       }
    ;

Champs:
       Champs Champ {
           addChild($1, $2);
           $$ = $1;
       }
    | Champ {
           $$ = makeNode(NODE_LIST);
           addChild($$, $1);
    }
    ;

Champ:
       TYPE Declarateurs ';' {
           $$ = makeNode(STRUCT_FIELD);
           addChild($$, makeNodeVal(STRUCT_TYPE, $1));
           addChild($$, $2);
       }
    |  STRUCT IDENT Declarateurs ';' {
           $$ = makeNode(STRUCT_FIELD);
           Node* typeNode = makeNodeVal(STRUCT_TYPE, "struct");
           addChild(typeNode, makeNodeVal(IDENTIFIER, $2));
           addChild($$, typeNode);
           addChild($$, $3);
    }
    ;

DeclFoncts:
       DeclFoncts DeclFonct {
           addChild($1, $2);
           $$ = $1;
       }
    |  DeclFonct {
           $$ = makeNode(DECL_FUNCTS);
           addChild($$, $1);
       }
    ;


// coller l'en-tête $1 dans le corps $2
DeclFonct:
       EnTeteFonct Corps {
           $$ = $1;
           addChild($$, $2);
       }
    ;

EnTeteFonct:
       //fonction classic
       TYPE IDENT '(' Parametres ')' {
           $$ = makeNodeVal(DECL_FUNCT, $2);
           Node* ret = makeNodeVal(RET_TYPE, $1);
           addChild($$, ret);
           addChild($$, $4);
       }
    | //return void 
    VOID IDENT '(' Parametres ')' {
           $$ = makeNodeVal(DECL_FUNCT, $2);
           Node* ret = makeNodeVal(RET_TYPE, "void");
           addChild($$, ret);
           addChild($$, $4);
       }
    |  //return struct
    STRUCT IDENT IDENT '(' Parametres ')' {            
           $$ = makeNodeVal(DECL_FUNCT, $3);
           Node* ret = makeNodeVal(RET_TYPE, "struct");
           addChild(ret, makeNodeVal(IDENTIFIER, $2));
           addChild($$, ret);
           addChild($$, $5);
       }
    ;

Parametres:
       VOID { $$ = makeNode(PARAM); }
    |  ListTypVar { $$ = $1; }
    | { $$ = makeNode(PARAM); }
    ;

ListTypVar:
       ListTypVar ',' TYPE IDENT {
           Node* p = makeNodeVal(IDENTIFIER, $4);
           addChild(p, makeNodeVal(STRUCT_TYPE, $3));
           addChild($1, p);
           $$ = $1;
       }
    |  ListTypVar ',' STRUCT IDENT IDENT {
           Node* p = makeNodeVal(IDENTIFIER, $5);
           Node* t = makeNodeVal(STRUCT_TYPE, "struct");
           addChild(t, makeNodeVal(IDENTIFIER, $4));
           addChild(p, t);
           addChild($1, p);
           $$ = $1;
       }
    |  TYPE IDENT {
           $$ = makeNode(PARAM);
           Node* p = makeNodeVal(IDENTIFIER, $2);
           addChild(p, makeNodeVal(STRUCT_TYPE, $1));
           addChild($$, p);
       }
    |  STRUCT IDENT IDENT {
           $$ = makeNode(PARAM);
           Node* p = makeNodeVal(IDENTIFIER, $3);
           Node* t = makeNodeVal(STRUCT_TYPE, "struct");
           addChild(t, makeNodeVal(IDENTIFIER, $2));
           addChild(p, t);
           addChild($$, p);
       }
    ;

Corps: 
    '{' Declarations SuiteInstr '}' { 
        $$ = makeNode(BODY);
        addChild($$, $2);
        addChild($$, $3);
    }
    ;

SuiteInstr:
       SuiteInstr Instr {
           addChild($1, $2);
           $$ = $1;
       }
    | {
        $$ = makeNode(INSTR_COMP);
    }
    ;

Acces:
       IDENT {
           $$ = makeNodeVal(IDENTIFIER, $1);
       }
    |  Acces '.' IDENT {
           $$ = makeNode(STRUCT_REF);
           addChild($$, $1);
           addChild($$, makeNodeVal(IDENTIFIER, $3));
    }
    ;

//chaque instruction crée un noeud spécifique 
Instr:
       Acces '=' Exp ';' {
           $$ = makeNode(INSTR_ASSIGN);
           addChild($$, $1);
           addChild($$, $3);
       }
    |  IF '(' Exp ')' Instr {
           $$ = makeNode(INSTR_IF);
           addChild($$, $3);//condition 
           addChild($$, $5);//bloc
    }
    |  IF '(' Exp ')' Instr ELSE Instr {
           $$ = makeNode(INSTR_IF);
           addChild($$, $3);//condition 
           addChild($$, $5);//bloc
           addChild($$, $7);//else
    }
    |  WHILE '(' Exp ')' Instr {
           $$ = makeNode(INSTR_WHILE);
           addChild($$, $3);
           addChild($$, $5);
    }
    |  IDENT '(' Arguments  ')' ';' {
           $$ = makeNodeVal(INSTR_CALL, $1);
           addChild($$, $3);
    }
    |  RETURN Exp ';' {
           $$ = makeNode(INSTR_RETURN);
           addChild($$, $2);
    }
    |  RETURN ';' {
           $$ = makeNode(INSTR_RETURN);
    }
    |  '{' SuiteInstr '}' {
           $$ = $2;
    }
    |  ';' {
           $$ = NULL;
    }
    ;


//assurer la priorités 
Exp :  Exp OR TB { $$ = makeNode(OP_OR); addChild($$, $1); addChild($$, $3); }
    |  TB { $$ = $1; }
    ;

TB  :  TB AND FB { $$ = makeNode(OP_AND); addChild($$, $1); addChild($$, $3); }
    |  FB { $$ = $1; }
    ;

FB  :  FB EQ M { $$ = makeNodeVal(OP_EQ, "=="); addChild($$, $1); addChild($$, $3); }
    |  M { $$ = $1; }
    ;

M   :  M ORDER E { $$ = makeNodeVal(OP_GT, "<>"); addChild($$, $1); addChild($$, $3); }
    |  E { $$ = $1; }
    ;

E   :  E ADDSUB T { 
          $$ = makeNodeVal(OP_ADD, "op");
          addChild($$, $1); 
          addChild($$, $3); 
       }
    |  T { $$ = $1; }
    ;    

T   :  T DIVSTAR F { 
          $$ = makeNodeVal(OP_MUL, "op");
          addChild($$, $1); 
          addChild($$, $3); 
       }
    |  F { $$ = $1; }
    ;

F   :  ADDSUB F { 
          $$ = makeNode(OP_UNARY_MINUS); 
          addChild($$, $2); 
       }
    |  '!' F { 
          $$ = makeNode(OP_NOT); 
          addChild($$, $2); 
       }
    |  '(' Exp ')' { $$ = $2; }
    |  NUM { 
           char buffer[20];
           sprintf(buffer, "%d", $1);
           $$ = makeNodeVal(LIT_INT, buffer); 
       }
    |  CHARACTER { 
           char buffer[2];
           buffer[0] = $1; buffer[1] = 0;
           $$ = makeNodeVal(LIT_CHAR, buffer); 
       }
    |  Acces { 
           $$ = $1; 
       }
    |  IDENT '(' Arguments  ')' {
           $$ = makeNodeVal(INSTR_CALL, $1);
           addChild($$, $3);
       }
    ;

Arguments:
       ListExp { $$ = $1; }
    |  { $$ = makeNode(PARAM); }
    ;

ListExp:
       ListExp ',' Exp {
           addChild($1, $3);
           $$ = $1;
       }
    |  Exp {
           $$ = makeNode(PARAM);
           addChild($$, $1);
       }
    ;

%%



int main(int argc, char **argv) {
    int opt;
    int option_index = 0;
    int print_tree = 0;

    //pour accepter -h et --help ....
    static struct option long_options[] = {
        {"tree", no_argument, 0, 't'},
        {"help", no_argument, 0, 'h'},
        {0, 0, 0, 0}
    };

    
    while ((opt = getopt_long(argc, argv, "th", long_options, &option_index)) != -1) {
        switch (opt) {
            case 't': 
                print_tree = 1; 
                break;
            case 'h': 
                fprintf(stderr, "usage: %s [OPTIONS] < file.tpc\n", argv[0]);
                fprintf(stderr, "Analyseur syntaxique pour le langage TPC.\n\n");
                fprintf(stderr, "Options:\n");
                fprintf(stderr, "  -t, --tree   Afficher l'arbre abstrait .\n");
                fprintf(stderr, "  -h, --help   Afficher ce message d'aide.\n");
                fprintf(stderr, "\nExemple:\n");
                fprintf(stderr, "  %s --tree < mon_fichier.tpc\n", argv[0]);
                return 0; 
            default: 
                
                return 2; 
        }
    }

    int res = yyparse();
    
    if (res == 0 && root != NULL) {
        if (print_tree) printTree(root);
        deleteTree(root);
        return 0;
    }
    return 1;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erreur de syntaxe dans la ligne %d et la colonne %d : %s\n", yylineno, current_column, s);
}