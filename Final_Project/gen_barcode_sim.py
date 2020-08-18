import random
"""
Generate tb modelsim commands for barcode39.
"""

def get_modelsim_commands(char, code39_mapping):
	out_str = f"wait for 200ns;\nbarcode_in <= '1';\n"
	out_str += f"-- START {char}\n"
	char_code_bits = list("{0:{fill}12b}".format(code39_mapping[char],fill='0'))
	for bit in char_code_bits:
		out_str += f"wait for 200ns;\nbarcode_in <= '{bit}';\n"
	out_str += f"-- END {char}\n"
	return out_str

code39_mapping = {
	'ones' : 0xFFF,
	'*' : 0x692,
	'0' : 0x592,
	'1' : 0x2D4,
	'2' : 0x4D4,
	'3' : 0x26A,
	'4' : 0x594,
	'5' : 0x2CA,
	'6' : 0x4CA,
	'7' : 0x5A4,
	'8' : 0x2D2,
	'9' : 0x4D2
}

with open('barcode_sim.txt','w') as fp:
	fp.write(get_modelsim_commands('ones', code39_mapping))
	fp.write(get_modelsim_commands('*', code39_mapping))
	for i in range(8):
		rand_digit = str(random.randrange(10))
		fp.write(get_modelsim_commands(rand_digit, code39_mapping))
	fp.write(get_modelsim_commands('*', code39_mapping))
	fp.write(get_modelsim_commands('ones', code39_mapping))