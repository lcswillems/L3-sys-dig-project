import subprocess
import re
import time
import datetime
import tkinter as tk
import sys
import os

sync = len(sys.argv) > 1 and sys.argv[1] == "-s"

proc = subprocess.Popen([
	'./simulator.byte',
		'micro/main.net',
		'-rom', 'clock/clock-without-mod.byte',
		'-ram', 'clock/clock-init.byte'
	], stdout=subprocess.PIPE)
regs = [0]*16

def leapyr(n):
    if n % 400 == 0:
        return True
    if n % 100 == 0:
        return False
    if n % 4 == 0:
        return True
    else:
        return False

def bitstring_of_int(nb):
	s = ""

	for i in range(32):
		s += str(nb//(2**i) % 2)

	return s

def ram_of_time():
	t = datetime.datetime.now()

	year = t.year
	month = t.month
	day = t.day
	hour = t.hour
	minute = t.minute
	second = t.second

	# year = 2017
	# month = 4
	# day = 30
	# hour = 23
	# minute = 59
	# second = 59

	file = open("clock/clock-init.byte", "w")
	file.write(''.join(map(bitstring_of_int, [
		year, year % 4, year % 100, year % 400, month, day, hour, minute, second, 5550 if leapyr(year) else 5546
	])))
	file.close()

ram_of_time()

s = datetime.datetime.now().second

while True:
	t = datetime.datetime.now().second

	if not(sync) or t != s:
		s = t

		reg_id = -1
		while reg_id != 15 or regs[reg_id] == 0:
			line = ''
			while line == '':
				line = proc.stdout.readline()

			line = line.decode('utf-8').rstrip()
			res = re.compile("r([0-9]+) : ([0-1]+)").findall(line)
			if len(res) > 0:
				reg_id = int(res[0][0])
				reg_sval = res[0][1]
				reg_ival = 0
				for i in range(len(reg_sval)):
					reg_ival *= 2
					reg_ival += (1 if int(reg_sval[i]) == 1 else 0)
				regs[reg_id] = reg_ival
			else:
				reg_id = -1

		os.system('clear')
		print("%02d : %02d : %02d   %02d / %02d / %04d" % (regs[6], regs[7], regs[8], regs[5], regs[4], regs[0]))