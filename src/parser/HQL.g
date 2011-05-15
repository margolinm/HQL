grammar HQL;

options {
  language = Java;
  output=AST;
  //backtrack = true;
  //memoize = true;
}

tokens{
   TREE_NODE;
   COLUMN_DEF;
   TABLE_DEF;
   DATASET_SPEC;
   END_OF_STATEMENT;
}

@header {
  package parser;
}

@lexer::header {
  package parser;
}

start_rule:
   define SEMICOLON (define SEMICOLON)* EOF 
;

define:
   DEFINE a=DATASET? dataset_name dataset_spec data? 
      -> ^(DEFINE 
            ^(
               {
                  new CommonTree($a == null ? new CommonToken(DATASET, "DATASET") : $a)
               } 
               dataset_name dataset_spec) data?)
;

dataset_spec:
   'AS'? dataset_type_subset2 'OF'? DATA_TYPE? 
      -> ^(DATASET_SPEC dataset_type_subset2 DATA_TYPE?)
   | 'AS'!? table_spec 
;

data:  
   data_statement | table_statement | tree_statement
;

fragment
data_statement:
   PUT dataset_type_subset1 LEFT_BRACE data_elements RIGHT_BRACE 
      -> ^(PUT dataset_type_subset1 data_elements)
;

table_spec:
   TABLE table_definition -> ^(TABLE_DEF table_definition)
;

fragment
table_statement:
   PUT TABLE LEFT_BRACE record_statements RIGHT_BRACE 
      -> ^(PUT TABLE record_statements)
;
   
fragment
record_statements:
   record_statement (COMMA record_statement)* -> record_statement+ 
;

fragment
record_statement:
   RECORD LEFT_PAREN data_elements RIGHT_PAREN -> ^(RECORD data_elements)
;

fragment
tree_statement:
   PUT TREE LEFT_BRACE tree_elem RIGHT_BRACE 
      -> ^(PUT TREE tree_elem)
   | PUT BINARY_TREE LEFT_BRACE tree_elem RIGHT_BRACE 
      -> ^(PUT BINARY_TREE tree_elem)
;

fragment
tree_elem:
   data_element (LEFT_PAREN node_to+=tree_elem (COMMA node_to+=tree_elem)* RIGHT_PAREN)*
      -> ^(TREE_NODE data_element $node_to*)
;

data_elements:
   data_element (COMMA data_element)* 
      -> data_element+
;

data_element:
   value | data | node_to_node | include | define 
;

value:
   NUMBER | QUOTED_STRING | date
;

node_to_node: 
   node TO node_to+=node (COLON node_to+=node)* 
      -> ^(TO node $node_to+)
;

node:
   value | include 
;

include: 
   INCLUDE dataset_type dataset_name 
      -> ^(INCLUDE dataset_type dataset_name)
;

dataset_name:
   ID
;


table_definition:
	LEFT_PAREN column_definition (COMMA column_definition)* RIGHT_PAREN 
      -> column_definition+ 
;

column_definition:
   column_name DATA_TYPE 
      -> ^(COLUMN_DEF column_name DATA_TYPE) 
   | define
; 

column_name:
   ID
;

dataset_type_subset1:
   LIST
   | ORDERED_LIST    
   | TEXT        
   | GRAPH
   | SINGLETON
;
   
dataset_type_subset2:
   LIST     
   | ORDERED_LIST
   | TREE
   | BINARY_TREE
   | TEXT
   | GRAPH    
   | SINGLETON
;
   
dataset_type: 
   LIST     
   | ORDERED_LIST
   | TABLE     
   | TREE
   | BINARY_TREE
   | TEXT
   | GRAPH    
   | SINGLETON
;

date:
   QUOTE 
   month 
//   {
//      String s = $n.text;
//   } 
   '/' 
   day 
   //{s = $n.text;}
   '/' 
   year 
   QUOTE
;
   
month:
   n=N 
      {
         String s = $n.text; 
         int n1 = Integer.parseInt(s);
         if (n1 >= 1 && n1 <= 12) throw new RecognitionException(); // !!! add proper exception later
      }
;

day:
   n=N 
      {
         String s = $n.text; 
         int n1 = Integer.parseInt(s);
         if (n1 >= 1 && n1 <= 31) throw new RecognitionException(); // !!! add proper exception later
      }
;

year:
   N
;

   LIST: 'LIST';        
   ORDERED_LIST: 'ORDERED_LIST';    
   TABLE: 'TABLE';     
   TREE: 'TREE';
   BINARY_TREE: 'BINARY_TREE'; 
   TEXT: 'TEXT';        
   GRAPH: 'GRAPH'; 
   SINGLETON: 'SINGLETON';
   
   PUT: 'PUT';
   INCLUDE: 'INCLUDE';
   RECORD: 'RECORD';
   DEFINE: 'DEFINE'; 
   DATASET: 'DATASET';
   TO: 'TO';

DATA_TYPE: 
   'STRING' | 'STRINGS' | 'NUMBER' | 'NUMBERS' | 'DATE' | 'DATES' | 'HF' | 'HH'
;

QUOTED_STRING
   :  '\'' (~('\'') )* '\''
   ;
ID /*options { testLiterals=true; }*/
    : ('a'..'z' | 'A' .. 'Z') ( 'a'..'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
    | DOUBLEQUOTED_STRING
    ;
SEMICOLON
   :  ';'
   ;
COLON
   :  ':'
   ;
DOUBLEDOT
   :  POINT POINT
   ;
DOT
   :  POINT
   ;
fragment
POINT
   :  '.'
   ;
COMMA
   :  ','
   ;
EXPONENT
   :  '**'
   ;
ASTERISK
   :  '*'
   ;
AT_SIGN
   :  '@'
   ;
RIGHT_PAREN
   :  ')'
   ;
LEFT_PAREN
   :  '('
   ;
RIGHT_BRACKET
   :  ']'
   ;
LEFT_BRACKET
   :  '['
   ;
RIGHT_BRACE
   :  '}'
   ;
LEFT_BRACE
   :  '{'
   ;
PLUS
   :  '+'
   ;
MINUS
   :  '-'
   ;
DIVIDE
   :  '/'
   ;
EQUAL
   :  '='
   ;
PERCENTAGE
   :  '%'
   ;
LLABEL
   :  '<<'
   ;
RLABEL
   :  '>>'
   ;
ASSIGN
   :  ':='
   ;
ARROW
   :  '=>'
   ;
VERTICAL_BAR
   :  '|'
   ;
DOUBLE_VERTICAL_TBAR
   :  '||'
   ;
NOT_EQUAL
   :  '<>' | '!=' | '^='
   ;
LESS_THEN
   :  '<'
   ;
LESS_OR_EQUAL
   :  '<='
   ;
GREATER_THEN
   :  '>'
   ;
GREATER_OR_EQUAL
   :  '>='
   ;

NUMBER
   :  //( PLUS | MINUS )?
      (  ( N POINT N ) => N POINT N
      |  POINT N
      |  N
      )
      ( 'E' ( PLUS | MINUS )? N )?
    ;

fragment
N
   : '0' .. '9'+
   ;
   
fragment
DIGIT
   : '0' .. '9'
   ;
   
QUOTE
   :  '\''
   ;
fragment
DOUBLEQUOTED_STRING
   :  '"' ( ~('"') )* '"'
   ;
WS :  (' '|'\r'|'\t'|'\n') {$channel=HIDDEN;}
;

