

#change this vartiable to your current "project path"
DIR = D:\Documentos\Repositorios\asm-games-8086
EXE_TTT = ttt.exe
EXE_PONG = pong.com

ttt:
	fasm ttt.asm ./bin/$(EXE_TTT)	
	
pong:
	fasm pong.asm ./bin/$(EXE_PONG)

#run dosbox and set current dir to bin
run:
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c 
	
run_ttt:
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE_TTT)"
	
run_pong:
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE_PONG)"	