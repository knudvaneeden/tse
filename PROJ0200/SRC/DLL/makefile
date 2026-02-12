.silent:

## debug/retail -----------------------------------------------------------

DEBUG=0

!if "$(r)" == "1"
BUILD=RETAIL
!endif

!if "$(BUILD)"==""
!message Defaulting BUILD to DEBUG
BUILD=DEBUG
!endif

OUT=release
!if "$(BUILD)"!="RETAIL"
DEBUG=1
OUT=debug
!endif



## project ----------------------------------------------------------------

PROJECT=ProjDLL


OBJS=\
!if $(DEBUG)
	$(OUT)\dbg.obj \
!endif
	$(OUT)\projdll.obj \
	$(OUT)\flatfile.obj \
	$(OUT)\tags.obj \
	$(OUT)\bscutil.obj \
	$(OUT)\std.obj \
	$(OUT)\arrays.obj \


RCFILES=


RES=


LIBS=\
!if $(DEBUG)
	advapi32.lib \
!endif
	user32.lib \
	msbsc60.lib \



## tools ------------------------------------------------------------------

CFLAGS=-nologo -W3 -GD -GF -LD -Zi -Fd"$(OUT)\msvc.pdb" -D "WIN32" -D "_WINDOWS" -c
RCFLAGS=/r /l 0x409
LINKFLAGS=/DLL /nologo /base:"0x6e000000" /machine:I386 /subsystem:windows /out:"$(OUT)\$(PROJECT).dll" /pdb:"$(OUT)\$(PROJECT).pdb"
TFLAGS=--excmd=p

!if $(DEBUG)
CFLAGS=-Od $(CFLAGS) -GR -D "DEBUG" -D "_DEBUG"
RCFLAGS=$(RCFLAGS) /dDEBUG
LINKFLAGS=/DEBUG $(LINKFLAGS) /incremental:yes
!else
CFLAGS=-O1 $(CFLAGS) -D "NDEBUG"
RCFLAGS=$(RCFLAGS) /dRELEASE
#LINKFLAGS=/RELEASE $(LINKFLAGS) /incremental:no
LINKFLAGS=/DEBUG $(LINKFLAGS) /incremental:no
!endif


SC=sc32
CL=cl $(CFLAGS)
RC=rc $(RCFLAGS)
LINK=link $(LINKFLAGS)
TAGS=ctags $(TFLAGS)

MKDEP=mkdep
RM=-rm



## rules ------------------------------------------------------------------

{}.cpp{$(OUT)}.obj:
	echo --- Compiling $(*B).cpp
	$(CL) /c $< /Fo$(OUT)\$(*B).obj

.si.mac:
	echo --- SAL Compiling $(*F)
	$(SC) $(*F)


all: $(OUT)\deps $(OUT) $(OUT)\$(PROJECT).dll tags

mac: proj.mac pjfile.mac


$(OUT):
	mkdir $(OUT)


!if "$(RES)" != ""
$(RES): $(RCFILES)
	echo --- RC File
	$(RC) /fo $(RES) $(RCFILES)
!endif


$(OUT)\$(PROJECT).dll: $(OBJS) $(RES)
	echo --- Building $(PROJECT).dll
	$(LINK) $(OBJS) $(RES) $(LIBS)



## special rules ----------------------------------------------------------

$(OUT)\deps:	$(OUT)
	echo --- Updating dependencies
	$(MKDEP) -n -p $(OUT)\ -s .obj *.c *.cpp > $(OUT)\deps

tags:
	echo --- Tags
	$(TAGS) *.cpp *.h

depend:
	echo --- Updating dependencies
	$(MKDEP) -n -p $(OUT)\ -s .obj *.c *.cpp > $(OUT)\deps

clean:
	$(RM) tags $(OUT)\*.*



## automatic rules from dependencies --------------------------------------

!if exists( $(OUT)\deps )
!include $(OUT)\deps
!endif


