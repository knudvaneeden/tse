/****************************************************************************\

  TseSHilf.S

  Deutsche Hilfe fr TseShell.

  Version         0.99/15.04.96

  Copyright       (c) 1995 by DiK
                  (c) 1996 rewrite 0.99 Dr. S. Schicktanz

\****************************************************************************/

/****************************************************************************\
    help screen
\****************************************************************************/

helpdef ShellHelp
    title = "Hilfe zu TseShell"
    x = 6
    y = 3
    width = 68
    height = 19

    ""
    " Alllgemeine Anmerkungen"
    " -----------------------"
    ""
    " Jede beliebige Zeile in diesem Puffer kann als Dos-Befehl aus-"
    " gefhrt werden. Die Befehle werden zus„tzlich in der Liste"
    " der frheren Befehle gespeichert."
    ""
    " Mit einer speziellen Befehlstaste ist es sogar m”glich, ein"
    " einzelnes oder mehrere Befehle ('Stapel') aus einem normalen"
    " Editierpuffer heraus auszufhren."
    ""
    " Die Programmausgaben (soweit sie nicht direktin den Bildschirm-"
    " speicher geschrieben werden) werden in diesen Puffer umgeleitet,"
    " so daá sie editiert, modifiziert oder an eine andere Stelle"
    " kopiert werden k”nnen."
    ""
    " Obwohl es m”glich ist, Dos-Stapeldateien auszufhren, erm”glicht"
    " eine interne 'Stapelfunktion' das einfache Abarbeiten von"
    " mehreren Dps-Befehlen. Sie wird benutzt, wenn im aktuellen Puffer"
    " (normalerweise der TseShell-Puffer) ein markierter Block vorliegt"
    " und die 'Ausfhren'-Taste bet„tigt wird."
    " Alle Zeilen des Blocks werden dann nacheinander als Dos-Befehle"
    " ausgefhrt."
    ""
    " Weiter M”glichkeiten"
    " --------------------"
    ""
    " Alle Dos-Befehle werden in der Liste frherer Befehle abgelegt,"
    " von der aus sie im TseShell-Puffer (und natrlich im Dos-"
    " Befehls-Dialog) jederzeit zurckgeholt werden k”nnen."
    " Die Rckhol-Methode ist mit einer Einstellfunktion w„hlbar."
    " Das 'schwebende Auswahlfenster' kann auáerdem auch mit einem"
    " speziellen Tastenbefehl aufgerufen werden."
    " Weiterhin can die Liste frher editierter Dateien aufgerufen"
    " werden, um einen Dateinamen an beliebiger Stelle einzufgen."
    " Dateinamen k”nnen auch aus einer Auswahlliste entnommen werden."
    ""
    " Interne Befehle"
    " ---------------"
    ""
    " Einige Befehle sind als interne Makrofunktionen erstellt, um"
    " die Bearbeitung zu beschleunigen."
    ""
    " cls           Bildschirm und Pufferinhalt l”schen"
    " cd            Verzeichnis wechseln"
    " cdd           Verzeichnis und Laufwerk wechseln"
    " cde           Verzeichnis auf Editorverzeichnis setzen"
    " [a-z]:        Schneller Laufwerkswechsel"
    " path\         Schneller Verzeichnis- und Laufwerkswechsel"
    "               (abschlieáender '\' notwendig!)"
    " ..{.}         Im Verzeichnisbaum aufw„rtsgehen -"
    "               benutzt die 4DOS-Mehrfachpunkt-Nomenklatur,"
    "               wobei fr jeden zus„tzlichen Punkt eine"
    "               Stufe h”her gegangen wird."
    "               (Mit schnellem Verzeichniswechsel kombinierbar)"
    ""
    " Tastenzuordnungen"
    " -----------------"
    ""
    " Zur Cursor-Bewegung stehen die normalen Cursor-Tasten zur"
    " Verfgung. Alle Editierfunktionen sind verfgbar."
    ""
    " Ausfhrungsbefehle"
    "   Enter               Befehl oder Inhalt des markierten"
    "                       Blocks ausfhren."
    "   Alt Enter           desgleichen, im Editier-Puffer"
    ""
    " Befehlszeile editieren"
    "   Ctrl Enter          Neuzuordnung des Enter-Taste"
    "                       ohne Ausfhrungsfunktion"
    "                       (z.B. zum Teilen der Zeile)"
    "   Escape              Befehlszeile l”schen"
    "   Alt Del             Bildschirm und Puffer l”schen"
    ""
    " Auswahlen / Frhere Eingaben"
    "   Ctrl CursorUp,"
    "   Ctrl CursorDown     letzten/n„chsten Eintrag der Liste"
    "                       frherer Eingaben anzeigen"
    "   Ctrl Shift-Up,"
    "   Ctrl Shift-Down     Auswahlfenster frherer Eingaben"
    "   F2                  Dateiname aus frheren Eingaben"
    "                       ausw„hlen"
    "   Ctrl F2             Dateiname aus Auswahlliste w„hlen"
    ""
    " Verschiedenes"
    "   F1                  Diesen Hilfetext anzeigen"
    "   Ctrl F7             zum Editorverzeichnis und -Laufwerk"
    "                       wechseln"
    "   Alt F7              Editorverzeichnis auf aktuelles setzen"
    "   F9                  Einstellungsmen"
    "   F11                 zum vorherigen Puffer zurckschalten"
    "                       (durch jeden Umschaltbefehl ausgel”st)"
    "   Alt X               TseShell entladen (mach Puffer editierbar)"
    ""
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main ()
    QuickHelp (ShellHelp)
    PurgeMacro (CurrMacroFilename ())
end