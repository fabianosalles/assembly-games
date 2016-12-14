EXE = fttt.exe
DIR = D:\Documentos\Repositorios\asm-ttt\


fasm:
	fasm fttt.asm ./bin/$(EXE)
	
run:
	
#	dosbox "$(DIR)\$(EXE)" -noautoexec 
	dosbox -noautoexec -c "mount c $(DIR)" -c "c:" -c "cd bin" -c "$(EXE)"