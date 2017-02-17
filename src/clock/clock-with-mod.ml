(*
	Notation: Correspondance

	yr: année
	mt: mois
	d: jour
	hr: heure
	mn: minute
	s: seconde
	lim: tableau à 12 entrées qui donne le nombre de jours par mois
*)

let is_leap_year yr =
	if yr mod 400 = 0 then true
	else if yr mod 100 = 0 then false
	else if yr mod 4 = 0 then true
	else false
in

let yr = ref 2015
and mt = ref 12
and d = ref 4
and hr = ref 23
and mn = ref 20
and s = ref 30
and lim = [|0;1;0;1;0;1;0;1;1;0;1;0;1|] (* le premier bit ne sert à rien *)
in

while true do
	s := !s + 1;
	if !s mod 60 = 0 then begin
		s := 0;
		mn := !mn + 1;
		if !mn mod 60 = 0 then begin
			mn := 0;
			hr := !hr + 1;
			if !hr mod 24 = 0 then begin
				hr := 0;
				d := !d + 1;
				if (!mt = 2 && !d = lim.(!mt) + 28 + 1) || !d = lim.(!mt) + 30 + 1 then begin
					d := 1;
					mt := !mt + 1;
					if !mt = 13 then begin
						mt := 1;
						yr := !yr + 1;
						lim.(2) <- 0
						if is_leap_year !yr then lim.(2) <- 1
					end
				end
			end
		end
	end;
	Printf.printf "%d:%d:%d %d/%d/%d\n" !hr !mn !s !d !mt !yr;
done