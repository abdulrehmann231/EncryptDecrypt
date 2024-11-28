# to run this app first you need to download irvine library and visual studio 2019

1) Download zip file of this repo
2) Extract the folder
3) open .sln file using visual studio 2019
4) then setup irvine path
5) right click on project, select build customization and tick masm
6) click ok
7) right click the project, select properties
8) go to general tab inside linker tab and add the path of irvine folder inside additional directories.
9) go to input tab inside linker tab and write "irvine32.lib;" at start of additional dependecies
10) go to microsoft micro assembler tab , and add path to your irvine folder in include paths
11) click apply. click ok.
12) If you cant find microsoft micro assemebler tab then right click your .asm file and select properties, go to general tab and select microsoft assembler as file type and click ok.


