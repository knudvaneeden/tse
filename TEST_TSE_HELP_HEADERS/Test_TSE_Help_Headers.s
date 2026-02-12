/*
  Tool            Test_TSE_Help_Headers
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE Pro v4.0 upwards
  Version         1   4 Mar 2022

  TSE maintains 4 system Help buffers.
  The buffer with id 7 is dedicated to Help headers.
  These "header topics" contain the topics and subtopics that TSE's Help shows,
  and more!
  Because the header topics are more numerous; what are the extra ones?
  As it turns out, mostly obsolete ones, as determined by a topic containing
  the word "obsolete".

  The tool also shows whether a header topic is (in) an indexed topic.
  This is only partly relevant.
  Not all menu-help is in an indexed topic, and there are some help topics
  that are not themselves indexed topics but are linked to from indexed topics.

*/

#define TSE_HELP_HEADERS_ID 7
#define TSE_HELP_CONTROL_ID 9

proc Main()
  string  header_topic          [MAXSTRINGLEN] = ''
  integer is_obsolete                          = FALSE
  integer log_id                               = NewFile()
  integer max_header_topic_len                 = 0
  integer my_headers_id                        = CreateTempBuffer()
  integer my_index_id                          = CreateTempBuffer()
  integer my_topic_id                          = CreateTempBuffer()
  integer odd_topics                           = 0
  integer old_MsgLevel                         = Query(MsgLevel)
  string  referenced_topic      [MAXSTRINGLEN] = ''
  integer is_in_indexed_topic    = FALSE

  // Get index. (And populate TSE Help buffers.)
  PushKey(<Escape>)
  PushKey(<Grey+>)
  Help('Index')

  GotoBufferId(my_index_id)
  Paste()
  UnMarkBlock()
  lReplace('()', '', 'gn$')

  GotoBufferId(TSE_HELP_HEADERS_ID)
  max_header_topic_len = LongestLineInBuffer() - 7
  MarkLine(1, NumLines())

  GotoBufferId(my_headers_id)
  CopyBlock()
  UnMarkBlock()
  BegFile()
  BufferVideo()
  repeat
    header_topic = GetText(8, MAXSTRINGLEN)
    if header_topic[1] <= ' '
      odd_topics = odd_topics + 1
      header_topic = header_topic[2: MAXSTRINGLEN]
    endif
    if Length(header_topic)
      PushKey(<Escape>)
      PushKey(<Grey+>)
      Help(header_topic)

      GotoBufferId(my_topic_id)
      EmptyBuffer()
      old_MsgLevel = Set(MsgLevel, _NONE_)
      Paste()
      Set(MsgLevel, old_MsgLevel)
      UnMarkBlock()
      referenced_topic = Trim(GetText(1, MAXSTRINGLEN))
      is_obsolete      = lFind('obsolete', 'giw')

      GotoBufferId(my_index_id)
      is_in_indexed_topic = lFind(referenced_topic, '^gi$')

      GotoBufferId(log_id)
      AddLine()
      BegLine()
      if is_in_indexed_topic
        InsertText('InIndexedTopic   ; ', _INSERT_)
      else
        InsertText('NotInIndexedTopic; ', _INSERT_)
      endif
      if is_obsolete
        InsertText('Obsolete; ', _INSERT_)
      else
        InsertText('Current ; ', _INSERT_)
      endif
      InsertText(Format(header_topic: max_header_topic_len * -1,
                        ';',
                        referenced_topic),
                 _INSERT_)

      GotoBufferId(my_headers_id)
      Message('Processing help headers   ', CurrLine() * 100 / NumLines(), ' %')
    endif
  until not Down()
  UnBufferVideo()

  GotoBufferId(log_id)
  BegFile()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  Warn('There were'; odd_topics; ' odd topics.')

  AbandonFile(my_headers_id)
  AbandonFile(my_topic_id)
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

<Grey+> Copy()

