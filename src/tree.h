#ifndef TREE_H
#define TREE_H

typedef enum {
  // noeuds  principals
  PROG,            //le point de dépard
  BODY,            //block entre {}
  DECL_VARS,        // déclaration de variable 
  DECL_FUNCTS,      //noeud de toutes les fonctions 
  DECL_FUNCT,       //noeud d'une seule fonction
  PARAM,            //paramétre de la fonction 
  RET_TYPE,         //type de retour de la fonction 
  
  // Les instructions 
  INSTR_IF,         //condition if
  INSTR_WHILE,      //boucle while
  INSTR_RETURN,     //return dans une fonction 
  INSTR_ASSIGN,     //affectation a=3;
  INSTR_CALL,       //appel de fonction 
  INSTR_COMP,       //instruction composée (un block de plusieurs instruction )
  
  //  Types 
  TYPE_INT,   //int
  TYPE_CHAR,  //char
  TYPE_VOID,  //void
  
  // Opérateurs 
  OP_OR,  // ||
  OP_AND, // &&
  OP_EQ,  //==
  OP_NEQ, //!=
  OP_GT,  //>
  OP_LT,  //<
  OP_GTE, //>=
  OP_LTE, //<=
  OP_ADD, //+
  //(pour l'instant je gere tout avec add +)
  OP_SUB, //-
  OP_MUL, //*
  OP_DIV, // "/"
  OP_MOD, //modulo %
  OP_NOT, // !
  OP_UNARY_MINUS, //nombre négatif
  OP_UNARY_PLUS,  //nombre positif
  
  // Terminaux avec valeurs 
  IDENTIFIER,  //  un nom (identifion)
  LIT_INT,  //un nombre (x=11; 11 en est un )
  LIT_CHAR, // un caractere 
  
  // Structures 
  STRUCT_DECL,      // déclaration d'une structure 
  STRUCT_TYPE,      // type struct d'une variable 
  STRUCT_FIELD,     //champs dans struct 
  NODE_LIST,        // pour gerer les suites ....
  STRUCT_REF        //l'accés à un champs strucN.champsN
} label_t;          


//liste chainée 
typedef struct Node {
  label_t label;  //l'étiquette 
  char *value;         //valeur (je l'ai ajouter car les noeuds stock des valeur)
  struct Node *firstChild, *nextSibling;
  int lineno;   //la ligne
} Node;

Node *makeNode(label_t label);
Node *makeNodeVal(label_t label, char *val); //j'ai ajouter cette fonction pour les noeud qui porte une valeur 
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node *node);
void printTree(Node *node);

#endif