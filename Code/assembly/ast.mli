type ident = string

type instr = {
	i_desc: instr_desc; i_pos: Lexing.position * Lexing.position }
and instr_desc = ident * int list

type fichier = instr list