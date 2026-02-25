FORWARD PROC Main()
FORWARD STRING PROC FNProgramRunBrowserInternetUrlArtificialIntelligenceS()
FORWARD STRING PROC FNStringGetErrorS()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunBrowserInternetUrlArtificialIntelligenceS() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: program: run: browser: internet: url: artificial: intelligence <description></description> <version control></version control> <version>1.0.0.0.23</version> <version control></version control> (filenamemacro=runprain.s) [<Program>] [<Research>] [kn, ri, sa, 14-12-2024 21:13:47]
STRING PROC FNProgramRunBrowserInternetUrlArtificialIntelligenceS()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunBrowserInternetUrlArtificialIntelligenceS() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case = Run a Artificial Intelligence (=AI) program from a list
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
 // e.g. // QuickHelp( HELPDEFFNProgramRunBrowserInternetUrlArtificialIntelligenceS )
 // e.g. HELPDEF HELPDEFFNProgramRunBrowserInternetUrlArtificialIntelligenceS
 // e.g.  title = "FNProgramRunBrowserInternetUrlArtificialIntelligenceS() help" // The help's caption
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
 // Use case: Explore artificial intelligence (=AI) web sites from within your The Semware Editor Professional (=TSE)
 //
 // Note: this was a very good example of using Carlo Hogeveen's 'bulkfind.s'
 //       TSE macro to extract all the URLs from my knowledge bases.
 //       I did put the left column in a file.
 //       and extracted the part of the other file with all the URLs into another file.
 //       Then did run bulkfind.s which extracted the URLs
 //       Then did some (regular expression) search and replace to edit further.
 //
 STRING s[255] = ""
 STRING s1[255] = ""
 STRING s2[255] = ""
 INTEGER B = FALSE
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
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: MOST: FREQUENTLY: USED" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "chatgpt                           http://chat.openai.com" )
 AddLine( "claude                            https://claude.ai/chats" )
 AddLine( "copilotgithub                     https://github.com/copilot/" )
 AddLine( "copilotmicrosoft                  https://copilot.microsoft.com" )
 AddLine( "deepseek                          https://chat.deepseek.com" )
 AddLine( "gemini                            https://gemini.google.com" )
 AddLine( "glm                               https://chat.z.ai" )
 AddLine( "grok                              https://grok.com/chat" )
 AddLine( "kimi                              https://kimi.ai" )
 AddLine( "minimax                           https://chat.minimax.io" )
 AddLine( "mistral                           https://chat.mistral.ai/chat" )
 AddLine( "notebooklm                        https://notebooklm.google.com" )
 AddLine( "perplexity                        https://www.perplexity.ai" )
 AddLine( "qwen                              https://chat.qwenlm.ai" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: GENERAL" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "aistudio                          https://aistudio.google.com" )
 AddLine( "aistudiochat                      https://aistudio.google.com/prompts/new_chat/" )
 AddLine( "andisearch                        https://andisearch.com" )
 AddLine( "bagel                             https://demo.bagel-ai.org" )
 AddLine( "bing                              https://bing.com" )
 AddLine( "chatglm                           https://en.chatglm.cn" )
 AddLine( "chatgptcodeinterpreter            https://chat.openai.com/?model=gpt-4-code-interpreter" )
 AddLine( "chatpdf                           https://www.chatpdf.com" )
 AddLine( "coconote                          https://coconote.app/home/" )
 AddLine( "codewhisperer                     https://aws.amazon.com/codewhisperer/" )
 AddLine( "cohere                            https://huggingface.co/chat/models/CohereForAI/c4ai-command-r-plus-08-2024" )
 AddLine( "comet                             browserinternetperplexitycomet" )
 AddLine( "contextual                        https://contextual.ai" )
 AddLine( "convergence                       https://convergence.ai" )
 AddLine( "devinaiorg                        https://devinai.org" )
 AddLine( "elicit                            https://elicit.com" )
 AddLine( "everythinguniverse                https://anything.world" )
 AddLine( "genesis                           https://genesis-embodied-ai.github.io" )
 AddLine( "globe                             https://explorer.globe.engineer/" )
 AddLine( "googlelearning                    https://learning.google.com/experiments/learn-about/signup" )
 AddLine( "granite                           https://www.ibm.com/granite/playground/" )
 AddLine( "huggingface                       https://huggingface.co" )
 AddLine( "huggingfacemicrosoftphi           https://huggingface.co/microsoft/phi-4" )
 AddLine( "humata                            https://www.humata.ai" )
 AddLine( "inflectionpi                      https://heypi.com/talk?utm_source=inflection.ai" )
 AddLine( "ithy                              https://ithy.com" )
 AddLine( "julius                            https://julius.ai" )
 AddLine( "llama2                            https://huggingface.co/blog/llama2" )
 AddLine( "llama3                            https://huggingface.co/chat/models/meta-llama/Llama-3.3-70B-Instruct" )
 AddLine( "manus                             https://manus.im" )
 AddLine( "meta                              https://meta.ai" )
 AddLine( "minimaxagent                      https://hailuo.ai" )
 AddLine( "mixtral                           https://mixtral.replicate.dev/" )
 AddLine( "napkin                            https://napkin.ai" )
 AddLine( "ollama                            https://ollama.com" )
 AddLine( "operabrowserai                    https://www.opera.com/features/browser-ai" )
 AddLine( "pdfgpt                            https://pdfgpt.io" )
 AddLine( "poe                               https://poe.com" )
 AddLine( "poetiq                            https://poetiq.ai" )
 AddLine( "popai                             https://popai.pro" )
 AddLine( "proactor                          https://proactor.ai" )
 AddLine( "qwen32bpreview                    https://huggingface.co/Qwen/QwQ-32B-Preview" )
 AddLine( "reka                              https://chat.reka.ai/chat/" )
 AddLine( "replit                            https://replit.com" )
 AddLine( "sizzle                            https://www.szl.ai" )
 AddLine( "storm                             https://storm.genie.stanford.edu" )
 AddLine( "tabnine                           https://www.tabnine.com" )
 AddLine( "tutorlily                         https://tutorlily.com/?lang=en" )
 AddLine( "upend                             https://upend.ai" )
 AddLine( "watsonx                           https://servicesessentials.ibm.com/curatorai/apps/ui" )
 AddLine( "you                               https://you.com/search" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: GOOGLE" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "googlelabs                        https://labs.google/disco/" )
 AddLine( "googlelearnyourway                https://learnyourway.withgoogle.com" )
 AddLine( "googleskills                      https://skills.google" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: LLM: MULTIPLE: ACCESS" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "abacus                            https://chatllm.abacus.ai" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: BOOK" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "type                              https://type.ai" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: GRAPHICS                                                                                                                                                                                                           -                       -                                                                                                                                 -                         -                          -                                  -                                                                                                                                                                      0848                   -                      [kn, ri, sa, 22-11-2025 22:02:26]" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "backflip                          https://backflip.ai" )
 AddLine( "cat-4d                            https://cat-4d.github.io" )
 AddLine( "dall-e                            https://openai.com/index/dall-e-3/" )
 AddLine( "diffus                            https://diffus.me" )
 AddLine( "fal                               https://fal.ai" )
 AddLine( "fluxpro                           https://fluxpro.ai" )
 AddLine( "fluxultra                         https://blackforestlabs.ai/flux-1-1-ultra/" )
 AddLine( "googlegenie                       https://deepmind.google/discover/blog/genie-2-a-large-scale-foundation-world-model/" )
 AddLine( "hailuo                            https://hailuoai.video" )
 AddLine( "hunyuan                           https://www.hunyuanai.ai" )
 AddLine( "image-fx                          https://labs.google/fx/tools/image-fx/" )
 AddLine( "imagen                            https://deepmind.google/technologies/imagen-3/" )
 AddLine( "janus                             https://deepseek.ai/janus-pro-7b" )
 AddLine( "kling                             https://kling.kuaishou.com" )
 AddLine( "lumalabs                          https://lumalabs.ai" )
 AddLine( "midjourney                        https://midjourney.com/home" )
 AddLine( "odyssey                           https://odyssey.systems" )
 AddLine( "omagic                            https://omagic.ai" )
 AddLine( "omnihuman                         https://omnihuman-lab.github.io" )
 AddLine( "pika                              https://pika.art" )
 AddLine( "pinokio                           https://pinokio.computer" )
 AddLine( "recraft                           https://recraft.ai" )
 AddLine( "saiyan                            https://saiyan-world.github.io/goku/" )
 AddLine( "sora                              https://openai.com/index/sora/" )
 AddLine( "veo                               https://deepmind.google/technologies/veo/veo-2/" )
 AddLine( "vidu                              https://vidu.studio" )
 AddLine( "wan                               https://huggingface.co/spaces/Wan-AI/Wan2.1" )
 AddLine( "worldlabs                         https://worldlabs.ai" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ARTIFICIAL: INTELLIGENCE: MUSIC" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "riffusion                         https://riffusion.com" )
 AddLine( "suno                              https://suno.ai" )
 AddLine( "------------------------------------------------------------------" )
 //
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  s = Trim( GetText( 1, MAXSTRINGLEN ) )
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  RETURN( FNStringGetErrorS() )
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 s1 = GetToken( s, " ", 1 )
 s2 = GetToken( s, " ", 2 )
 //
 B = StartPgm( s2 )
 //
 IF NOT ( B )
  //
  Warn( s2, ":", " ", "could not be run. Please check." )
  //
  RETURN( FNStringGetErrorS() )
  //
 ENDIF
 //
 RETURN( s1 )
 //
END

// library: string: get: error <description>general output string to recognize an error (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstger.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 20:58:17]
STRING PROC FNStringGetErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetErrorS() ) // gives e.g. "<ERROR>"
 // e.g. END
 //
 RETURN( "<ERROR>" )
 //
END
