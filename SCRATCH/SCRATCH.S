/*************************************************************************
 Scratch      Scratch buffer package

 Author:      Bill Stewart (bstewart@iname.com)

 Overview:

 This macro gives you quick access to 26 scratch buffers A-Z.

 Keys:        <Ctrl S>  SelectScratchBuffer()

 This macro was inspired by vi's notion of text registers. It works by
 changing the clipboard buffer.

 It's also compatible with the Named Clipboards feature in TSE Pro (e.g.
 the "A" scratch buffer is the same as Named Clipboard "A").

 I find this macro more convenient than the Named Clipboards feature
 because you don't have to go through the Named Clipboards menu to copy to
 different buffers; just switch to the desired buffer and use it with the
 normal clipboard commands.

 On initialization, the system clipboard ID is saved, and scratch buffer A
 becomes the default. To switch buffers, press <Ctrl S>.

 To empty all scratch buffers and reset the current scratch buffer to A,
 execute the public EmptyScratchBuffers macro.

 *************************************************************************/

string scratch_buffer[1] = ""       // holds the scratch buffer name
integer system_clipboardid          // holds the system clipboard buffer ID

// sets the changes the clipboard to the specified buffer name
// returns the ID of the new clipboard buffer if successful, 0 if not
integer proc SetScratchBuffer(string buffer)
  integer id, cid

  id = getbufferid("+++" + buffer)
  if not id
    cid = getbufferid()
    id = createbuffer("+++" + buffer, _SYSTEM_)
    if id
      gotobufferid(cid)
    endif
  endif
  if id
    set(clipboardid, id)
  endif
  return(id)
end

// lets you interactively select the desired scratch buffer (A-Z)
proc SelectScratchBuffer()
  integer ok
  string buffer[1] = scratch_buffer

  // causes problems with other macros...use ask() instead of getkey()
  //repeat
  //  message("Scratch buffer (A-Z) [" + scratch_buffer + "]: ")
  //  vgotoxy(wherex(), wherey())
  //  k = getkey() & 0xFF
  //  if k in 97..122
  //    k = k - 32
  //  endif
  //  ok = k in 13, 27, 32, 65..90
  //until ok
  //updatedisplay()
  //if k in 65..90
  //  if not SetScratchBuffer(chr(k))
  //    warn("Could not create buffer")
  //  else
  //    scratch_buffer = chr(k)
  //  endif
  //endif

  // use this block of code instead
  repeat
    ok = ask("Scratch buffer (A-Z):", buffer) and length(buffer)
    if ok
      buffer = upper(buffer)
      ok = buffer in "A".."Z"
      if ok
        ok = SetScratchBuffer(buffer)
        if not ok
          warn("Could not create buffer")
          break
        else
          scratch_buffer = buffer
        endif
      endif
    else
      break
    endif
  until ok
end

proc WhenLoaded()
  system_clipboardid = query(clipboardid)
  scratch_buffer = "A"
  if not SetScratchBuffer(scratch_buffer)
    warn("Could not create buffer")
  endif
end

// empty all buffers from A to Z and reset A as the default
public proc EmptyScratchBuffers()
  integer i, id

  if yesno("Empty scratch buffers?") == 1
    set(clipboardid, system_clipboardid)
    for i = 65 to 90
      id = getbufferid("+++" + chr(i))
      if id
        abandonfile(id)
      endif
    endfor
    WhenLoaded()
  endif
end

proc WhenPurged()
  // restore system clipboard
  set(clipboardid, system_clipboardid)
  // EmptyScratchBuffers()  // can do this if desired
end

<ctrl s>    SelectScratchBuffer()
