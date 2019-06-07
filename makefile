#change this vartiable to your current "project path"
DIR = ./bin

DEBUG_PATH= /media/fabiano/Dados/Software/DOS/Dosbox/d/
EXE_TTT = ttt.exe
EXE_PONG = pong.com

#change this to enable or disble autexec.bat in dosbox startup
NOAUTOEXEC = -noautoexec

DBGAUTOEXEC = -noautoexec \
	-c "mount d $(DEBUG_PATH)" \
	-c "set path=%path%;d:\bp\bin" 
  
	   
MOUNT = -c "mount r $(DIR)" -c "r:" 
 
bin:
	mkdir -p bin

ttt: bin
	fasm ttt.asm ./bin/$(EXE_TTT)	
	
pong: bin
	fasm pong.asm ./bin/$(EXE_PONG)

#run dosbox and set current dir to bin
run: bin
	dosbox $(MOUNT) $(NOAUTOEXEC)
	
run-ttt: ttt
	dosbox $(MOUNT) $(NOAUTOEXEC) -c $(EXE_TTT)
	
run-pong: pong
	dosbox $(MOUNT) $(NOAUTOEXEC) -c $(EXE_PONG)


###############################################################
# Debug commands
# This uses turbo debugger and it is expetcted that in $(DEBUG_PATH)\db\bin exits
# an valid Tubro pascal with a TD installation 
###############################################################
debug-pong:
	dosbox $(MOUNT) $(DBGAUTOEXEC) -c "cd r:" -c "td $(EXE_PONG)"
	
