open Ast

exception Typing_error of string

let raise_error params = raise (Typing_error (match params with   
    | "instr_not_found"::a::[] -> Printf.sprintf "L'instruction '%s' n'existe pas." a
    | "instr_not_format"::a::[] -> Printf.sprintf "L'instruction n'est pas du format '%s'." a
    | "param_not_format"::a::b::[] -> Printf.sprintf "'%s' n'est pas du format '%s'." a b
    | a::q -> a
    | [] -> ""
))

let check_imm_format n =
    if not(0 <= n && n <= 65535) then raise_error ["param_not_format"; string_of_int n; "immédiat"]

let check_reg_format n =
    if not(0 <= n && n <= 15) then raise_error ["param_not_format"; string_of_int n; "registre"]

let pos = ref (Lexing.dummy_pos, Lexing.dummy_pos)

let program fichier =
    let env = [
        "li", "L";
        "addiu", "I";
        "bne", "I";
        "sltu", "R";
        "srlv", "R";
        "and", "R";
        "or", "R";
        "j", "J";
        "lw", "I";
        "sw", "I"
    ]
    in

    let rec type_instr env instr = pos := instr.i_pos; match instr.i_desc with (ident1, intl) ->
        try (
            let format1 = List.assoc ident1 env in match (format1, intl) with
                | ("L", a::b::[]) -> check_reg_format a; check_imm_format b
                | ("R", a::b::c::[]) -> check_reg_format a; check_reg_format b; check_reg_format c
                | ("I", a::b::c::[]) -> check_reg_format a; check_reg_format b; check_imm_format c
                | ("J", a::[]) -> check_imm_format a
                | _ -> raise_error ["instr_not_format"; format1]
        )
        with Not_found -> raise_error ["instr_not_found"; ident1]
    in

    List.iter (fun instr -> type_instr env instr) fichier