# Registre: Correspondance
#
# 0: année
# 1: année % 4
# 2: année % 100
# 3: année % 400
# 4: mois
# 5: jour
# 6: heure
# 7: minute
# 8: seconde
# 9: tableau à 12 entrées qui donne le nombre de jours par mois
# 10: utilisé pour faire les conditions
# 11: utilisé pour faire les conditions
# 12: utilisé pour faire les conditions
# 13: utilisé pour faire les conditions
#
# Instruction (MIPS): Correspondance
#
# li: load immediate
# addiu: add immediate unsigned
# bne: branch on not equal
# sltu: set less than unsigned
# srlv: shift right logical variable
# and: and
# or: or
# j: jump

# Initilisation des registres

# li 0, 2015
# li 1, 3
# li 2, 15
# li 3, 15
# li 4, 12
# li 5, 4
# li 6, 23
# li 7, 20
# li 8, 30
# li 9, 5546 # valeur décimale de 0101010110101 avec le bit de poids faible à gauche
lw 0, 15, 0
lw 1, 15, 1
lw 2, 15, 2
lw 3, 15, 3
lw 4, 15, 4
lw 5, 15, 5
lw 6, 15, 6
lw 7, 15, 7
lw 8, 15, 8
lw 9, 15, 9

# Corps du while

# Dirac dans le registre 15 pour savoir que l'on commence un nouveau cycle
li 15, 1
li 15, 0
addiu 8, 8, 1
# if !s = 60 then begin
li 10, 60
bne 8, 10, 64
	li 8, 0
	addiu 7, 7, 1
	# if !mn = 60 then begin
	bne 7, 10, 61
		li 7, 0
		addiu 6, 6, 1
		# if !hr = 24 then begin
		li 10, 24
		bne 6, 10, 57
			li 6, 0
			addiu 5, 5, 1
			# if (!mt = 2 && !d = lim.(!mt) + 28 + 1) || !d = lim.(!mt) + 30 + 1 then begin
			li 10, 3
			sltu 11, 4, 10
			li 10, 1
			sltu 12, 10, 4
			and 11, 11, 12 # met la valeur de !mt = 2 dans le registre 11
			srlv 10, 9, 4
			li 12, 1
			and 10, 10, 12
			addiu 10, 10, 28 # met la valeur de lim.(!mt) + 28 dans le registre 10
			sltu 12, 10, 5
			addiu 10, 10, 2
			sltu 13, 5, 10
			and 12, 12, 13 # met la valeur de !d = lim.(!mt) + 28 + 1) dans le registre 12
			and 11, 11, 12 # met la valeur de !mt = 2 && !d = lim.(!mt) + 28 + 1 dans le registre 11
			srlv 10, 9, 4
			li 12, 1
			and 10, 10, 12
			addiu 10, 10, 30 # met la valeur de lim.(!mt) + 30 dans le registre 10
			sltu 12, 10, 5
			addiu 10, 10, 2
			sltu 13, 5, 10
			and 12, 12, 13
			or 11, 11, 12 # met la valeur de !mt = 2 && !d = lim.(!mt) + 28 + 1) || !d = lim.(!mt) + 30 + 1 dans le registre 11
			li 10, 1
			bne 11, 10, 30
				li 5, 1
				addiu 4, 4, 1
				# if !mt = 13 then begin
				li 10, 13
				bne 4, 10, 26
					li 4, 1
					addiu 0, 0, 1

					# Modification des valeurs de yr modulo

					addiu 1, 1, 1
					# if !yrM4 = 4 then
					li 10, 4
					bne 1, 10, 1
						li 1, 0

					addiu 2, 1, 1
					# if !yrM100 = 100 then
					li 10, 100
					bne 2, 10, 1
						li 2, 0

					addiu 3, 1, 1
					# if !yrM400 = 400 then
					li 10, 400
					bne 3, 10, 1
						li 3, 0

					# Test si l'année est bissextile
					li 9, 5546 # valeur décimale de 0101010110101 avec le bit de poids faible à gauche
					# if !yrM400 = 0 || (!yrM100 > 0 && !yrM4 = 0) then
					li 10, 1
					sltu 11, 3, 10 # met la valeur de !yrM400 < 1 dans le registre 11
					li 10, 0
					sltu 12, 10, 2 # met la valeur de !yrM100 > 0 dans le registre 12
					li 10, 1
					sltu 13, 1, 10 # met la valeur de !yrM4 < 1 dans le registre 13
					and 12, 12, 13 # met la valeur de !yrM100 > 0 && !yrM4 = 0 dans le registre 12
					or 11, 11, 12  # met la valeur de !yrM400 = 0 || (!yrM100 > 0 && !yrM4 = 0) dans le registre 11
					li 10, 0
					bne 11, 10, 1
						li 9, 5550 # valeur décimale de 0111010110101 avec le bit de poids faible à gauche
				# end
			# end
		# end
	# end
# end

# Retour au début du programme juste après l'initialisation des registres

j 10