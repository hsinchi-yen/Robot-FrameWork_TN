#!/bin/bash -x
#sudo cp *.sh /media/lance/root/home/root/

cp_files=$(ls -1 *.sh | grep -v "cfgpatch")

for file in ${cp_files}
do 
	sudo cp ${file} /media/lance/root/home/root/
done

sudo cp imx8mp-edm-g-wb.dtb /media/lance/boot/
sync

