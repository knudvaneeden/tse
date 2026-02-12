//  Nov 11, 1994 (Ton Teuns)
//
//  TS: Timed saving of file being edited; macro checks when keyboard is
//      idle; if the file has changed and 5 minutes have gone by the file
//      is saved in the current directory as filename.B$$
//      So if you answer 'No' to 'Save changes?' and then start yelling
//      !!!@#$()*@?!!! or other fourletter words at least you have a copy
//      of your work minus the changes you made in the last five minutes
//
//      By the way, does anyone know a way to tell that a file really has
//      changed since the last check? Of course I don't want to use
//      FileChanged( FALSE ) in mTimedSave() !!
//


integer bhour, bmin, bsec, bhun             // begin values
string  filename[80]
integer counter = 0

proc mDelTmp()
     string command[80]
     filename = SplitPath( CurrFileName(), _NAME_ ) + ".b$$"

     if Length( filename )  > 0 and FileExists( filename )
         command = "del " + filename
         dos( command, _DONT_CLEAR_ )
     endif
end

proc mTimedSave()
    integer ehour, emin, esec, ehun

    GetTime( ehour, emin, esec, ehun )
    counter = counter + 1

    if emin < bmin
        emin = 60 + emin
    endif
    if FileChanged()
        if ( emin - bmin > 5 )
             filename = SplitPath( CurrFileName(), _NAME_ ) + ".b$$"
             SaveAs( filename, _OVERWRITE_ )
             UpdateDisplay( _STATUSLINE_REFRESH_ )
             gettime( bhour, bmin, bsec, bhun )
        endif
    endif
end mTimedSave

proc mCancelSave()
    Unhook( mTimedSave )
    Warn( "Automatic saving disabled: " + Str(counter) + " visits" )
end  mCancelSave

proc WhenLoaded()
    GetTime( bhour, bmin, bsec, bhun )
    Hook( _IDLE_, mTimedSave )
    Hook( _ON_FILE_SAVE_, mDelTmp )
end WhenLoaded

<Ctrl F><S> mCancelSave()
