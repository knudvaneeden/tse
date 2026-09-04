/*
   File       : clipstack_demo.s
   Purpose    : Minimal test for clipstack.inc.
   Version    : 1.0.0.0.7
   Date       : 2026-09-02
   LLM        : OpenAI Codex
*/

#include ["clipstack.inc"]

proc Main()
   if (clipStackTopI > 0)
      if PROCPopClipboard()
         Warn("Clipboard popped and restored.")
      endif
   else
      if PROCPushClipboard()
         Warn("Clipboard pushed. Change it, then run this macro again to pop it.")
      endif
   endif
end

<CtrlAlt O> PROCPushClipboard()
<CtrlAlt P> PROCPopClipboard()
<CtrlAlt Q> PROCPushClipboardWin()
<CtrlAlt R> PROCPopClipboardWin()
