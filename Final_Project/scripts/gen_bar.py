import random

def create_barcode(code39_mapping):
    barcode = ""
    barcode_txt = ""
    for i in range(random.randint(10, 20)):
        barcode += '1'
    barcode += str(bin(0x692))[2:].zfill(12) + '1'
    barcode_txt += '*'
    for i in range(9):
        curr_char = random.choice(list(code39_mapping.keys()))
        barcode += bin(int(code39_mapping[curr_char],16))[2:].zfill(12) + '1'
        barcode_txt += curr_char
    barcode += str(bin(0x692))[2:].zfill(12) + '1'
    barcode_txt += '*'
    for i in range(random.randint(10, 20)):
        barcode += '1'
    return barcode, barcode_txt

def gen_mapping():
    d = {}
    with open('mapping.csv','r') as fp:
        lines = fp.readlines()
        for line in lines:
            char, mapping = line.split(',')
            d[char] = hex(int(nw2digits(mapping.strip('\n')),2))
    return d

def nw2digits(nw):
    barcode = ""
    for i, e in enumerate(nw):
        if not(i % 2):
            if e == 'n':
                barcode += '0'
            else:
                barcode += '00'
        else:
            if e == 'n':
                barcode += '1'
            else:
                barcode += '11'
    return barcode

barcode, barcode_txt = create_barcode(gen_mapping())
print(barcode)
with open("../Scanner.txt","w") as fp:
	fp.write(barcode)
print(barcode_txt)

print(gen_mapping())