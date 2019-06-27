targetdir =bin
includedir = inc
libdir = lib
compile = tcc -ml -n$(targetdir) -O -G -I$(includedir) -L$(libdir)
complib = tcc -ml -n$(libdir) -O -G -I$(includedir) -L$(libdir) -c

clean:
	del bin\*.exe -y
	del bin\*.obj -y
	del bin\*.map -y

lib:
	$(complib) src\vga.c

lines:
	$(compile) lines.c

pallete: 
	$(compile) pallete.c		

pixels:
	$(compile) pixels.c

polygon:
	$(compile) polygon.c	

pong:
	$(compile) pong.c	

detect:
	$(compile) detect.c	