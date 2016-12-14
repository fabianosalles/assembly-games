

#change this vartiable to your current "project path"
DIR = D:\Documentos\Repositorios\asm-games-8086
EXE = fttt.exe


fasm:
	fasm fttt.asm ./bin/$(EXE)
	
run:
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE)"