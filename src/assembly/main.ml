open Lexing;;

try (
    let file = ref "" in

    let get_pos pos = (pos.pos_lnum, pos.pos_cnum - pos.pos_bol + 1) in
    let print_pos (pos1, pos2) =
        let pos1 = get_pos pos1 and pos2 = get_pos pos2 in
        Printf.printf "File \"%s\", line %d, characters %d-%d:\n" !file (fst pos1) (snd pos1) (snd pos2)
    in

    Arg.parse
        []
        (fun s -> print_string s; print_newline();
            if s = "" then (Printf.printf "No file to compile\n"; exit 1)
            else if not (Filename.check_suffix s ".s") then (Printf.printf "The file must have .s extension\n"; exit 1)
            else file := s
        )
        "";

    let lexbuf = Lexing.from_channel (open_in !file) in
    try
        let pass1 = Parser.fichier Lexer.token lexbuf in
        Typer.program pass1;
        let out = open_out ((Filename.chop_suffix !file ".s") ^ ".byte") in
        Printf.fprintf out "%s" (Compiler.program pass1);
        close_out out;
        exit 0
    with
        | Lexer.Lexing_error c ->
            print_pos (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf);
            Printf.printf "lexical error: %s\n" c;
            exit 1
        | Parsing.Parse_error | Parser.Error ->
            print_pos (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf);
            Printf.printf "syntax error\n";
            exit 1
        | Typer.Typing_error c ->
            print_pos !(Typer.pos);
            Printf.printf "typing error : %s\n" c;
            exit 1
) with _ ->
    Printf.printf "compiler error\n";
    exit 2