open Netlist_ast
open Graph

let read_exp = fun (ident, exp) ->
	let vars = ref [] in
	let extract_ident args = List.iter (function | Avar(ident) -> vars := ident::!vars | Aconst(_) -> ()) args in
	(match exp with
		| Earg(arg) | Enot(arg) | Eslice(_, _, arg) | Eselect(_, arg) -> extract_ident [arg]
		| Ebinop(_, arg1, arg2) | Econcat(arg1, arg2) -> extract_ident [arg1;arg2]
		| Emux(arg1, arg2, arg3) -> extract_ident [arg1;arg2;arg3]
		| Ereg(_) -> ()
		| Erom(_, _, arg) -> extract_ident [arg]
		| Eram(_, _, arg1, arg2, arg3, arg4) -> extract_ident [arg1;arg2;arg3;arg4]
	); !vars

let schedule p =
	let g = mk_graph() in
	List.iter (fun (ident, exp) -> add_node g ident) p.p_eqs;
	List.iter (fun (ident_to, exp) ->
		List.iter (fun ident_from ->
			add_edge g ident_from ident_to;
		) (read_exp (ident_to, exp))
	) p.p_eqs;
	{ p_eqs =  List.map (fun v -> (v, List.assoc v p.p_eqs)) (topological g); 
	  p_inputs = p.p_inputs ; 
	  p_outputs = p.p_outputs ; 
	  p_vars = p.p_vars }
