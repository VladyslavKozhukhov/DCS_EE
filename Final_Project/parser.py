filepath = "C:/Users/VladKo/Documents/MSc/BGU/Barcode.txt"
Dict = {484484844: '*', 444884448: '4'} 
num = 0
count = True
with open(filepath) as fp:
	line = fp.readline()
	cnt = 0
	cnt_parser=0
	while line:
		print("Line {}: {}".format(cnt, line.strip()))
		line = fp.readline()
		cnt += 1
		if(cnt >= 2 and count):
			cnt_parser+=1
			num=num*10+int(line)
			if(cnt_parser == 9):
				count = False
				cnt_parser = 0
				print(num)
				print("parser value is "+Dict[num])
				num =0
		elif count ==False:
			count = True