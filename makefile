#change this vartiable to your current "project path"
DIR = ${CURDIR}/bin
EXE_TTT = ttt.exe
EXE_PONG = pong.com

bin:
	mkdir -p bin

ttt: bin
	fasm ttt.asm ./bin/$(EXE_TTT)	
	
pong: bin
	fasm pong.asm ./bin/$(EXE_PONG)

#run dosbox and set current dir to bin
run: bin
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin"
	
run-ttt: ttt
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE_TTT)"
	
run-pong: pong
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE_PONG)"	
