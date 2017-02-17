open Netlist_ast

let simulate p number_steps rom ram =
    let e = ref Env.empty and e2 = ref Env.empty and number_steps = ref number_steps and step_number = ref 0 and ram = ref ram and ram_for_write = ref [] in

    while !number_steps <> 0 do
        number_steps := !number_steps - 1;
        step_number := !step_number + 1;
        Format.printf ">>>> Step %d\n@?" !step_number;

        (* Read the inputs *)

        let read_bit ident =
            let rec retry () =
              try
                Format.printf "%s ? @?" ident;
                match read_int () with
                | 0 -> false
                | 1 -> true
                | _ -> raise Exit
              with _ -> (print_endline "Invalid bit"; retry ())
            in retry ()
        in

        e := List.fold_left (fun e ident ->
            Env.add ident (match Env.find ident p.p_vars with
                | TBit -> VBit(read_bit ident)
                | TBitArray(l) -> VBitArray(Array.init l (fun i -> read_bit (ident^"["^(string_of_int i)^"]")))
            ) e
        ) !e p.p_inputs;

        (* Compute the equations *)

        let get_value e arg = match arg with
            | Avar(ident) -> Env.find ident e
            | Aconst(value) -> value
        in let get_bit e arg = match get_value e arg with
            | VBit(b) -> b
            | _ -> assert false
        in let get_bitarray e arg = match get_value e arg with
            | VBitArray(a) -> a
            | _ -> assert false
        in let rec int_of_bitarray value = match value with
            | VBit(b) -> int_of_bitarray (VBitArray([|b|]))
            | VBitArray(a) -> Array.fold_right (fun b n -> 2*n + (if b then 1 else 0)) a 0
        in

        e2 := !e;

        ram_for_write := [];
        List.iter (fun (ident, exp) ->
            e2 := Env.add ident (match exp with
                | Earg(arg) -> get_value !e2 arg
                | Ereg(ident) ->
                    (try get_value !e (Avar(ident)) with | Not_found -> (match Env.find ident p.p_vars with
                        | TBit -> VBit(false)
                        | TBitArray(l) -> VBitArray(Array.make l false)
                    ))
                | Enot(arg) -> VBit (not(get_bit !e2 arg))
                | Ebinop(op, arg1, arg2) ->
                    let f b1 b2 = (match op with
                        | Or -> b1 || b2
                        | Xor -> b1 <> b2
                        | And -> b1 && b2
                        | Nand -> not(b1 && b2)
                    ) in
                    let map2 f a1 a2 =
                        let a3 = Array.make (Array.length a1) false in
                        for i = 0 to (Array.length a1) - 1 do
                            a3.(i) <- f a1.(i) a2.(i)
                        done;
                        a3
                    in
                    (match (get_value !e2 arg1, get_value !e2 arg2) with
                        | (VBit(b1), VBit(b2)) -> VBit(f b1 b2)
                        | (VBitArray(a1), VBitArray(a2)) -> VBitArray(map2 f a1 a2)
                        | _ -> assert false)
                | Emux(cond, arg1, arg2) -> if get_bit !e2 cond then get_value !e2 arg1 else get_value !e2 arg2
                | Erom(addr_size, word_size, read_addr) -> 
                    let read_index = word_size * (int_of_bitarray (get_value !e2 read_addr)) in
                    if word_size = 1 then VBit(rom.(read_index)) else VBitArray(Array.sub rom read_index word_size)
                | Eram(addr_size, word_size, read_addr, write_enable, write_addr, data) ->
                    let read_index = word_size * (int_of_bitarray (get_value !e2 read_addr)) in
                    if read_index + word_size > (Array.length !ram) then (
                        ram := Array.init (read_index+word_size) (fun i -> try !ram.(i) with | Invalid_argument(s) -> false)
                    );
                    if get_bit !e2 write_enable then ram_for_write := exp :: !ram_for_write;
                    if word_size = 1 then VBit(!ram.(read_index)) else VBitArray(Array.sub !ram read_index word_size)
                | Econcat(arg1, arg2) -> (match (get_value !e2 arg1, get_value !e2 arg2) with
                    | (VBitArray(a1), VBitArray(a2)) -> VBitArray(Array.concat [a1; a2])
                    | (VBitArray(a1), VBit(b2)) -> VBitArray(Array.concat [a1; [|b2|]])
                    | (VBit(b1), VBitArray(a2)) -> VBitArray(Array.concat [[|b1|]; a2])
                    | (VBit(b1), VBit(b2)) -> VBitArray([|b1; b2|]))
                | Eslice(i1, i2, arg) -> VBitArray(Array.sub (get_bitarray !e2 arg) i1 (i2 - i1 + 1))
                | Eselect(i, arg) -> match get_value !e2 arg with | VBit(b) -> VBit(b) | VBitArray(a) -> VBit(a.(i))
            ) !e2
        ) p.p_eqs;

        e := !e2;

        List.iter (function
            | Eram(addr_size, word_size, read_addr, write_enable, write_addr, data) ->
                if get_bit !e write_enable then (
                    let write_index = word_size * (int_of_bitarray (get_value !e write_addr)) in
                    if word_size = 1 then
                        !ram.(write_index) <- (try get_bit !e data with | Not_found -> false)
                    else
                        Array.iteri (fun i b -> !ram.(write_index + i) <- b) (try get_bitarray !e data with | Not_found -> Array.make word_size false)
                )
            | _ -> assert false
        ) !ram_for_write;

        (* Write the outputs*)

        let string_of_bool b = if b then "1" else "0" in
        let print_value ident =
            Format.printf "%s : %s\n@?" ident (match Env.find ident !e with
                | VBit(b) -> string_of_bool(b)
                | VBitArray(a) ->
                    snd(Array.fold_left (fun (i, s) b ->
                        (i+1, (string_of_bool b)^s)
                    ) (0, "") a)
            )
        in
        List.iter (fun ident -> print_value ident) p.p_outputs;
    done