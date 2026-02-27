#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

extern int yylineno;       //gérer autoamtiquement par flex contrairement au td, sert à compter les lignes 

//même ordre que dans l'enum
static const char *StringFromLabel[] = {
  "Program", "Body", "DeclVars", "DeclFuncts", "DeclFunct", "Params", "RetType",
  "If", "While", "Return", "Assign", "Call", "Block",
  "Int", "Char", "Void",
  "OR", "AND", "EQ", "NEQ", "GT", "LT", "GTE", "LTE", 
  "Add", "Sub", "Mul", "Div", "Mod", "Not", "Neg", "Pos",
  "Ident", "Num", "CharLit",
  "StructDecl", "StructType", "FieldAccess",
  "NodeList", "StructRef"
};

Node *makeNode(label_t label) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node->value = NULL; 
  node->firstChild = node->nextSibling = NULL;
  node->lineno = yylineno;
  return node;
}

 // J'ai ajouté le champ "value" dans la structure Node pour gérer les identifiants.
Node *makeNodeVal(label_t label, char *val) {
    Node *n = makeNode(label);
    if (val) n->value = strdup(val);   //la valeur apres un malloc
    return n;
}


//ajouter un frére
void addSibling(Node *node, Node *sibling) {
  if (!node) return;
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (!parent || !child) return;
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (!node) return;
  if (node->firstChild) deleteTree(node->firstChild);
  if (node->nextSibling) deleteTree(node->nextSibling);
  if (node->value) free(node->value);
  free(node);
}

void printTree(Node *node) {
  if (!node) return;
  static bool rightmost[128]; 
  static int depth = 0;       
  
  for (int i = 1; i < depth; i++) {
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 "); //des code unicode pour faire les dessins 
  }
  
  printf("%s", StringFromLabel[node->label]);
  if (node->value) {
      printf(": %s", node->value);
  }
  printf("\n");
  
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}