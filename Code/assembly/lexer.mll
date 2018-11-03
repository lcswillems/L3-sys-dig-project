{
    open Lexing
    open Parser

    exception Lexing_error of string
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']

rule token = parse
    | eof { EOF }
    | "\n" { Lexing.new_line lexbuf; token lexbuf }
    | [' ' '\t'] { token lexbuf }
    | "," { COMMA }
    | "#" { comment lexbuf }
    | digit+ as i { let i = int_of_string i in CINT(i) }
    | alpha+ as s { let s = String.lowercase s in IDENT(s) }
    | _ as s { raise (Lexing_error (Printf.sprintf "%C" s)) }

and comment = parse
    | eof { EOF }
    | "\n" { Lexing.new_line lexbuf; token lexbuf }
    | _ { comment lexbuf }