open Ast

let rec bytecode_from_int nbb n = match nbb with
    | 0 -> ""
    | _ -> bytecode_from_int (nbb - 1) (n / 2) ^ string_of_int (n mod 2)

let bytecode_from_format format intl = match (format, intl) with
    | ("L", a::b::[]) ->    bytecode_from_int 4 0 ^ bytecode_from_int 4 0 ^ bytecode_from_int 4 a ^ bytecode_from_int 16 b
    | ("R", a::b::c::[]) -> bytecode_from_int 4 b ^ bytecode_from_int 4 c ^ bytecode_from_int 4 a ^ bytecode_from_int 16 0
    | ("I", a::b::c::[]) -> bytecode_from_int 4 b ^ bytecode_from_int 4 0 ^ bytecode_from_int 4 a ^ bytecode_from_int 16 c
    | ("J", a::[]) ->       bytecode_from_int 4 0 ^ bytecode_from_int 4 0 ^ bytecode_from_int 4 0 ^ bytecode_from_int 16 a
    | _ -> assert false

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

    List.fold_left (fun bytecode instr -> match instr.i_desc with (ident1, intl) ->
        let string_rev s =
            let len = String.length s in
            String.init len (fun i -> s.[len - 1 - i])
        in

        bytecode ^ string_rev ((match ident1 with
            | "li" -> "0000" 
            | "addiu" -> "0001"
            | "bne" -> "0010"
            | "sltu" -> "0011"
            | "srlv" -> "0100"
            | "and" -> "0101"
            | "or" -> "0110"
            | "j" -> "0111"
            | "lw" -> "1000"
            | "sw" -> "1001"
            | _ -> assert false)
        ^ bytecode_from_format (List.assoc ident1 env) intl)
    ) "" fichier