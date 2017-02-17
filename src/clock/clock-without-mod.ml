(*
	Notation: Correspondance

	yr: année
	yrM4: année % 4
	yrM100: année % 100
	yrM400: année % 400
	mt: mois
	d: jour
	hr: heure
	mn: minute
	s: seconde
	lim: tableau à 12 entrées qui donne le nombre de jours par mois
*)

let yr = ref 2015
and yrM4 = ref 3
and yrM100 = ref 15
and yrM400 = ref 15
and mt = ref 12
and d = ref 4
and hr = ref 23
and mn = ref 20
and s = ref 30
and lim = [|0;1;0;1;0;1;0;1;1;0;1;0;1|] (* le premier bit ne sert à rien *)
in

while true do
	s := !s + 1;
	if !s = 60 then begin
		s := 0;
		mn := !mn + 1;
		if !mn = 60 then begin
			mn := 0;
			hr := !hr + 1;
			if !hr = 24 then begin
				hr := 0;
				d := !d + 1;
				if (!mt = 2 && !d = lim.(!mt) + 28 + 1) || !d = lim.(!mt) + 30 + 1 then begin
					d := 1;
					mt := !mt + 1;
					if !mt = 13 then begin
						mt := 1;
						yr := !yr + 1;

						(* Modification des valeurs de yr modulo *)
						yrM4 := !yrM4 + 1;
						if !yrM4 = 4 then yrM4 := 0;
						yrM100 := !yrM100 + 1;
						if !yrM100 = 100 then yrM100 := 0;
						yrM400 := !yrM400 + 1;
						if !yrM400 = 400 then yrM400 := 0;

						(* Test si l'année est bissextile *)
						lim.(2) <- 0
						if !yrM400 = 0 || (!yrM100 > 0 && !yrM4 = 0) then lim.(2) <- 1
					end
				end
			end
		end
	end;
	Printf.printf "%d:%d:%d %d/%d/%d\n" !hr !mn !s !d !mt !yr
done