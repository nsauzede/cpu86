f=open("blk_orig.mif")
n=16383
for d in f.readlines():
	print("%d : %s;" % (n, d.replace("\n","")))
	n -= 1
while n >= 0:
	print("%d : 00000000;" % n)
	n -= 1
