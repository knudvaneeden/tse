FORWARD INTEGER PROC FNBlockRunArtificialIntelligenceCase()
FORWARD INTEGER PROC FNBufferGetBufferIdFileCurrentI()
FORWARD INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckEscapeB( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckEditCentralMessageB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckEditMessageB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckGotoEndB()
FORWARD INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckGotoBeginB()
FORWARD INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckPurgeB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckLogicOrB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberGreaterZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheck_NumberDifferenceGreaterB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetInitializeNewI()
FORWARD INTEGER PROC FNMathGetIntegerZeroI()
FORWARD INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCaseInsensitiveB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckLocationAddressIpStartingWith10B()
FORWARD INTEGER PROC FNStringGetLengthI( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertB( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertCentralB( STRING s1, INTEGER i1 )
FORWARD PROC Main()
FORWARD PROC PROCError( STRING s1 )
FORWARD PROC PROCErrorCaseNotFound( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCErrorFileNotFound( STRING s1 )
FORWARD PROC PROCFileGotoEnd()
FORWARD PROC PROCFileInsertEndPrepare()
FORWARD PROC PROCFileInsertTextEnd( STRING s1, STRING s2, INTEGER i1 )
FORWARD PROC PROCLineInsertAfter()
FORWARD PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroPurge( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCMacroRunPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurgeParameter( STRING s1, STRING s2 )
FORWARD PROC PROCTextGetAbbreviationTemplateDataExtractDefault( STRING s1 )
FORWARD PROC PROCTextGetAbbreviation_TemplateDataExtract( STRING s1, STRING s2 )
FORWARD PROC PROCTextGotoLineBegin()
FORWARD PROC PROCTextInsert( STRING s1 )
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNProgramRunBrowserInternetUrlArtificialIntelligenceS()
FORWARD STRING PROC FNStringGetAddressIpIpconfigCaptureLocalS()
FORWARD STRING PROC FNStringGetAddressIpIpconfigCaptureS()
FORWARD STRING PROC FNStringGetAddressIpIpconfigCaptureVpnS()
FORWARD STRING PROC FNStringGetAddressIpSearchIpconfigCaptureS()
FORWARD STRING PROC FNStringGetAddressMacIpconfigCaptureCentralS( STRING s1, STRING s2, STRING s3, STRING s4, INTEGER i1 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCaseLowerS( STRING s1 )
FORWARD STRING PROC FNStringGetCaseUpperS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetConcatS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetConcatTailS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetCons4S( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD STRING PROC FNStringGetCons5S( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetDateDaynumberToDaynameS( INTEGER i1, STRING s1 )
FORWARD STRING PROC FNStringGetDateDaynumberTo_DaynameNEDS( INTEGER i1 )
FORWARD STRING PROC FNStringGetDateDaynumber_ToDaynameDUIS( INTEGER i1 )
FORWARD STRING PROC FNStringGetDateTodayFormatKnudDefaultS()
FORWARD STRING PROC FNStringGetDateTodayFormatKnudS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetDate_DaynumberToDaynameENGS( INTEGER i1 )
FORWARD STRING PROC FNStringGetEmptyS()
FORWARD STRING PROC FNStringGetEnvironmentS( STRING s1 )
FORWARD STRING PROC FNStringGetErrorS()
FORWARD STRING PROC FNStringGetEscapeS()
FORWARD STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameCurrentS()
FORWARD STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameGlobalErrorS()
FORWARD STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
FORWARD STRING PROC FNStringGetGlobalS( STRING s1 )
FORWARD STRING PROC FNStringGetInStringS( INTEGER i1, STRING s1 )
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetLanguageNaturalNameS( STRING s1 )
FORWARD STRING PROC FNStringGetLeftStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetLengthAddBeginS( STRING s1, INTEGER i1, STRING s2 )
FORWARD STRING PROC FNStringGetLengthAddS( STRING s1, INTEGER i1, STRING s2 )
FORWARD STRING PROC FNStringGetLineNumberCurrentS()
FORWARD STRING PROC FNStringGetLocationGeographyDefaultS()
FORWARD STRING PROC FNStringGetLocationVacationTrueS()
FORWARD STRING PROC FNStringGetMachineNameS()
FORWARD STRING PROC FNStringGetMathIntegerToStringS( INTEGER i1 )
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetNetworkIpaddressEthernetNameS()
FORWARD STRING PROC FNStringGetOperatingSystemS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetPortS()
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetSpaceRemoveBeginS( STRING s1 )
FORWARD STRING PROC FNStringGetTimeS()
FORWARD STRING PROC FNStringGetTokenLocationHomeS()
FORWARD STRING PROC FNStringGetTokenLocationJobS()
FORWARD STRING PROC FNStringGetTokenLocationVacationS()
FORWARD STRING PROC FNStringGetUserNameFirstS()
FORWARD STRING PROC FNStringGetUserNameLastS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


// --- MAIN --- //

PROC Main()
 Message( FNBlockRunArtificialIntelligenceCase() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: block: run: artificial: intelligence: case <description></description> <version control></version control> <version>1.0.0.0.14</version> <version control></version control> (filenamemacro=runblica.s) [<Program>] [<Research>] [kn, ri, su, 15-02-2026 22:19:54]
INTEGER PROC FNBlockRunArtificialIntelligenceCase()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockRunArtificialIntelligenceCase() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNBlockRunArtificialIntelligenceCase )
 // e.g. HELPDEF HELPDEFFNBlockRunArtificialIntelligenceCase
 // e.g.  title = "FNBlockRunArtificialIntelligenceCase() help" // The help's caption
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
 STRING infoS[255] = "Block copied to Microsoft Windows clipboard. Paste it in the AI prompt" // change this
 //
 STRING fileNameS[255] = "c:\temp\ddd.txt" // change this
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 STRING s1[255] = ""
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 s1 = GetText( CurrCol(), 255 )
 CopyToWinClip()
 Warn( LeftStr( s1, 20 ), "...", ":", " ", infoS )
 //
 s = FNProgramRunBrowserInternetUrlArtificialIntelligenceS()
 //
 GotoBufferId( bufferI )
 AddLine( Format( "Q. Computer: Editor: Text: TSE", ":", " ", s, ":", " ", s1, ":", " ", "[<", s, ">]", " ", "[<How to>]", " ", "[<Research>]" ) )
 AddLine()
 AddLine( "A." )
 AddLine( FNStringGetDateTodayFormatKnudDefaultS() )
 AddLine()
 BegLine()
 PROCTextGetAbbreviationTemplateDataExtractDefault( "gf" )
 AddLine()
 AddLine( Format( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" ) )
 //
 SaveAs( fileNameS, _APPEND_ )
 //
 RETURN( B )
 //
END

// library: program: run: browser: internet: url: artificial: intelligence <description></description> <version control></version control> <version>1.0.0.0.21</version> <version control></version control> (filenamemacro=runprain.s) [<Program>] [<Research>] [kn, ri, sa, 14-12-2024 21:13:47]
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
 AddLine( "deepseek                          https://chat.deepseek.com" )
 AddLine( "gemini                            https://gemini.google.com" )
 AddLine( "glm                               https://chat.z.ai" )
 AddLine( "grok                              https://grok.com/chat" )
 AddLine( "kimi                              https://kimi.ai" )
 AddLine( "minimax                           https://www.minimax.io" )
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
 AddLine( "copilotgithub                     https://github.com/features/copilot" )
 AddLine( "copilotmicrosoft                  https://copilot.microsoft.com" )
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

// library: string: get: date: today: format: knud: default <description></description> <version control></version control> <version>1.0.0.0.9</version> (filenamemacro=formdakd.s) [<Program>] [<Research>] [kn, ri, fr, 12-04-2002 02:58:56]
STRING PROC FNStringGetDateTodayFormatKnudDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetDateTodayFormatKnudDefaultS() ) // gives e.g. [kn, ri, su, 21-04-2002 02:19:16]
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringGetDateTodayFormatKnudS( "kn", FNStringGetLocationS( "eng" ) ) )
 //
 RETURN( FNStringGetDateTodayFormatKnudS( "kn", FNStringGetLocationGeographyDefaultS() ) )
 //
END

// library: text: get: abbreviation: template: data: extract: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteede.s) [<Program>] [<Research>] [kn, ri, su, 23-09-2007 21:35:09]
PROC PROCTextGetAbbreviationTemplateDataExtractDefault( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCTextGetAbbreviationTemplateDataExtractDefault( "su" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGetAbbreviation_TemplateDataExtract( s, "template.mac" )
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

// library: string: get: date in my own format (e.g. <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getdatk.s) [<Program>] [<Research>] [kn, ni, <dayname>, dd-mm-yy hh:mm:ss]). Saves a lot of retyping [kn, ni, mo, 03-08-1998 22:35:05]
STRING PROC FNStringGetDateTodayFormatKnudS( STRING mynameS, STRING mylocationS )
 // e.g. PROC Main()
 // e.g.  STRING nameS[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING languageS[255] = FNStringGetInitializeNewStringS()
 // e.g.  nameS = FNStringGetInputS( "string: get: date in my own format: name = ", "kn" )
 // e.g.  IF FNKeyCheckPressEscapeB( nameS ) RETURN() ENDIF
 // e.g.  languageS = FNStringGetInputS( "string: get: date in my own format: language = ", "eng" )
 // e.g.  IF FNKeyCheckPressEscapeB( languageS ) RETURN() ENDIF
 // e.g.  // Message( FNStringGetDateTodayFormatKnudS( "kn", FNStringGetLocationS( languageS ) ) ) // gives e.g. [kn, zoe, mo, 24-05-1999 18:23:15]
 // e.g.  Message( FNStringGetDateTodayFormatKnudS( "kn", FNStringGetLocationGeographyDefaultS() ) ) // gives e.g. [kn, zoe, mo, 24-05-1999 18:23:15]
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER dayI = FNMathGetInitializeNewI()
 //
 INTEGER monthI = FNMathGetInitializeNewI()
 //
 INTEGER yearI = FNMathGetInitializeNewI()
 //
 INTEGER dowI = FNMathGetInitializeNewI()
 //
 GetDate( monthI, dayI, yearI, dowI ) // get current date
 //
 RETURN( Format( "[", mynameS, ", ", mylocationS, ", ", FNStringGetCaseLowerS( FNStringGetDateDaynumberToDaynameS( dowI, "eng" ) ), ", ", dayI:2:"0", "-", monthI:2:"0", "-", yearI, " ", FNStringGetTimeS(), "]" ) )
 //
END

// library: string: get: location <description></description> <version control></version control> <version>1.0.0.0.22</version> (filenamemacro=getstglo.s) // location: return the location (depending on the time of the day (and or if your are on vacation (e.g. nice)) [<Program>] [<Research>] [kn, ni, we, 23-08-2006 17:42:29]
STRING PROC FNStringGetLocationGeographyDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLocationGeographyDefaultS() ) // version short // gives e.g. "[kn, ni, we, 23-08-2006 17:40:26]"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER dayI = FNMathGetInitializeNewI()
 //
 INTEGER dowI = FNMathGetInitializeNewI()
 //
 INTEGER monthI = FNMathGetInitializeNewI()
 //
 INTEGER yearI = FNMathGetInitializeNewI()
 //
 STRING daynameS[255] = FNStringGetTimeS()
 //
 STRING languageinS[255] = "eng"
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 STRING timeS[255] = FNStringGetTimeS()
 //
 GetDate( monthI, dayI, yearI, dowI )
 //
 // if vacation activate this
 //
 IF FNStringCheckEqualCaseInsensitiveB( FNStringGetFileIniDefaultS( "StringGetLocationVacationCheckS" ), FNStringGetLocationVacationTrueS() )
  //
  RETURN( FNStringGetTokenLocationVacationS() )
  //
 ENDIF
 //
 CASE daynameS
  //
  WHEN
   //
   "sa",
   //
   "su"
   //
    RETURN( FNStringGetTokenLocationHomeS() )
    //
  OTHERWISE
   //
   // do nothing
   //
 ENDCASE
 //
 IF ( FNStringCheckLocationAddressIpStartingWith10B() ) // IP address in 10.x.y.z range, thus always job // [kn, ri, th, 29-03-2012 00:36:53]
  //
  RETURN( FNStringGetTokenLocationJobS() )
  //
 ENDIF
 //
 daynameS = FNStringGetCaseLowerS( FNStringGetDateDaynumberToDaynameS( dowI, languageinS ) )
 //
 IF timeS IN "08:30:00".."20:00:00" // new [kn, am, th, 25-11-2010 10:13:07]
  //
  s = FNStringGetTokenLocationJobS()
  //
 ELSE
  //
  s = FNStringGetTokenLocationHomeS()
  //
 ENDIF
 //
 // IF ( FNMathCheckComputerNameHomeB() )
 //  //
 //  RETURN( FNStringGetTokenLocationHomeS() )
 //  //
 // ENDIF
 // //
 // IF ( FNMathCheckComputerNameJobB() )
 //  //
 //  RETURN( FNStringGetTokenLocationJobS() )
 //  //
 // ENDIF
 //
 RETURN( s )
 //
END

// library: text: get: abbreviation: template: data: extract <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gettedex.s) [<Program>] [<Research>] [kn, ri, mo, 28-05-2007 02:41:59]
PROC PROCTextGetAbbreviation_TemplateDataExtract( STRING s, STRING macroNameS )
 // e.g. PROC Main()
 // e.g.  PROCTextGetAbbreviation_TemplateDataExtract( "su", "template.mac" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextInsert( s )
 //
 PROCMacroRunKeep( macroNameS )
 //
END

// library: math: get: initialize: new <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getmaine.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:59:54]
INTEGER PROC FNMathGetInitializeNewI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetInitializeNewI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathGetIntegerZeroI() )
 //
END

// library: string: uppercase/lowercase: lower case: convert characters in string to lower case <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstclp.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:21:07]
STRING PROC FNStringGetCaseLowerS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: case: lower: string = ", "This is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCaseLowerS( s1 ) ) // gives e.g. "this is a test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Lower( s ) )
 //
END

// library: string: get: date: daynumber: to: dayname <description>string: get: date: given the daynumber (1=Sunday, 2=Monday, ...) return the corresponding dayname. Use the DOS routine 'date' for it</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getsttdc.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 22:20:38]
STRING PROC FNStringGetDateDaynumberToDaynameS( INTEGER dowI, STRING languageinS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetDateDaynumberToDaynameS( 1, "ned" ) ) // gives 'zo'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[2] = FNStringGetInitializeNewStringS()
 //
 STRING languageS[255] = FNStringGetCaseUpperS( languageinS )
 //
 CASE FNStringGetLanguageNaturalNameS( languageS )
  //
  WHEN "DUI"
   //
   s = FNStringGetDateDaynumber_ToDaynameDUIS( dowI )
   //
  WHEN "NED"
   //
   s = FNStringGetDateDaynumberTo_DaynameNEDS( dowI )
   //
  WHEN "ENG"
   //
   s = FNStringGetDate_DaynumberToDaynameENGS( dowI )
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetDateDaynumberToDaynameS()", "language: " + languageS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: time: current: (Returns the Current System Time as String) N    * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgti.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 01:29:11]
STRING PROC FNStringGetTimeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTimeS() ) // gives e.g. 03:44:25
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = GetTimeStr()
 //
 // RETURN( GetTimeStr() )
 //
 s = FNStringGetSpaceRemoveBeginS( s )
 //
 RETURN( FNStringGetLengthAddBeginS( s, 2 + 1 + 2 + 1 + 2, "0" ) )
 //
END

// library: string: get: initialize: new: string <description>string: initialize</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstnsa.s) [<Program>] [<Research>] [[kn, ri, mo, 09-07-2001 12:00:07]
STRING PROC FNStringGetInitializeNewStringS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetInitializeNewStringS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetEmptyS() )
 //
END

// library: string: check: equal: case: insensitive: convert first the two strings to upper case, then compare for equality <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=checstcj.s) [<Program>] [<Research>] [kn, ri, th, 18-10-2001 23:04:06]
INTEGER PROC FNStringCheckEqualCaseInsensitiveB( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: check: equal: case: insensitive: first string = ", "tESTiNg" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: check: equal: case: insensitive: second string = ", "TeStING" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringCheckEqualCaseInsensitiveB( s1, s2 ) ) // gives TRUE when the characters in both strings are equal (case insensitive)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringCheckEqualB( FNStringGetCaseUpperS( s1 ), FNStringGetCaseUpperS( s2 ) ) )
 //
 RETURN( EquiStr( s1, s2 ) )
 //
END

// library: string: get: file: ini: default <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstids.s) [<Program>] [<Research>] [kn, ri, th, 16-10-2025 00:57:40]
STRING PROC FNStringGetFileIniDefaultS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileIniDefaultS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g.
 //
 RETURN( FNStringGetFileIniDefaultCrossPlatformS( searchS ) )
 //
END

// library: string: get: location: vacation: true <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstvtr.s) [<Program>] [<Research>] [kn, ho, we, 23-08-2006 17:39:38]
STRING PROC FNStringGetLocationVacationTrueS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLocationVacationTrueS() ) // gives e.g. "true"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "StringGetLocationVacationTrueS" ) )
 //
END

// library: string: get: token: location: vacation <description></description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstlva.s) [<Program>] [<Research>] [kn, ri, th, 24-02-2011 00:20:39]
STRING PROC FNStringGetTokenLocationVacationS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLocationVacationS() ) // gives e.g. "ni"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "StringGetLocationVacationS" ) )
 //
END

// library: string: get: location: home <description></description> <version control></version control> <version>1.0.0.0.7</version> (filenamemacro=getstlho.s) [<Program>] [<Research>] [kn, ri, su, 14-04-2002 21:50:37]
STRING PROC FNStringGetTokenLocationHomeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLocationHomeS() ) // gives e.g. "ri"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "ni" )
 //
 // RETURN( "ri" )
 //
 RETURN( FNStringGetFileIniDefaultS( "StringGetLocationHomeS" ) )
 //
END

// library: string: check: location: address: ip: starting: with10 <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=checstsw.s) [<Program>] [<Research>] [kn, ri, sa, 01-03-2014 17:05:53]
INTEGER PROC FNStringCheckLocationAddressIpStartingWith10B()
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckLocationAddressIpStartingWith10B() ) // gives e.g. TRUE if the first digit of the IP address is "10" // IP address not in 10.x.y.z range, thus always not job
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 B = ( LeftStr( FNStringGetAddressIpIpconfigCaptureS(), 3 ) == "10." )
 //
 RETURN( B )
 //
END

// library: string: get: location: job <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstljo.s) [<Program>] [<Research>] [kn, ri, su, 14-04-2002 21:50:37]
STRING PROC FNStringGetTokenLocationJobS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLocationJobS() ) // gives e.g. "am"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "amstv" )
 //
 // RETURN( "ni" )
 //
 // RETURN( "ri" )
 //
 // RETURN( "amv" )
 //
 // RETURN( "am" )
 //
 RETURN( FNStringGetFileIniDefaultS( "StringGetLocationJobS" ) )
 //
END

// library: text: insert: insert text <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=insetein.s) [<Program>] [<Research>] [kn, ni, mo, 10-08-1998 06:26:51]
PROC PROCTextInsert( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "which text to insert at current position = ", FNStringGetEmptyS() )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  PROCTextInsert( s )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNStringCheckEmptyB( s )
  //
  // PROCerror( FNStringGetFilenameCurrentS() + ": Attempt made to insert an empty string" )
  //
  RETURN()
  //
 ENDIF
 //
 IF FNMathCheckLogicNotB( FNTextCheckInsertB( s ) )
  //
  PROCerror( FNStringGetCons4S( FNStringGetFilenameCurrentS(), ": Text '", s, "' could not be inserted" ) )
  //
 ENDIF
 //
END

// library: macro: run: keep <description>macro: run a macro, then keep it</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmarke.s) [<Program>] [<Research>] [[kn, zoe, fr, 27-10-2000 15:59:33]
PROC PROCMacroRunKeep( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunKeep( "mysubma1.mac myparameter11 myparameter12" )
 // e.g.  PROCMacroRunKeep( "mysubma2.mac myparameter21" )
 // e.g.  PROCMacroRunKeep( "mysubma3.mac myparameter31 myparameter32" )
 // e.g. END
 //
 IF FNMacroCheckLoadB( FNStringGetCarS( macronameS ) ) // necessary if you pass parameters in a string
  //
  PROCMacroExec( macronameS )
  //
 ENDIF
 //
END

// library: math: get: integer: zero <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getmaize.s) [<Program>] [<Research>] [kn, ri, we, 06-02-2002 21:12:47]
INTEGER PROC FNMathGetIntegerZeroI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerZeroI() ) // gives e.g. 9
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( 0 )
 //
END

// library: string: get: case: uppercase/lowercase: upper case: convert characters in string to upper case <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcuq.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:21:07]
STRING PROC FNStringGetCaseUpperS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: case: upper: string = ", "This is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCaseUpperS( s1 ) ) // gives e.g. "THIS IS A TEST"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Upper( s ) )
 //
END

// library: string: get: language: natural: name <description>language: name: return the language name</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstnnb.s) [<Program>] [<Research>] [[kn, zoe, we, 27-10-1999 21:46:12]
STRING PROC FNStringGetLanguageNaturalNameS( STRING s )
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetLanguageNaturalNameS( "engels" ) ) // gives "ENG"
 // e.g.  Warn( FNStringGetLanguageNaturalNameS( "nederlands" ) ) // gives "NED"
 // e.g.  Warn( FNStringGetLanguageNaturalNameS( "frans" ) ) // gives "FRA"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCaseUpperS( FNStringGetLeftStringS( s, 3 ) ) )
 //
END

// library: string: get: date: daynumber: to: dayname: d: u <description>date: given the daynumber (1=Sunday, 2=Monday, ...) return the corresponding dayname. Use the DOS routine 'date' for it: DUI</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstui.s) [<Program>] [<Research>] [[kn, zoe, mo, 24-05-1999 19:17:14]
STRING PROC FNStringGetDateDaynumber_ToDaynameDUIS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetDateDaynumber_ToDaynameDUIS( 1 ) ) // gives 'Sonntag'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[15] = FNStringGetInitializeNewStringS()
 //
 CASE I
  //
  WHEN 1
   //
   s = "Sonntag"
   //
  WHEN 2
   //
   s = "Montag"
   //
  WHEN 3
   //
   s = "Dienstag"
   //
  WHEN 4
   //
   s = "Mittwoch"
   //
  WHEN 5
   //
   s = "Donnerstag"
   //
  WHEN 6
   //
   s = "Freitag"
   //
  WHEN 7
   //
   s = "Samstag"
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetDateDaynumber_ToDaynameDUIS(", STR( I ) + ": unknown daynumber (must be 1,2,3,4,5,6,7)" )
   //
   RETURN( "Unknown daynumber" )
   //
   // PROCError( STR( dowI ) + ": unknown daynumber (must be 1,2,3,4,5,6,7)" )
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: string: get: date: daynumber: to: dayname: n: e <description>date: given the daynumber (1=Sunday, 2=Monday, ...) return the corresponding dayname. Use the DOS routine 'date' for it: NED</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getsted.s) [<Program>] [<Research>] [[kn, zoe, mo, 24-05-1999 19:17:14]
STRING PROC FNStringGetDateDaynumberTo_DaynameNEDS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetDateDaynumberTo_DaynameNEDS( 1 ) ) // gives 'zondag'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[15] = FNStringGetInitializeNewStringS()
 //
 CASE I
  //
  WHEN 1
   //
   s = "zondag"
   //
  WHEN 2
   //
   s = "maandag"
   //
  WHEN 3
   //
   s = "dinsdag"
   //
  WHEN 4
   //
   s = "woensdag"
   //
  WHEN 5
   //
   s = "donderdag"
   //
  WHEN 6
   //
   s = "vrijdag"
   //
  WHEN 7
   //
   s = "zaterdag"
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetDateDaynumberTo_DaynameNEDS(", STR( I ) + ": unknown daynumber (must be 1,2,3,4,5,6,7)" )
   //
   RETURN( "Unknown daynumber" )
   //
   // PROCError( STR( dowI ) + ": unknown daynumber (must be 1,2,3,4,5,6,7)" )
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: string: get: date: daynumber: to: dayname: e: n <description>date: given the daynumber (1=Sunday, 2=Monday, ...) return the corresponding dayname. Use the DOS routine 'date' for it: ENG</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstnh.s) [<Program>] [<Research>] [[kn, zoe, mo, 24-05-1999 19:17:14]
STRING PROC FNStringGetDate_DaynumberToDaynameENGS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetDate_DaynumberToDaynameENGS( 1 ) ) // gives 'Sunday'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[15] = FNStringGetInitializeNewStringS()
 //
 INTEGER caseminI = 0 // start at zero
 //
 INTEGER caseI = caseminI + I
 //
 CASE caseI
  //
  WHEN 1
   //
   s = "Sunday"
   //
  WHEN 2
   //
   s = "Monday"
   //
  WHEN 3
   //
   s = "Tuesday"
   //
  WHEN 4
   //
   s = "Wednesday"
   //
  WHEN 5
   //
   s = "Thursday"
   //
  WHEN 6
   //
   s = "Friday"
   //
  WHEN 7
   //
   s = "Saturday"
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetDate_DaynumberToDaynameENGS(", FNStringGetConsS( FNStringGetMathIntegerToStringS( caseI ), ": unknown daynumber (must be 1,2,3,4,5,6,7)" ) )
   //
   RETURN( FNStringGetConsS( FNStringGetErrorS(), "unknown daynumber" ) )
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: error: case: not: found <description>error: case: not: found</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=caseernf.s) [<Program>] [<Research>] [[kn, ri, we, 28-02-2001 23:08:10]
PROC PROCErrorCaseNotFound( STRING infoS, STRING procfnnameS, STRING caseS )
 // e.g. PROC Main()
 // e.g.  PROCErrorCaseNotFound( infoS, procfnnameS, caseS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCError( FNStringGetCons5S( procfnnameS, infoS, ": case: ", caseS, " not found / unknown option" ) )
 //
END

// library: string: get: empty (return an empty string) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgem.s) [<Program>] [<Research>] [kn, ri, sa, 20-05-2000 20:11:03]
STRING PROC FNStringGetEmptyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEmptyS() ) // gives e.g. the empty string: ""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "" )
 //
END

// library: string: space: remove: begin <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=remostsb.s) [<Program>] [<Research>] [kn, ri, th, 15-02-2001 06:06:51]
STRING PROC FNStringGetSpaceRemoveBeginS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: space: remove: begin: string = ", "   test    " )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( "'", FNStringGetSpaceRemoveBeginS( s ), "'" ) // gives e.g. "test    "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LTrim( s ) )
 //
END

// library: string: get: length: add: begin <description>string: add: first: smaller length adapting with a certain character, on the FRONT of the string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstabe.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 17:56:47]
STRING PROC FNStringGetLengthAddBeginS( STRING s, INTEGER lenmaxI, STRING fillS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLengthAddBeginS( "knud", 15, "0" ) ) // gives "00000000000knud" (because the total length has to be 15)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetLengthAddS( s, lenmaxI, fillS ), s ) )
 //
END

// library: string: get: file: ini: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.9</version> <version control></version control> (filenamemacro=getstcpo.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:44:08]
STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileIniDefaultCrossPlatformS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g.
 //
 // USAGE
 //
 // 1. -Choose a filename for your global variables initialization file
 //
 //    1. -E.g. default name is here
 //
 //         dddpath.ini
 //
 //    2. -You can set this name in a function in this library, if you
 //
 //        want to change the default name
 //
 // 3. -Save this file in the directory
 //
 //     (path chosen to be given by Microsoft Windows environment variable APPDATA)
 //
 //      C:\Documents and Settings\<your Microsoft Windows login name>\Application Data\
 //
 // 4. -The full path to your initialization file is thus e.g.
 //
 //      C:\Documents and Settings\Administrator\Application Data\dddpath.ini
 //
 // 5. -To keep things as simple as possible, you need to put once
 //
 //     in top of your file the word (which must start at the beginning
 //
 //     of the line). Further no more '[' characters starting at the begin of any line.
 //
 //      [default]
 //
 // 6. -This file contains 0 or more lines of the general format
 //
 //      <variable name> = <variable value>
 //
 //     1. -E.g.
 //
 //         [default]
 //
 //          path4dos = c:\4dos
 //
 //          tsevariable1 = test1
 //
 //          tsevariable2 = test2
 //
 //          tsevariable3 = test3
 //
 //          ...
 //
 //     2. -Note: you should/could put spaces before and after the '=' sign
 //
 //         (e.g. for backwards compatibility purposes)
 //
 // 7. -Using this library, you can then e.g. get the value of your global variable from this file
 //
 STRING s[255] = ""
 //
 s = FNStringGetFileGetFilenamePathDefaultCrossPlatformS( searchS )
 //
 IF EquiStr( Trim( s ), "" )
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  Warn( searchS, ":", " ", "Not found (or found but the value is the empty string). Please check dddpath.ini and adapt file bibdelphi.del" )
 ENDIF
 //
 // If a filename it should be checked and converted if applicable in the receiving function, not before that.
 // IF ( StrFind( "^[A-Za-z]:", s, "gx" ) > 0 ) // is it a filename?
 // s = FNStringGetMicrosoftWindowsToCrossPlatformS( s )
 // //
 // ENDIF
 //
 RETURN( s )
 //
END

// library: string: get: address: ip: ipconfig: capture <description></description> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=getsticb.s) [<Program>] [<Research>] [kn, am, mo, 02-07-2012 10:23:13]
STRING PROC FNStringGetAddressIpIpconfigCaptureS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAddressIpIpconfigCaptureS() ) // gives e.g. "10.20.30.40"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetAddressIpIpconfigCaptureVpnS()
 //
 IF ( FNStringCheckEqualErrorOrEmptyB( s ) )
  //
  s = FNStringGetAddressIpIpconfigCaptureLocalS()
  //
 ENDIF
 //
 IF ( FNStringCheckEqualErrorOrEmptyB( s ) )
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 RETURN( s )
 //
END

// library: string: check: empty <description>string: empty: is given string empty?</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcz.s) [<Program>] [<Research>] [[kn, ri, sa, 20-05-2000 20:11:08]
INTEGER PROC FNStringCheckEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyB( s ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEmptyS() ) )
 //
END

// library: math: check: logic: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmaln.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:21]
INTEGER PROC FNMathCheckLogicNotB( INTEGER B )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "math: check: logic: not: number = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicNotB( FNStringGetToIntegerI( s ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( NOT B )
 //
END

// library: text: check: insert <description>text: insert: insert text</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checteci.s) [<Program>] [<Research>] [[kn, zoe, tu, 23-11-1999 20:30:45]
INTEGER PROC FNTextCheckInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertB( s ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckInsertCentralB( s, _INSERT_ ) )
 //
END

// library: error <description>error: central routine</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=ererror.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:12]
PROC PROCError( STRING s )
 // e.g. INTEGER ErrorGB = FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  PROCError( "this is an error" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSavePositionStackPush()
 //
 // Alarm()
 //
 // PROCWarn( s )
 //
 // Message( s )
 //
 // Message( "Linenr ", FNMathGetProgramLineNumberAbsoluteCurrentI(), ": ", s )
 //
 PROCWarnCons4( "Error: Linenr", FNStringGetLineNumberCurrentS(), ":", s )
 //
 // only when seriously: PROCFileInsertTextEnd( "line " + STR( FNMathGetProgramLineNumberAbsoluteCurrentI() ) + ": " + s, FNStringGetFilenameGlobalErrorS(), FNMathCheckGetLogicTrueB() )
 //
 PROCFileInsertTextEnd( "line " + STR( FNMathGetProgramLineNumberAbsoluteCurrentI() ) + ": " + s, FNStringGetFilenameGlobalErrorS(), FNMathCheckGetLogicTrueB() )
 //
 // errorGB = FNMathCheckGetLogicTrueB()
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: string: get: cons4: string: concatenation: 4 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcz.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:54:56]
STRING PROC FNStringGetCons4S( STRING s1, STRING s2, STRING s3, STRING s4 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons4S( "a", "b", "c", "d" ) ) // gives e.g. "a b c d"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetCons3S( s1, s2, s3 ), s4 ) )
 //
END

// library: file: filename: get: current: return current filename (as a string containing the complete path) (Get Full Name of Current Buffer) (nofilenamemacro) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstfcv.s) [<Program>] [<Research>] [kn, ni, sa, 08-08-1998 00:02:37] [FNfilenamecurrent]
STRING PROC FNStringGetFilenameCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameCurrentS() ) // gives e.g. "c:\wordproc\tse\ddd.ddd"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrFilename() )
 //
END

// library: macro: check: load <description>macro: load: (Loads a Macro File From Disk Into Memory) R    LoadMacro(STRING macro_filename)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacl.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:07:06]
INTEGER PROC FNMacroCheckLoadB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckLoadB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LoadMacro( macronameS ) )
 //
END

// library: string: get: word: token: get: first: FNStringGetCarS(): Get the first word of a string (words delimited by a space " " (=space delimited list)). <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgca.s) [<Program>] [<Research>] [kn, ni, su, 02-08-1998 15:54:17]
STRING PROC FNStringGetCarS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: first: s = ", "this is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarS( s1 ) ) // gives e.g. "this"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetTokenFirstS( s, " " ) )
 //
 RETURN( GetToken( s, " ", 1 ) ) // faster, but not central
 //
END

// library: macro: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=execmame.s) [[kn, zoe, we, 16-06-1999 01:06:54]
PROC PROCMacroExec( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroExec( "video" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNMacroCheckExecB( macronameS ) )
  //
  PROCWarnCons3( "macro", macronameS, ": could not be executed" )
  //
 ENDIF
 //
END

// library: string: get: word: token: first: return a given integer amount of characters from the left of a given string (=LEFT$ in BASIC) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=strilels.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:05:49]
STRING PROC FNStringGetLeftStringS( STRING s, INTEGER totalI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING charactertotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: word: token: get: left: string = ", "knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  charactertotalS = FNStringGetInputS( "string: word: token: get: left: character total = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( charactertotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetLeftStringS( s, FNStringGetToIntegerI( charactertotalS ) ) ) //  gives e.g. "kn"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetMidStringS( s, 1, totalI ) )
 //
END

// library: string: get: cons: string: concatenation: concatenation 2 words to 1 word (separated by a space) <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstgcx.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:15:03]
STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
 // e.g. //
 // e.g. // version with test if string empty
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConsS( "john", "doe" ) ) // gives "john doe"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetCharacterSymbolSpaceS() ) )
 //
END

// library: string: get: math: get: integer: to: convert an integer to a string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttsu.s) [<Program>] [<Research>] [number to string] [kn, ni, mo, 03-08-1998 00:34:05]
STRING PROC FNStringGetMathIntegerToStringS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMathIntegerToStringS( 3 ) ) // gives e.g. "3"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Str( I ) )
 //
END

// library: string: get: cons5: string: concatenation: 5 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcb.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:55:03]
STRING PROC FNStringGetCons5S( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons5S( "a", "b", "c", "d", "e" ) ) // gives e.g. "a b c d e"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetCons4S( s1, s2, s3, s4 ), s5 ) )
 //
END

// library: string: get: concat <description>concatenation 2 words tot 1 word</description> <version>1.0.0.0.3</version> (filenamemacro=getstgch.s) [<Program>] [<Research>] [kn, zoe, th, 01-02-2001 19:32:49]
STRING PROC FNStringGetConcatS( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatS( "test1", "test2" ) ) // version with test if string empty ) // gives e.g. "test1test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetEmptyS() ) )
 //
END

// library: string: get: length: add <description>string: add: length adapting with a certain character</description> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstlaf.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 17:57:31]
STRING PROC FNStringGetLengthAddS( STRING s, INTEGER lengthI, STRING fillS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLengthAddS( "test", 6, "0" ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //
 // see also Format()
 //
 // E.g. Format( s: 4 : "0" ) // always length 4, if necessary append 0 in front
 // E.g. Format( s: lengthI : fillS ) // always length 4, if necessary append 0 in front
 //
 INTEGER lenI = FNMathGetInitializeNewI()
 //
 INTEGER lengthdifferenceI = FNMathGetInitializeNewI()
 //
 lenI = FNStringGetLengthI( s )
 //
 lengthdifferenceI = lengthI - lenI
 //
 IF FNMathCheckNumberGreaterZeroB( lengthdifferenceI )
  //
  RETURN( FNStringGetInStringS( lengthdifferenceI, fillS ) )
  //
 ENDIF
 //
 RETURN( FNStringGetEmptyS() )
 //
END

// library: string: get: file: get: filename: path: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstcpn.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:32:24]
STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileGetFilenamePathDefaultCrossPlatformS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetInitializationGlobalS( searchS, FNStringGetSectionSeparatorS(), FNStringGetFilenameIniDefaultCrossPlatformS() ) )
 //
END

// library: string: get: address: ip: ipconfig: capture: vpn <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getstcvp.s) [<Program>] [<Research>] [kn, ri, fr, 25-11-2016 12:04:53]
STRING PROC FNStringGetAddressIpIpconfigCaptureVpnS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAddressIpIpconfigCaptureVpnS() ) // gives e.g. "10.20.30.40"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringGetAddressMacIpconfigCaptureCentralS( "c:\windows\system32\ipconfig.exe", "/all", "Ethernet adapter VPN Network", FNStringGetAddressIpSearchIpconfigCaptureS(), 2 ) )
 RETURN( FNStringGetAddressMacIpconfigCaptureCentralS( "c:\windows\system32\ipconfig.exe", "/all", FNStringGetNetworkIpaddressEthernetNameS(), FNStringGetAddressIpSearchIpconfigCaptureS(), 2 ) )
 //
END

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEqualErrorOrEmptyB( FNStringGetEmptyS() ) ) // gives TRUE if string empty or string equals error string
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicOrB( FNErrorCheckSB( s ), FNStringCheckEmptyB( s ) ) )
 //
END

// library: string: get: address: ip: ipconfig: capture: local <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getsticj.s) [<Program>] [<Research>] [kn, ri, fr, 25-11-2016 12:07:34]
STRING PROC FNStringGetAddressIpIpconfigCaptureLocalS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAddressIpIpconfigCaptureLocalS() ) // gives e.g. "192.168.1.1"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetAddressMacIpconfigCaptureCentralS( "c:\windows\system32\ipconfig.exe", "/all", "Ethernet adapter Local Area Connection", FNStringGetAddressIpSearchIpconfigCaptureS(), 2 ) )
 //
END

// library: string: check: equal <description>string: equal: are two given strings equal? (stored in 'checstcf.s')</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcy.s) [<Program>] [<Research>] [[kn, zoe, we, 04-10-2000 18:23:27]
INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: check: equal: first string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: check: equal: second string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringCheckEqualB( s1, s2 ) ) // gives e.g. TRUE when string1 is equal to string2
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "knud" ) ) // gives TRUE
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "van" ) ) // gives FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( s1 == s2 )
 //
END

// library: text: check: insert: central <description>text: insert: insert text: central</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checteic.s) [<Program>] [<Research>] [[kn, ri, fr, 16-02-2001 22:00:44]
INTEGER PROC FNTextCheckInsertCentralB( STRING s, INTEGER optionB )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertCentralB( s, optionB ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( InsertText( s, optionB ) )
 //
END

// library: text: save: position: stack: push <description>text: save: position: stack: push: store</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=savetesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextSavePositionStackPush()
 // e.g. PROC Main()
 // e.g.  PROCTextSavePositionStackPush()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushPosition() // returns nothing
 //
 // pushpopGT = pushpopGT + 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: warn: cons4 <description>error: warning: give a warning message via 4 strings</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=conswawe.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:28:22]
PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons4( "error", "1", "2", "3" ) // gives e.g. "error 1 2 3"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons4S( s1, s2, s3, s4 ) )
 //
END

// library: string: get: line: number: current (return the current linenumber) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstncm.s) [<Program>] [<Research>] [kn, ni, mo, 02-08-1999 00:46:42]
STRING PROC FNStringGetLineNumberCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineNumberCurrentS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetMathIntegerToStringS( FNMathGetProgramLineNumberAbsoluteCurrentI() ) )
 //
END

// library: file: insert: text: end <description>file: line: text: insert: end: goto the end of the given file, insert some text (when newlineB is TRUE, start every inserted line on a new line)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=insefite.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:29]
PROC PROCFileInsertTextEnd( STRING s, STRING filenameS, INTEGER newlineB )
 // e.g. PROC Main()
 // e.g.  PROCFileInsertTextEnd( "this is put on the end of the file", "myoutputfile", FNMathCheckGetLogicTrueB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSavePositionStackPush()
 //
 IF FNMathCheckLogicNotB( FNFileCheckEditMessageB( filenameS ) )
  //
  PROCTextRemovePositionStackPop()
  //
  RETURN()
  //
 ENDIF
 //
 PROCFileGotoEnd()
 //
 IF ( newlineB )
  //
  PROCFileInsertEndPrepare()
  //
 ENDIF
 //
 PROCTextInsert( s )
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: math: get: program: line: number: absolute: current <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getfincu.s) [<Program>] [<Research>] [kn, ni, mo, 02-08-1999 00:46:42]
INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetProgramLineNumberAbsoluteCurrentI() ) // gives e.g. 332 if the cursor is on line 332 in the current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //                                                     |
 //                                                     ...
 // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³V
 // ³cursor is here on this line                       ³--- <-- CurrLine()
 // ³                                                  ³
 // ³                                                  ³
 // ³[end of file]-------------------------------------³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //
 RETURN( CurrLine() )
 //
END

// library: string: get: filename: global: error <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstget.s) [<Program>] [<Research>] [kn, zoe, fr, 20-10-2000 23:34:48]
STRING PROC FNStringGetFilenameGlobalErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameGlobalErrorS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetGlobalS( "filenameerrorGS" ) )
 //
END

// library: math: check: get: logic: true: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalt.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:12]
INTEGER PROC FNMathCheckGetLogicTrueB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicTrueB() ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( TRUE )
 //
END

// library: text: remove: position: stack: pop <description>text: remove: position: stack: pop: restore</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=remotesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextRemovePositionStackPop()
 // e.g. PROC Main()
 // e.g.  PROCTextRemovePositionStackPop()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PopPosition() // returns nothing
 //
 // pushpopGT = pushpopGT - 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: string: get: cons3: string: concatenation: 3 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcy.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:52:07]
STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons3S( "a", "b", "c" ) ) // gives e.g. "a b c"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetConsS( s1, s2 ), s3 ) )
 //
END

// library: macro: check: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmace.s) [[kn, zoe, we, 16-06-1999 01:06:54]
INTEGER PROC FNMacroCheckExecB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckExecB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( ExecMacro( macronameS ) )
 //
END

// library: warn: cons3 <description>error: warning: give a warning message via 3 strings</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=conswawd.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:24:52]
PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons3( "error", "1", "2" ) // gives e.g. "error 1 2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons3S( s1, s2, s3 ) )
 //
END

// library: string: get: mid: string <description></description> <version control>string: get: word: token: middle: return a given integer amount of characters from a given startposition</version control> <version>1.0.0.0.9</version> (=MID$ in BASIC) <version>1.0.0.0.9</version> (filenamemacro=getstmid.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:29:00]
STRING PROC FNStringGetMidStringS( STRING s, INTEGER beginI, INTEGER totalI  )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING positionBeginS[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING characterTotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: MIDSTRING: string = ", "testing" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  positionBeginS = FNStringGetInputS( "string: get: MIDSTRING: beginposition = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( positionBeginS ) RETURN() ENDIF
 // e.g.  characterTotalS = FNStringGetInputS( "string: get: MIDSTRING: character total = ", "3" )
 // e.g.  IF FNKeyCheckPressEscapeB( characterTotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetMidStringS( s, FNStringGetToIntegerI( positionBeginS ), FNStringGetToIntegerI( characterTotalS ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // Message( FNStringGetMidStringS( "knud", 2, 3 ) ) // gives "nud"
 //
 // Message( FNStringGetMidStringS( "knud", 3, 2 ) ) // gives "ud"
 //
 RETURN( SubStr( s, beginI, totalI ) )
 //
END

// library: string: get: concat: separator: string: concatenation: concatenate 2 words to 1 word, separated by separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcsg.s) [<Program>] [<Research>] [kn, zoe, th, 01-07-1999 01:33:18]
STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING separatorS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatSeparatorS( "test1", "test2", " " ) ) // gives e.g. "tes1 test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNStringCheckEmptyB( s1 ) RETURN( s2 ) ENDIF
 //
 IF FNStringCheckEmptyB( s2 ) RETURN( s1 ) ENDIF
 //
 RETURN( s1 + separatorS + s2 ) // leave this like this. Do not call a function, as this is a primitive function, you will get into a recursive loop, and get stack overflow
 //
END

// library: string: get: character: symbol: " " <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstssp.s) [<Program>] [<Research>] [kn, zoe, we, 25-10-2000 01:33:39]
STRING PROC FNStringGetCharacterSymbolSpaceS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolSpaceS() ) // gives " "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 32 ) )
 //
END

// library: string: line: length: what is the length <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgle.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:20:58]
INTEGER PROC FNStringGetLengthI( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: line: length: string = ", "this is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetLengthI( s1 ) ) // gives e.g. 14
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetLengthI( "knud" ) ) // gives 4
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetLengthI( "the" ) ) // gives 3
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Length( s ) )
 //
END

// library: math: number: compare: number1 GREATER THAN zero? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmagz.s) [<Program>] [<Research>] [kn, ri, mo, 09-07-2001 14:32:51]
INTEGER PROC FNMathCheckNumberGreaterZeroB( INTEGER x )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberGreaterZeroB( 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheck_NumberDifferenceGreaterB( x, 0 ) )
 //
END

// library: string: get: in: string <description>create concatenated duplicates of a certain string (STRING$ in BBCBASIC)</description> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=getstist.s) [<Program>] [<Research>] [kn, zoe, th, 20-05-1999 11:25:55]
STRING PROC FNStringGetInStringS( INTEGER maxI, STRING inS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "3" // change this
 // e.g.  STRING s2[255] = "a" // change this
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: totalT = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: string = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetInStringS( Val( s1 ), s2 ) ) // gives "aaa"
 // e.g.  Warn( FNStringGetInStringS( 15, "0" ) ) // gives "000000000000000"
 // e.g.  Warn( FNStringGetInStringS( 3, " " ) ) // gives "   "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 1
 //
 INTEGER I = 0
 //
 STRING s[255] = ""
 //
 IF ( maxI <= 0 )
  //
  RETURN( "" )
  //
 ENDIF // minimum 1 character width block or more to insert
 //
 FOR I = minI TO maxI
  //
  s = Format( s, inS )
  //
 ENDFOR
 //
 RETURN( s )
 //
END

// library: string: get: initialization: global <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstigl.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:44:33]
STRING PROC FNStringGetInitializationGlobalS( STRING searchS, STRING sectionS, STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetInitializationGlobalS( "path4dos", "default", FNStringGetFilenameIniDefaultS() ) ) // e.g. gives "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetProfileStr( sectionS, searchS, FNStringGetEmptyS(), fileNameS ) )
 //
END

// library: string: get: section: separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstssh.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:43:21]
STRING PROC FNStringGetSectionSeparatorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSectionSeparatorS() ) // gives e.g. "default"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "default" ) // you can not put this in the initialization file, because this actually determines the default section of that file itself. Possibly pass it as a command line parameter
 //
END

// library: string: get: filename: ini: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=getstcpm.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:15:56]
STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
 // e.g. PROC Main()
 // e.g. STRING s[255] = ""
 // e.g.  s = FNStringGetFilenameIniDefaultCrossPlatformS() // gives e.g. "c:\documents and settings\administrator\application data\dddpath.ini"
 // e.g.  IF NOT EditFile( QuotePath( s ) )
 // e.g.   Warn( "could not open the file", ":", " ", s, ".", " ", "Please check." )
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "c:\dddpath.ini" )
 //
 STRING fileNameS[255] = ""
 //
 IF FNProgramGetOperatingSystemLinuxNonWslB()
  //
  // You will have to hard code the username(s) (or put it in a global variable SetGlobalStr() as the first lines in the start programs. Otherwise it calls itself recursively while searching) [kn, ri, sa, 18-10-2025 20:11:39]
  // fileNameS = Format( "/home/", FNStringGetUserNameLinuxNonWslS(), "/c/users/", FNStringGetUserNameMicrosoftWindowsS(), "/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  fileNameS = Format( "/home/knudvaneeden/c/users/knud_/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  //
 ELSEIF FNProgramGetOperatingSystemLinuxWslB()
  //
  // You will have to hard code the username(s) (or put it in a global variable SetGlobalStr() as the first lines in the start programs. Otherwise it calls itself recursively while searching) [kn, ri, sa, 18-10-2025 20:11:39]
  // fileNameS = Format( "/mnt/c/users/", userNameMicrosoftWindowsGS, "/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  fileNameS = Format( "/mnt/c/users/knud_/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  //
 ELSEIF FNProgramGetOperatingSystemMicrosoftWindowsB()
  //
  fileNameS = FNStringGetConcatS( FNStringGetPathUser_DataApplicationCurrentBackslashS(), FNStringGet_FilenameIniDefaultS() )
  //
 ELSE
  //
  Warn( "Unknown operating system. Please check." )
  //
 ENDIF
 //
 RETURN( fileNameS )
 //
END

// library: string: get: address: ip: ipconfig: capture: central <author>Carlo Hogeveen</author> <description></description> <version>1.0.0.0.41</version> <version control></version control> (filenamemacro=getsticd.s) [<Program>] [<Research>] [kn, am, mo, 28-02-2011 15:50:22]
STRING PROC FNStringGetAddressMacIpconfigCaptureCentralS( STRING fileNameExeS, STRING fileNameExeParameterS, STRING networkAdapterNameS, STRING searchS, INTEGER searchTagI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAddressMacIpconfigCaptureCentralS( "c:\windows\system32\ipconfig.exe", "/all", "Ethernet adapter Local Area Connection", FNStringGetAddressMacSearchIpconfigCaptureS(), 1 ) ) // gives e.g. ""34-35-43-44-32-00"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetErrorS()
 //
 STRING filenameTempS[255] = MakeTempName( "." )
 //
 PushPosition()
 //
 // Dos( Format( "ipconfig", " ", ">", filenameTempS ), _DONT_PROMPT_ | _DONT_CLEAR_ | _START_HIDDEN_ )
 Dos( Format( QuotePath( fileNameExeS ), " ", fileNameExeParameterS, " ", ">", filenameTempS ), _DONT_PROMPT_ | _DONT_CLEAR_ | _START_HIDDEN_ ) // using only 'macconfig' did not always work when PATH was lost and put back partially. So supplying the full path to macconfig.exe instead [kn, am, mo, 02-07-2012 10:11:47]
 //
 IF ( EditFile( QuotePath( filenameTempS ), _DONT_PROMPT_ ) )
  //
  iF LFind( networkAdapterNameS, "gi" )
   //
   IF ( LFind( searchS, 'ix' ) )
    //
    s = GetFoundText( searchTagI )
    //
   ENDIF
   //
  ENDIF
  //
  IF s == "0.0.0.0" // if your fixed network adapter was not active, it will find this address
   //
   IF LFind( "wireless", "gi" ) // if no IP address found, then alternatively assume your wireless network adapter is active, so try that instead
    //
    IF ( LFind( searchS, 'ix' ) )
     //
     s = GetFoundText( searchTagI )
    //
    ENDIF
    //
   ENDIF
   //
  ENDIF
 //
 ENDIF
 //
 EraseDiskFile( filenameTempS )
 //
 IF ( EditFile( filenameTempS ) )
  AbandonFile()
 ENDIF
 //
 PopPosition()
 //
 s = Trim( s )
 //
 RETURN( s )
 //
END

// library: string: get: network: ipaddress: ethernet: name <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstena.s) [<Program>] [<Research>] [kn, ri, fr, 09-11-2018 10:46:51]
STRING PROC FNStringGetNetworkIpaddressEthernetNameS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetNetworkIpaddressEthernetNameS() ) // gives e.g. "Ethernet adapter Ethernet"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetNetworkIpaddressEthernetNameS" )  )
 //
END

// library: string: get: address: ip: search: ipconfig: capture <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getsticc.s) [<Program>] [<Research>] [kn, ri, sa, 19-03-2011 16:21:10]
STRING PROC FNStringGetAddressIpSearchIpconfigCaptureS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAddressIpSearchIpconfigCaptureS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "IP{v4}?[ ]+Address.*{[0-9]#\.[0-9]#\.[0-9]#\.[0-9]#}" )
 //
END

// library: math: check: logic: or: 2 arguments <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalo.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:17]
INTEGER PROC FNMathCheckLogicOrB( INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "math: check: logic: or: number1 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "math: check: logic: or: number2 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicOrB( FNStringGetToIntegerI( s1 ), FNStringGetToIntegerI( s2 ) ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( B1 )
  //
  RETURN( FNMathCheckGetLogicTrueB() )
  //
 ENDIF
 //
 IF ( B2 )
  //
  RETURN( FNMathCheckGetLogicTrueB() )
  //
 ENDIF
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: error: check <description>error: test if an error occurred, via testing the output // version with testing local variable. Better.</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checercs.s) [<Program>] [<Research>] [[kn, ni, we, 05-08-1998 20:27:34]
INTEGER PROC FNErrorCheckSB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNErrorCheckSB( "this is an error" ) ) // version with testing local variable. Better. ) // gives TRUE or FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetErrorS() ) )
 //
END

// library: warn <description>error: warning: give a warning message</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=wawarn.s)  [<Program>] [<Research>] [kn, zoe, we, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCWarn( "you have forgotten to input a value" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new [kn, ri, fr, 22-05-2020 20:12:39]
 Warn( s )
 //
END

// library: file: edit: edit a file, with test of problems <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checficf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:08:39]
INTEGER PROC FNFileCheckEditMessageB( STRING filenameS )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckEditMessageB( "" ) ) // gives e.g. TRUE when file loaded without problems
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNFileCheckEditCentralMessageB( filenameS, FNMathCheckGetLogicTrueB() ) )
 //
END

// library: file: movement: end: goto end of file: moves to the end of the last line of current file <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotofien.s) [<Program>] [<Research>] [kn, ri, su, 28-03-1999 01:08:06]
PROC PROCFileGotoEnd()
 // e.g. PROC Main()
 // e.g.  PROCFileGotoEnd()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNFileCheckGotoEndB() )
  //
  // PROCWarn( "cursor was already in end file else error: could no go to end of file" )
  //
 ENDIF
 //
END

// library: file: insert: end: prepare <description>file: insert: prepare for the insertion (e.g. of text, of a new file, ...)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=insefiep.s) [<Program>] [<Research>] [[kn, zoe, th, 25-01-2001 18:03:46]
PROC PROCFileInsertEndPrepare()
 // e.g. PROC Main()
 // e.g.  PROCFileInsertEndPrepare()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCFileGotoEnd()
 //
 PROCLineInsertAfter()
 //
 PROCTextGotoLineBegin()
 //
END

// library: string: get: global <description>string: global: get: get a global string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstggl.s) [<Program>] [<Research>] [[kn, zoe, mo, 14-06-1999 20:54:18]
STRING PROC FNStringGetGlobalS( STRING stringglobalnameS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetGlobalS( "dirGS" ) ) // e.g. gives "c:\"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetGlobalS( "dir1GS" ) ) // indicates first that this string does not exist, and returns the result '<VARIABLE NOT KNOWN>'.
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 IF FNMathCheckLogicNotB( ExistGlobalVar( stringglobalnameS ) )
  //
  PROCWarnCons5( "file", FNStringGetFilenameCurrentS(), ":", stringglobalnameS, ": this string is not known to this macro (suggestion: execute 'initglobal.mac' (or 'i.m') for this macro)" )
  //
  RETURN( FNStringGetErrorS() )
  //
 ENDIF
 //
 s = GetGlobalStr( stringglobalnameS )
 //
 RETURN( s )
 //
END

// library: string: get: character: symbol: central <description>string: get: character: symbol: central</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstscm.s) [<Program>] [<Research>] [[kn, ri, sa, 07-07-2001 22:35:39]
STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolCentralS( I ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetAsciiToCharacterS( I ) )
 //
END

// library: math: number: compare: number1 GREATER THAN number2? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmang.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 12:50:03]
INTEGER PROC FNMathCheck_NumberDifferenceGreaterB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheck_NumberDifferenceGreaterB( 3, 2 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( x1 > x2 )
 //
END

// library: program: get: operating: system: linux: non: wsl <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprnws.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:38:29]
INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramGetOperatingSystemLinuxNonWslB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemLinuxNonWslB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemLinuxNonWslB
 // e.g.  title = "FNProgramGetOperatingSystemLinuxNonWslB() help" // The help's caption
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
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Linux non-WSL" )
 //
 RETURN( B )
 //
END

// library: string: get: filename: ini: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstide.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 22:54:12]
STRING PROC FNStringGet_FilenameIniDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGet_FilenameIniDefaultS() ) // gives e.g. "dddpath.ini"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "dddpath.ini" ) // you can not put this in the global initialization file, because this actually determines the name of that file itself. You could overrule this by passing the filename as a parameter on the command line. (if ( parameter is empty ) then ( defaultfilename = dddpath.ini ), else ( defaultfilename = <that command line parameter> ) )
 //
END

// library: program: get: operating: system: linux: wsl <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprlws.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:38:43]
INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
 // e.g. PROC Main() //
 // e.g.  Message( FNProgramGetOperatingSystemLinuxWslB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemLinuxWslB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemLinuxWslB
 // e.g.  title = "FNProgramGetOperatingSystemLinuxWslB() help" // The help's caption
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
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Linux WSL" )
 //
 RETURN( B )
 //
END

// library: program: get: operating: system: microsoft: windows <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprmwi.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:30:02]
INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramGetOperatingSystemMicrosoftWindowsB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemMicrosoftWindowsB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemMicrosoftWindowsB
 // e.g.  title = "FNProgramGetOperatingSystemMicrosoftWindowsB() help" // The help's caption
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
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Microsoft Windows NT" ) OR EquiStr( s, "Microsoft Windows non-NT" )
 //
 RETURN( B )
 //
END

// library: string: get: path: user: data: application: current: backslash <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstcbe.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 23:01:06]
STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPathUser_DataApplicationCurrentBackslashS() ) // gives e.g. "c:\documents and settings\administrator\application data\" (this is a hidden directory)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFilenameEndBackSlashNotEqualInsertEndS( FNStringGetPathUser_DataApplicationCurrentBackslashNotS() ) )
 //
END

// library: math: check: get: logic: false: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:08]
INTEGER PROC FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicFalseB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FALSE )
 //
END

// library: file: check: edit: central: message <description></description> <version control></version control> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=checfiex.s) [<Program>] [<Research>] [kn, ho, mo, 17-04-2006 17:41:21]
INTEGER PROC FNFileCheckEditCentralMessageB( STRING filenameS, INTEGER messageB )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckEditCentralMessageB( "test.dok", FNMathCheckGetLogicFalseB() ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER editfileB = FNMathCheckGetLogicFalseB()
 //
 STRING s[255] = ""
 //
 // here the file is loaded in TSE menu "&Load..." [kn, ri, fr, 10-02-2023 01:59:37]
 //
 if FNStringCheckEmptyB( filenameS )
  //
  PushKey( <ALT Del> ) // delete to end of line // added [kn, ri, fr, 10-02-2023 02:07:49]
  PushKey( <Home> ) // goto beginning of the box // added [kn, ri, fr, 10-02-2023 02:07:49]
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  editfileB = EditFile()
  //
 ELSE
  //
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  editfileB = EditFile( filenameS )
  //
 ENDIF
 //
 IF FNMathCheckLogicNotB( editfileB )
  //
  IF messageB
   //
   PROCErrorFileNotFound( filenameS )
   //
  ENDIF
  //
 ENDIF
 //
 s = CurrFileName()
 //
 IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
  //
  PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "TSE%3A+File%3A+Load%3A+" + s + "&submit01=Create" ) )
  //
 ENDIF
 //
 RETURN( editfileB )
 //
END

// library: file: check: goto: end <description>file: movement: end: goto end of file: moves to the end of the last line of current file</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checfigs.s) [<Program>] [<Research>] [[kn, ri, su, 28-03-1999 01:08:06]
INTEGER PROC FNFileCheckGotoEndB()
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckGotoEndB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( EndFile() )
 //
END

// library: line: insert: inserts 1 line after current line. The cursor is placed on the newly created line. The cursor column does not change <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=inseliaf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:35:30]
PROC PROCLineInsertAfter()
 // e.g. PROC Main()
 // e.g.  PROCLineInsertAfter()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCLineInsertAfterLineGotoBeginTextInsert( FNStringGetEmptyS() )
 //
END

// library: text: goto: line: begin // goto begin of line (=column 1 of the current line). If the cursor is already at the beginning of the current line, zero is returned. See also: EndLine() <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotolibe.s) [<Program>] [<Research>] [kn, zoe, th, 17-06-1999 00:12:52]
PROC PROCTextGotoLineBegin()
 // e.g. PROC Main()
 // e.g.  PROCTextGotoLineBegin()
 // e.g. END
 //
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNLineCheckGotoBeginB() )
  //
  // PROCWarn( "Could not go to the beginning of the current line" )
  //
 ENDIF
 //
END

// library: warn: cons5 <description>error: warning: give a warning message via 5 strings</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=conswawf.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:57:23]
PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
  // e.g. PROC Main()
 // e.g.  PROCWarnCons5( "error", "1", "2", "3", "4" ) // gives e.g. "error 1 2 3 4"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons5S( s1, s2, s3, s4, s5 ) )
 //
END

// library: string: get: ascii: to: character (given the ASCII value, what is the corresponding character? (Get Single Character Equivalent of an Integer). Syntax: Chr(INTEGER i)*) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttch.s)  [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:51]
STRING PROC FNStringGetAsciiToCharacterS( INTEGER asciiI )
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 65 ) ) // gives "A"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 66 ) ) // gives "B"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 100 ) ) // gives "d"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Chr( asciiI ) ) // leave this keyword, otherwise possibly recursive stack overflow
 //
END

// library: string: get: operating: system <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstosy.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:26:13]
STRING PROC FNStringGetOperatingSystemS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetOperatingSystemS() ) // gives e.g. "Microsoft Windows"
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
 // e.g. // QuickHelp( HELPDEFFNStringGetOperatingSystemS )
 // e.g. HELPDEF HELPDEFFNStringGetOperatingSystemS
 // e.g.  title = "FNStringGetOperatingSystemS() help" // The help's caption
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
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetOperatingSystemS() ) // gives e.g. ...""
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
 // e.g. // QuickHelp( HELPDEFFNStringGetOperatingSystemS )
 // e.g. HELPDEF HELPDEFFNStringGetOperatingSystemS
 // e.g.  title = "FNStringGetOperatingSystemS() help" // The help's caption
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
 // create a temporary filename in the current directory
 STRING fileNameS[255] = QuotePath( MakeTempName( ".", ".TMP" ) )
 //
 INTEGER linuxWslB = FALSE
 //
 STRING s[255] = ""
 //
 PushPosition()
 PushBlock()
 //
 IF ( WhichOS() == _LINUX_ )
  //
  PushPosition()
  PushBlock()
  //
  Dos( Format( "cat /proc/version", " ", ">", " ", fileNameS ), _DONT_PROMPT_ )
  //
  EditFile( fileNameS )
  //
  linuxWslB = LFind( "microsoft", "gi" )
  //
  IF linuxWslB
   //
   s = "Linux WSL"
   //
  ELSE
   //
   s = "Linux non-WSL"
   //
  ENDIF
  //
 ELSEIF ( WhichOS() == _WINDOWS_ )
  //
  s = "Microsoft Windows non-NT"
  //
 ELSEIF ( WhichOS() == _WINDOWS_NT_ )
  //
  s = "Microsoft Windows NT"
  //
 ELSE
  //
  Warn( "Unknown operating system. Please check." )
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 IF EditFile( fileNameS )
  //
  AbandonFile()
  //
 ENDIF
 //
 EraseDiskFile( fileNameS )
 //
 PopBlock()
 PopPosition()
 //
 RETURN( s )
 //
END

// library: string: get: filename: end: back: slash: not: equal: insert: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstiep.s) [<Program>] [<Research>] [kn, ni, su, 17-08-2003 00:24:04]
STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameEndBackSlashNotEqualInsertEndS( 'c:\temp\ddd' ) ) // gives e.g. a string 'c:\temp\ddd\' (so with always a string with a backslash '\' at the end)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterEndBackSlashNotEqualInsertEndS( s ) )
 //
END

// library: string: get: path: user: data: application: current <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstacu.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 22:50:55]
STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPathUser_DataApplicationCurrentBackslashNotS() ) // gives e.g. "c:\documents and settings\administrator\application data" (this is a hidden directory)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetEnvironmentS( "APPDATA" )
 //
 IF FNStringCheckEnvironmentFoundNotB( s )
  //
  PROCWarnCons3( "current user path to application data", s, ": not found" )
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 RETURN( s )
 //
END

// library: error: file: not: found <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=fileernf.s) [<Program>] [<Research>] [kn, ri, we, 28-02-2001 23:02:12]
PROC PROCErrorFileNotFound( STRING filenameS )
 // e.g. PROC Main()
 // e.g.  PROCErrorFileNotFound( "xsefadafadfasdf.sdfa" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 IF FNErrorCheckEscapeB( filenameS )
  //
  s = FNStringGetConsS( FNStringGetEscapeS(), "has been pressed" )
  //
 ELSE
  //
  s = FNStringGetCons3S( "file: ", filenameS, "not found / path does not exist" )
  //
 ENDIF
 //
 PROCError( s )
 //
END

// library: macro: run: purge: parameter <description>macro: run a macro, then purge it, pass parameter string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmappa.s) [<Program>] [<Research>] [[kn, ri, sa, 17-02-2001 02:22:27]
PROC PROCMacroRunPurgeParameter( STRING macronameS, STRING commandlineparameterS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunPurgeParameter( macronameS, commandlineparameterS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunPurge( FNStringGetConsS( macronameS, commandlineparameterS ) )
 //
END

// library: string: get: machine: name <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstmnc.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:41:10]
STRING PROC FNStringGetMachineNameS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMachineNameS() ) // gives e.g. "mcnlken01" or "localhost"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetMachineNameS" ) )
 //
END

// library: string: get: user: name: first <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstnfi.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:40:16]
STRING PROC FNStringGetUserNameFirstS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetUserNameFirstS() ) // gives e.g. "knud"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetUserNameFirstS" ) )
 //
END

// library: string: get: user: name: last <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstnla.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:40:40]
STRING PROC FNStringGetUserNameLastS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetUserNameLastS() ) // gives e.g. "van eeden"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetUserNameLastS" ) )
 //
END

// library: string: get: port: name <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstpnc.s) [<Program>] [<Research>] [kn, ri, sa, 24-07-2010 21:52:33]
STRING PROC FNStringGetPortS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPortS() ) // gives e.g. "80"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetPortS" ) )
 //
END

// library: line: insert: after: line: goto: begin: text: insert <description>line insert after: insert text at first column (text: insert: after each other)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=inselitj.s) [<Program>] [<Research>] [[kn, zoe, we, 28-02-2001 20:24:53]
PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCLineInsertAfterLineGotoBeginTextInsert( s )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: PROCLineInsertAfter() PROCLineGotoBeginTextInsert( s )
 //
 IF FNMathCheckLogicNotB( FNLineCheckInsertAfterLineGotoBeginTextInsertB( s ) )
  //
  // PROCWarn( "line could not be inserted" )
  //
 ENDIF
 //
END

// library: line: check: goto: begin <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checligb.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:36:31]
INTEGER PROC FNLineCheckGotoBeginB()
 // e.g. //
 // e.g. // version not central
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( "Goto the beginning of the line = ", FNLineCheckGotoBeginB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( BegLine() )
 //
END

// library: string: get: backslash: if last character is not equal to '\', then concatenate a backslash to the end of the given string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstien.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:48:15]
STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: backslash: if: not equal insert end: string = ", "this is a string without a backslash at end" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCharacterEndBackSlashNotEqualInsertEndS( s1 ) ) // gives e.g. "this is a string with a backslash at end\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterInsertEndIfEqualNotS( s, FNStringGetCharacterSymbolSlashBackwardS() ) )
 //
END

// library: environment: string: get (Searches for and Returns a Specified Environment Str) R    GetEnvStr(STRING s)* <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstgen.s) [<Program>] [<Research>] [kn, ri, th, 25-10-2001 01:44:48]
STRING PROC FNStringGetEnvironmentS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInputS( "value: environment variable = ", "windir" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  PROCMessageCons3( s, "=", FNStringGetEnvironmentS( s ) ) // gives e.g. "windir=C:\WINNT", when working on a Windows2000 machine
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING valueS[255] = GetEnvStr( s )
 //
 IF FNStringCheckEmptyB( valueS )
  //
  // PROCMessageCons3( "environment variable", s, ": not found" ) // old [kn, vo, fr, 08-02-2013 10:14:48]
  //
  valueS = FNStringGetErrorS()
  //
 ENDIF
 //
 RETURN( valueS )
 //
END

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEnvironmentFoundNotB( FNStringGetEmptyS() ) ) // gives TRUE (thus not found) because string empty (or string error string)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualErrorOrEmptyB( s ) )
 //
END

// library: error: check: escape <description>escape or error</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checerce.s) [<Program>] [<Research>] [[kn, zoe, th, 09-11-2000 23:18:32]
INTEGER PROC FNErrorCheckEscapeB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNErrorCheckEscapeB( "<ESCAPE>" ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNErrorCheckSB( s ) RETURN( FNMathCheckGetLogicTrueB() ) ENDIF
 //
 IF FNKeyCheckPressEscapeB( s ) RETURN( FNMathCheckGetLogicTrueB() ) ENDIF
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: string: get: escape <description>general output string to recognize an escape (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.3</version> (filenamemacro=getstges.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 18:52:24]
STRING PROC FNStringGetEscapeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEscapeS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "<ESCAPE>" )
 //
END

// library: macro: run: purge <description>macro: run a macro, then purge it (this text goes into the main macro file)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmarpu.s) [<Program>] [<Research>] [[kn, zoe, tu, 27-10-1998 18:54:17]
PROC PROCMacroRunPurge( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunPurge( "mysubma1.mac myparameter11 myparameter12" )
 // e.g.  PROCMacroRunPurge( "mysubma2.mac myparameter21" )
 // e.g.  PROCMacroRunPurge( "mysubma3.mac myparameter31 myparameter32" )
 // e.g. END
 //
 IF FNStringCheckEmptyB( macronameS )
  //
  PROCError( "macro should not be empty" )
  //
  RETURN()
  //
 ENDIF
 //
 IF FNMacroCheckLoadB( FNStringGetCarS( macronameS ) ) // necessary if you pass parameters in a string
  //
  PROCMacroExec( macronameS )
  //
  PROCMacroPurge( FNStringGetCarS( macronameS ) )
  //
 ENDIF
 //
 // PROCFileInsertStringEndFilenameDefault( macronameS ) // if you want to count the frequency a certain macro has been called
 //
END

// library: line insert after: insert text at first column <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=inseliti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNLineCheckInsertAfterLineGotoBeginTextInsertB( s1 ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( AddLine( s ) )
 //
 RETURN( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s, FNBufferGetBufferIdFileCurrentI() ) )
 //
END

// library: compare if string end is equal, if not so insert that string at the end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstenp.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:06:33]
STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING inS, STRING tailS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: insert: insert: string = ", "c:\kee" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: insert: insert: frontS = ", "\" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( s1, s2 ) ) // gives e.g. "c:\kee\"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c", ":" ) ) // gives "c:"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c:", ":" ) ) // gives "c:"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c:\kee", FNStringGetCharacterSymbolSlashBackwardS() ) ) // gives "c:\kee\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 IF FNMathCheckLogicNotB( FNStringCheckEqualCharacterLastNB( s, tailS ) )
  //
  // s = FNStringGetConcatS( s, tailS )
  //
  s = FNStringGetConcatTailS( s, tailS )
  //
 ENDIF
 //
 RETURN( s )
 //
END

// library: string: get: character: symbol: "\" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstsba.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:41:11]
STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolSlashBackwardS() ) // gives "\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 92 ) )
 //
END

// library: key: check: press: escape <description>input: escape: test if escape was pressed</description> <version>1.0.0.0.4</version> (filenamemacro=checkepe.s) [<Program>] [<Research>] [kn, ni, we, 05-08-1998 20:29:00]
INTEGER PROC FNKeyCheckPressEscapeB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNKeyCheckPressEscapeB( "" ) ) // version with testing local variable ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEscapeS() ) )
 //
END

// library: macro: purge <description>macro: (Purges a Macro File From Memory) R    PurgeMacro(STRING s)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=purgmamp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:09:32]
PROC PROCMacroPurge( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroPurge( macronameS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNMacroCheckPurgeB( macronameS ) )
  //
  PROCWarnCons3( "macro", macronameS, ": could not be found" )
  //
 ENDIF
 //
END

// library: file: check: insert: line: after: line: goto: begin: text: insert: line insert after: insert text at first column (Add Line After Current Line). Syntax: AddLine( <STRING text <, INTEGER bufferid > > ). If the optional bufferid is specified, the line is added after the current line in the specified buffer. _ON_CHANGING_FILES_ hooks are not invoked by this command <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checfiti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s, INTEGER bufferid )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "line insert after: insert text at first column: bufferID = ", FNStringGetMathIntegerToStringS( FNBufferGetBufferIdFileCurrentI() ) )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s1, FNStringGetToIntegerI( s2 ) ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( AddLine( s, bufferid ) ) // s is the string that will be inserted at column 1 of the newly created line. BufferidI is the optional id of the file where the line is to be added. If not passed, the line is added to the current file.
 //
END

// library: buffer: get: id: current ((Returns the Unique Id of Requested or Current Buffer) O GetBufferId([<Program>] [<Research>] [STRING name])*) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getbuicu.s) [kn, zoe, th, 25-01-2001 11:12:56]
INTEGER PROC FNBufferGetBufferIdFileCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNBufferGetBufferIdFileCurrentI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNBufferGetBufferIdGivenBufferNameI( FNStringGetFilenameCurrentS() ) )
 //
END

// library: string: word: equal: last: compare if a given string is equal at the end to another given string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checstln.s) [<Program>] [<Research>] [kn, zoe, we, 29-11-2000 19:08:34]
INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s, STRING tailS )
 // e.g. //
 // e.g. // version: first parameter s then endS
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEqualCharacterLastNB( "knud", "d" ) ) //  gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( FNStringGetRightStringLengthEqualS( s, tailS ), tailS ) )
 //
END

// library: string: get: concat: tail: suffix <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstctb.s) [<Program>] [<Research>] [kn, ri, su, 02-09-2001 03:08:08]
STRING PROC FNStringGetConcatTailS( STRING s, STRING tailS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatTailS( "Knu", "d" ) ) // gives e.g. "Knud"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( s, tailS ) )
 //
END

// library: macro: check: purge <description>macro: purge</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:03:50]
INTEGER PROC FNMacroCheckPurgeB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckPurgeB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( PurgeMacro( macronameS ) )
 //
END

// library: buffer: get: buffer: id: given: buffer: name (Returns the Unique Id of Requested or Current Buffer) O GetBufferId([<Program>] [<Research>] [STRING name])*  <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getbubna.s) [kn, zoe, th, 25-01-2001 11:12:23]
INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING bufferNameS )
 // e.g. PROC Main()
 // e.g.  Message( FNBufferGetBufferIdGivenBufferNameI( "test" ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetBufferId( bufferNameS ) )
 //
END

// library: STRING: get: right: string: length: equal <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstler.s) [<Program>] [<Research>] [kn, ni, su, 30-11-2003 23:32:40]
STRING PROC FNStringGetRightStringLengthEqualS( STRING s, STRING tailS
)
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRightStringLengthEqualS( "Knud van Eeden", "12345" ) ) // gives e.g. "Eeden"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( tailS ) ) )
 //
END

// library: string: get: word: token: last: return a given integer amount of characters from the right of a given string (=RIGHT$ in BASIC) <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=stririrs.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:05:49]
STRING PROC FNStringGetRightStringS( STRING s, INTEGER totalI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING charactertotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: word: token: get: right: string = ", "knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  charactertotalS = FNStringGetInputS( "string: word: token: get: right: character total = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( charactertotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetRightStringS( s, FNStringGetToIntegerI( charactertotalS ) ) ) //  gives e.g. "kn"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "knud", 1 ) ) // gives "d"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "knud", 2 ) ) // gives "ud"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "best", 3 ) ) // gives "est"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER lengthI = FNStringGetLengthI( s )
 //
 IF FNMathCheckLogicNotB( ( ( 0 <= totalI ) AND ( totalI <= lengthI ) ) ) // if not between 0 and length( string ), return the whole given string
  //
  totalI = lengthI
  //
 ENDIF
 //
 RETURN( FNStringGetMidStringS( s, 1 + lengthI - totalI, lengthI ) )
 //
END
