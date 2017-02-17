let schedule_only = ref false 
and number_steps = ref (-1) 
and filename = ref "" 
and rom_filename = ref ""
and ram_filename = ref "" in

Arg.parse
    [("-print", Arg.Set schedule_only, "Ne fait que l'ordonnancement"); 
    ("-n", Arg.Set_int number_steps, "Nombre d'étapes à simuler"); 
    ("-rom", Arg.Set_string rom_filename, "Fichier contenant la ROM");
    ("-ram", Arg.Set_string ram_filename, "Fichier contenant la RAM")]
    (fun s -> filename := s)
    "";

try
    let filename_sch = ((Filename.chop_suffix !filename ".net") ^ "_sch.net") in

    (* Schedule *)

    let p = 
        if !schedule_only || not(Sys.file_exists filename_sch) then (
            let p =
                (try Scheduler.schedule (Netlist.read_file !filename);
                with | Graph.Has_cycle -> Format.eprintf "The netlist has a combinatory cycle.@."; exit 2 )
            in
            let out = open_out filename_sch in
            Netlist_printer.print_program out p;
            close_out out;
            p
        ) else (
            Netlist.read_file filename_sch
        )
    in 

    (* Simulate *)
    
    if not !schedule_only then (
        let load_file f =
            let ic = open_in f in
            let n = in_channel_length ic in
            let s = Bytes.create n in
            really_input ic s 0 n;
            close_in ic;
            (s)
        in

        let s = (try load_file !rom_filename with Sys_error(s) -> "") in
        let rom = Array.init (String.length s) (fun i -> match s.[i] with '0' -> false | '1' -> true | _ -> assert false) in
        let s = (try load_file !ram_filename with Sys_error(s) -> "") in
        let ram = Array.init (String.length s) (fun i -> match s.[i] with '0' -> false | '1' -> true | _ -> assert false) in

        Simulator.simulate p !number_steps rom ram;
    )
with
    Netlist.Parse_error s -> Format.eprintf "An error accurred: %s@." s; exit 2
