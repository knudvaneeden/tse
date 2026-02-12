/*********************************************************************
 I spotted the following tip from Semware BBS file TSE_TIP4
               > Date: 09-28-94  From: GEORGE DE BRUIN  <
               >       Subj: Up() & Down() Alarm        <
 Sounded great and I promptly added it to my UI file and 'burned it in'.
 But I quickly found I couldn't stand the incessant beeping every time
 I hit the Top or Bottom (or Left Margin which I also added), ESPECIALLY
 SINCE I COULD NOT DISABLE IT NOW I HAD BURNED IT INTO MY EDITOR!!!!
 So I propose the following:  Compile this source file as an external
 macro and load it whenever you want to be 'Alarming' !!  You can even
 insert it in your 'Potpourri' if you like.
 Now whenever you tire of your new 'Alarming' capabilities, you can
 simply Purge the macro.  (Simple)

Author:  ROB HOWSE,  SASKATOON, SASK (CANADA)  DEC 94
Apologies & Credits: to GEORGE DE BRUIN, of course!

NOTE:  For a related macro of (mine?) which allows keyboard macros to
       'break out' if they encounter the same kinds of situations,
       see my BREAK.S .  (Again with apologies to someone at SemWare
       but I've forgotten who! <sheepish>
 *********************************************************************/
//Sound alarm if we can't successfully complete any of the following
//conditions. (Such as 'banging'up against the top of the file)
proc mUp()       if NOT Up()       Alarm()  endif  end
proc mDown()     if NOT Down()     Alarm()  endif  end
proc mLeft()     if NOT Left()     Alarm()  endif  end
proc mRollUp()   if NOT RollUp()   Alarm()  endif  end
proc mRollDown() if NOT RollDown() Alarm()  endif  end

<CursorUp>              mUp()
<CursorDown>            mDown()
<CursorLeft>            mLeft()
<Ctrl CursorUp>         mRollUp()
<Ctrl CursorDown>       mRollDown()
