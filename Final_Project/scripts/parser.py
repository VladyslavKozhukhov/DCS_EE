filepath = "../Barcode.txt"
Dict = {844448448: 'A', 448448448: 'B', 848448444: 'C', 444488448: 'D', 844488444: 'E', 448488444: 'F', 444448848: 'G',
        844448844: 'H', 448448844: 'I', 444488844: 'J', 844444488: 'K', 448444488: 'L', 848444484: 'M', 444484488: 'N', 844484484: 'O',
        448484484: 'P', 444444888: 'Q', 844444884: 'R', 448444884: 'S', 444484884: 'T', 884444448: 'U', 488444448: 'V',
        888444444: 'W', 484484448: 'X', 884484444: 'Y', 488484444: 'Z', 444884844: '0', 844844448: '1', 448844448: '2',
        848844444: '3', 444884448: '4', 844884444: '5', 448884444: '6', 444844848: '7', 844844844: '8', 448844844: '9',
        484484844: '*', 484444848: '-', 484848444: '$', 488444844: ' ', 444848484: '%', 884444844: '.', 484844484: '/', 484448484: '+'}
num = 0
count = True
fullTxt = ""
with open(filepath) as fp:
    line = fp.readline()
    cnt = 0
    cnt_parser = 0
    while line:
        print("Line {}: {}".format(cnt, line.strip()))

        cnt += 1
        if (count):
            cnt_parser += 1
            num = num * 10 + int(line)

            if (cnt_parser == 9):
                cnt_parser = 0
                count =False;
                print(num)
                print("parser value is " + Dict[num])
                fullTxt = fullTxt + str(Dict[num])
                num = 0
        else:
            count = True;
        line = fp.readline()
print("FULL TEXT: "+ fullTxt)