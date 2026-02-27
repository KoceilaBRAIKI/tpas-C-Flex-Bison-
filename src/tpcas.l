%{
#include <stdio.h>    /* printf */
#include <stdlib.h>   /* malloc */
#include <string.h>   /* strdup */
#include "tree.h"     /* pour connaître les types */
#include "tpcas.tab.h" /* pour les tokens (numero) */

int current_column = 1;   /* on l'utilise pour compter manuellement les colonnes */

/* elle met à jour la colonne avant chaque action */
#define YY_USER_ACTION \
    { yylloc.first_line = yylloc.last_line = yylineno; \
      yylloc.first_column = current_column; \
      yylloc.last_column = current_column + yyleng - 1; \
      current_column += yyleng; } /* yyleng la longeur de mot, et yylloc pour localiser */
%}

%option yylineno
%option noyywrap
%option noinput nounput

%%

[ \t]       { } /* ignorer les tabulation et les espaces mais current_column grace à YY_USER_ACTION */
\n          { current_column = 1; } /* on se replace au début */

"/*"([^*]|(\*+[^*/]))*\*+\/ { }  /* ignorer commentaires avec ... c'est une une expression régulière */
"//".* { } /* ignorer commentaires d'une ligne */

"void"      { return VOID; }
"int"       { yylval.sval = strdup(yytext); return TYPE; }  /* yytext c'est le texte exacte , et sval=string values */
"char"      { yylval.sval = strdup(yytext); return TYPE; }
"struct"    { return STRUCT; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"return"    { return RETURN; }

[0-9]+      { yylval.ival = atoi(yytext); return NUM; } /* atoi transforme texte en int */

\'\\?.\'    {  
              if (yytext[1] == '\\') {
                  if (yytext[2] == 'n') yylval.cval = '\n';
                  else if (yytext[2] == 't') yylval.cval = '\t';
                  else if (yytext[2] == '0') yylval.cval = '\0';
                  else yylval.cval = yytext[2]; /* c pas un char */
              } else {
                  yylval.cval = yytext[1]; /* on récupere le char */
              }
              return CHARACTER; 
            }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENT; }    /* identifiant */

"=="|"!="         { return EQ; }
"<"|">"|"<="|">=" { return ORDER; }
"&&"              { return AND; }
"||"              { return OR; }
"+"|"-"           { return ADDSUB; }
"*"|"/"|"%"       { return DIVSTAR; }

[=;(){},!.]       { return yytext[0]; } /* renvoie le code ASCI de caractere */

.                 { 
                    fprintf(stderr, "Erreur lexicale ligne %d colonne %d: car '%s' inconnu\n", 
                            yylineno, current_column, yytext); 
                    exit(1); 
                  }

%%