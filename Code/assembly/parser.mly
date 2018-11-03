%{
    open Ast
%}

%token EOF, COMMA
%token <int>CINT
%token <string>IDENT

%start fichier

%type <Ast.fichier> fichier

%%

fichier:
    instrl=instr+ EOF { instrl }

instr:
    desc1=instr_desc { { i_desc = desc1; i_pos = ($startpos, $endpos) } }
instr_desc:
    ident1=IDENT intl=separated_nonempty_list(COMMA, CINT) { (ident1, intl) }