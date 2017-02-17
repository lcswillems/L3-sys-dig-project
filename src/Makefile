all: assembly simulator micro

minijazz:
	cd minijazz/src && ocamlbuild mjc.byte && mv mjc.byte ../mjc.byte

assembly:
	cd assembly && ocamlbuild main.byte && mv main.byte ../assembly.byte

simulator:
	cd simulator && ocamlbuild main.byte && mv main.byte ../simulator.byte

micro:
	cd micro && cpp -P main.mmj > main.mj && ../minijazz/mjc.byte main.mj && ../simulator.byte main.net -print

clean:
	rm -f -R assembly/_build
	rm -f -R simulator/_build
	rm -f micro/main_sch.net
	rm -f assembly.byte
	rm -f simulator.byte

clock:
	./assembly.byte clock/clock-without-mod.s
	./simulator.byte micro/main.net -rom clock/clock-without-mod.byte -ram clock/clock-init.byte

.PHONY: minijazz assembly simulator micro all test clock