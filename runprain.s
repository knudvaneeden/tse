FORWARD INTEGER PROC FNProgramRunBrowserInternetUrlArtificialIntelligenceB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunBrowserInternetUrlArtificialIntelligenceB() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: program: run: browser: internet: url: artificial: intelligence <description></description> <version control></version control> <version>1.0.0.0.12</version> <version control></version control> (filenamemacro=runprain.s) [<Program>] [<Research>] [kn, ri, sa, 14-12-2024 21:13:47]
INTEGER PROC FNProgramRunBrowserInternetUrlArtificialIntelligenceB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunBrowserInternetUrlArtificialIntelligenceB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramRunBrowserInternetUrlArtificialIntelligenceB )
 // e.g. HELPDEF HELPDEFFNProgramRunBrowserInternetUrlArtificialIntelligenceB
 // e.g.  title = "FNProgramRunBrowserInternetUrlArtificialIntelligenceB() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 // Use case: Explore artificial intelligence (=AI) web sites from within your The Semware Editor Professional (=TSE)
 //
 // Note: this was a very good example of using Carlo Hogeveen's 'bulkfind.s'
 //       TSE macro to extract all the URLs from my knowledge bases.
 //       I did put the left column in a file.
 //       and extracted the part of the other file with all the URLs into another file.
 //       Then did run bulkfind.s which extracted the URLs
 //       Then did some (regular expression) search and replace to edit further.
 //
 STRING s1[255] = ""
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 //
 GotoBufferId( bufferI )
 //
 AddLine( "aistudio                        https://aistudio.google.com" )
 AddLine( "anything.world                  https://anything.world" )
 AddLine( "bing                            https://bing.com" )
 AddLine( "chatglm                         https://en.chatglm.cn" )
 AddLine( "chatgpt                         http://chat.openai.com" )
 AddLine( "chatgptcodeinterpreter          https://chat.openai.com/?model=gpt-4-code-interpreter" )
 AddLine( "chatpdf                         https://www.chatpdf.com" )
 AddLine( "claude                          https://claude.ai/chats" )
 AddLine( "codewhisperer                   https://aws.amazon.com/codewhisperer/" )
 AddLine( "cohere                          https://huggingface.co/chat/models/CohereForAI/c4ai-command-r-plus-08-2024" )
 AddLine( "copilotgithub                   https://github.com/features/copilot" )
 AddLine( "copilotmicrosoft                https://copilot.microsoft.com" )
 AddLine( "deepseek                        https://chat.deepseek.com" )
 AddLine( "devinai                         https://console.devinai.com" )
 AddLine( "elicit                          https://elicit.com" )
 AddLine( "gemini                          https://gemini.google.com" )
 AddLine( "genesis                         https://genesis-embodied-ai.github.io" )
 AddLine( "glm                             https://chat.z.ai" )
 AddLine( "googlelearning                  https://learning.google.com/experiments/learn-about/signup" )
 AddLine( "granite                         https://www.ibm.com/granite/playground/" )
 AddLine( "grok                            https://x.ai" )
 AddLine( "humata                          https://www.humata.ai" )
 AddLine( "inflectionpi                    https://heypi.com/talk?utm_source=inflection.ai" )
 AddLine( "julius                          https://julius.ai" )
 AddLine( "kimi                            https://kimi.ai" )
 AddLine( "kling                           https://kling.kuaishou.com" )
 AddLine( "llama                           https://huggingface.co/chat/models/meta-llama/Llama-3.3-70B-Instruct" )
 AddLine( "meta                            https://meta.ai" )
 AddLine( "minimax                         https://www.minimax.io" )
 AddLine( "mistral                         https://chat.mistral.ai/chat" )
 AddLine( "mixtral                         https://mixtral.replicate.dev/" )
 AddLine( "napkin                          https://napkin.ai" )
 AddLine( "notebookgoogle                  https://notebooklm.google.com" )
 AddLine( "operabrowserai                  https://www.opera.com/features/browser-ai" )
 AddLine( "pdfgpt                          https://pdfgpt.io" )
 AddLine( "perplexity                      https://www.perplexity.ai" )
 AddLine( "poe                             https://poe.com" )
 AddLine( "popai                           https://popai.pro" )
 AddLine( "qwen                            https://huggingface.co/chat/models/Qwen/Qwen2.5-72B-Instruct" )
 AddLine( "reka                            https://chat.reka.ai/chat/" )
 AddLine( "replit                          https://replit.com" )
 AddLine( "sizzle                          https://www.szl.ai" )
 AddLine( "tabnine                         https://www.tabnine.com" )
 AddLine( "tutorlily                       https://tutorlily.com/?lang=en" )
 AddLine( "type                            https://type.ai" )
 AddLine( "upend                           https://upend.ai" )
 AddLine( "you.com                         https://you.com/search" )
 AddLine( "------------------------------------------------------" )
 AddLine( "backflip                        https://www.backflip.ai" )
 AddLine( "cat-4d                          https://cat-4d.github.io" )
 AddLine( "dall-e                          https://openai.com/index/dall-e-3/" )
 AddLine( "diffus                          https://www.diffus.me" )
 AddLine( "fluxpro                         https://www.fluxpro.ai" )
 AddLine( "genie                           https://deepmind.google/discover/blog/genie-2-a-large-scale-foundation-world-model/" )
 AddLine( "imagen                          https://deepmind.google/technologies/imagen-3/" )
 AddLine( "midjourney                      https://midjourney.com/home/" )
 AddLine( "odessey                         https://odyssey.systems" )
 AddLine( "omagic                          https://omagic.ai" )
 AddLine( "sora                            https://openai.com/index/sora/" )
 AddLine( "veo                             https://deepmind.google/technologies/veo/veo-2/" )
 AddLine( "worldlabs                       https://www.worldlabs.ai" )
 //
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  s1 = Trim( GetText( 1, MAXSTRINGLEN ) )
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  B = FALSE
  RETURN( B )
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 s1 = GetToken( s1, " ", 2 )
 //
 B = StartPgm( s1 )
 //
 RETURN( B )
 //
END
