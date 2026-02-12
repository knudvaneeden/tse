/*
  Macro           Test_CompareLines
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE Beta v4.41.42 (21 Aug 2020) upwards
                  According to a hint in the read.me.beta file.
  Tested with     TSE Beta v4.41.46
  Version         1   28 Dec 2021

  This test macro demonstrates that CompareLines() has three formats:

    Format 1:   integer CompareLines(integer line_nr_1,
                                     integer line_nr_2)

    Format 2:   integer CompareLines(integer line_nr_1,
                                     integer line_nr_2,
                                     integer case_insensitive)

    Format 3:   integer CompareLines(integer line_nr_1,
                                     integer line_nr_2,
                                     integer case_insensitive,
                                     integer buffer_id_1,
                                     integer buffer_id_2)

  All formats return an integer result with one of these three values:
    -1  line_nr_1's content "is smaller than" line_nr_2's content.
     0  line_nr_1's content "is equal to"     line_nr_2's content.
     1  line_nr_1's content "is greater than" line_nr_2's content.

  Format 1 compares case-sensitively.

  In formats 2 and 3, if the case_insensitive parameter is TRUE or FALSE,
  then line_nr_1's content and line_nr_2's content are compared
  case-insensitively or case-sensitively respectively.

  Note that case-sensitively means, that "A" < "a" and "z" > "A".

  Format 1 and format 2 work on lines in the current buffer.

  In format 3 the content from line_nr_1 from buffer_id_1 is compared to the
  content from line_nr_2 from buffer_id_2.

  Format 1 does the same as
  format 2 with case_insensitive = FALSE.

  Format 2 does the same as
  format 3 with buffer_id_1 = GetBufferId() and buffer_id_2 = GetBufferId().

*/

integer log_id = 0

proc compare_lines_5(integer buf1_line,
                     integer buf2_line,
                     integer case_insensitive,
                     integer buf1_id,
                     integer buf2_id)
  integer result            = 0
  string  s1 [MAXSTRINGLEN] = ''
  string  s2 [MAXSTRINGLEN] = ''
  PushLocation()
  GotoBufferId(buf1_id)
  GotoLine(buf1_line)
  s1 = GetText(1, MAXSTRINGLEN)
  BegFile()
  GotoBufferId(buf2_id)
  GotoLine(buf2_line)
  s2 = GetText(1, MAXSTRINGLEN)
  BegFile()
  PopLocation()

  result = CompareLines(buf1_line,
                        buf2_line,
                        case_insensitive,
                        buf1_id,
                        buf2_id)

  AddLine(Format(s1; '?'; s2; '  Result ='; result:2;
                 iif(result < 0, '(<)', iif(result, '(>)', '(=)'));
                 '  case_insensitive ='; case_insensitive;
                 iif(case_insensitive, '(TRUE)', '(FALSE)')),
          log_id)
end compare_lines_5

proc compare_lines_3(integer line1,
                     integer line2,
                     integer case_insensitive)
  integer result            = 0
  string  s1 [MAXSTRINGLEN] = ''
  string  s2 [MAXSTRINGLEN] = ''

  if FALSE
    compare_lines_5(line1,
                    line2,
                    case_insensitive,
                    GetBufferId(),
                    GetBufferId())
  else
    PushLocation()
    GotoLine(line1)
    s1 = GetText(1, MAXSTRINGLEN)
    GotoLine(line2)
    s2 = GetText(1, MAXSTRINGLEN)
    PopLocation()

    result = CompareLines(line1,
                          line2,
                          case_insensitive)

    AddLine(Format(s1; '?'; s2; '  Result ='; result:2;
                   iif(result < 0, '(<)', iif(result, '(>)', '(=)'));
                   '  case_insensitive ='; case_insensitive;
                   iif(case_insensitive, '(TRUE)', '(FALSE)')),
            log_id)
  endif
end compare_lines_3

proc compare_lines_2(integer line1,
                     integer line2)
  integer result            = 0
  string  s1 [MAXSTRINGLEN] = ''
  string  s2 [MAXSTRINGLEN] = ''

  PushLocation()
  GotoLine(line1)
  s1 = GetText(1, MAXSTRINGLEN)
  GotoLine(line2)
  s2 = GetText(1, MAXSTRINGLEN)
  PopLocation()

  result = CompareLines(line1,
                        line2)

  AddLine(Format(s1; '?'; s2; '  Result ='; result:2;
                 iif(result < 0, '(<)', iif(result, '(>)', '(=)'))),
          log_id)
end compare_lines_2

proc Main()
  integer case_insensitive = FALSE
  integer id1              = 0
  integer id2              = 0

  log_id = NewFile()
  AddLine('')

  PushLocation()
  id1 = CreateTempBuffer()
  id2 = CreateTempBuffer()
  AddLine('a', id1)
  AddLine('b', id1)
  AddLine('b', id2)
  AddLine('a', id2)
  PopLocation()

  AddLine('Comparing two files case-sensitively:', log_id)

  compare_lines_5(1, 1, case_insensitive, id1, id2)
  compare_lines_5(2, 2, case_insensitive, id1, id2)
  compare_lines_5(1, 2, case_insensitive, id1, id2)
  compare_lines_5(2, 1, case_insensitive, id1, id2)

  compare_lines_5(1, 1, case_insensitive, id2, id1)
  compare_lines_5(2, 2, case_insensitive, id2, id1)
  compare_lines_5(1, 2, case_insensitive, id2, id1)
  compare_lines_5(2, 1, case_insensitive, id2, id1)

  PushLocation()
  GotoBufferId(id2)
  MarkLine(1, NumLines())
  Upper()
  UnMarkBlock()
  PopLocation()

  compare_lines_5(1, 1, case_insensitive, id1, id2)
  compare_lines_5(2, 2, case_insensitive, id1, id2)
  compare_lines_5(1, 2, case_insensitive, id1, id2)
  compare_lines_5(2, 1, case_insensitive, id1, id2)

  compare_lines_5(1, 1, case_insensitive, id2, id1)
  compare_lines_5(2, 2, case_insensitive, id2, id1)
  compare_lines_5(1, 2, case_insensitive, id2, id1)
  compare_lines_5(2, 1, case_insensitive, id2, id1)

  AddLine('', log_id)
  AddLine('Comparing two files case-insensitively:', log_id)
  case_insensitive = TRUE

  compare_lines_5(1, 1, case_insensitive, id1, id2)
  compare_lines_5(2, 2, case_insensitive, id1, id2)
  compare_lines_5(1, 2, case_insensitive, id1, id2)
  compare_lines_5(2, 1, case_insensitive, id1, id2)

  compare_lines_5(1, 1, case_insensitive, id2, id1)
  compare_lines_5(2, 2, case_insensitive, id2, id1)
  compare_lines_5(1, 2, case_insensitive, id2, id1)
  compare_lines_5(2, 1, case_insensitive, id2, id1)

  GotoBufferId(id2)
  EmptyBuffer()
  AddLine('a')
  AddLine('b')
  AddLine('A')
  AddLine('B')
  BegFile()

  AddLine('', log_id)
  AddLine('Comparing lines within one file case-sensitively:', log_id)
  case_insensitive = FALSE

  compare_lines_3(1, 1, case_insensitive)
  compare_lines_3(1, 2, case_insensitive)
  compare_lines_3(1, 3, case_insensitive)
  compare_lines_3(1, 4, case_insensitive)

  compare_lines_3(2, 1, case_insensitive)
  compare_lines_3(2, 2, case_insensitive)
  compare_lines_3(2, 3, case_insensitive)
  compare_lines_3(2, 4, case_insensitive)

  compare_lines_3(3, 1, case_insensitive)
  compare_lines_3(3, 2, case_insensitive)
  compare_lines_3(3, 3, case_insensitive)
  compare_lines_3(3, 4, case_insensitive)

  compare_lines_3(4, 1, case_insensitive)
  compare_lines_3(4, 2, case_insensitive)
  compare_lines_3(4, 3, case_insensitive)
  compare_lines_3(4, 4, case_insensitive)

  AddLine('', log_id)
  AddLine('Comparing lines within one file case-insensitively:', log_id)
  case_insensitive = TRUE

  compare_lines_3(1, 1, case_insensitive)
  compare_lines_3(1, 2, case_insensitive)
  compare_lines_3(1, 3, case_insensitive)
  compare_lines_3(1, 4, case_insensitive)

  compare_lines_3(2, 1, case_insensitive)
  compare_lines_3(2, 2, case_insensitive)
  compare_lines_3(2, 3, case_insensitive)
  compare_lines_3(2, 4, case_insensitive)

  compare_lines_3(3, 1, case_insensitive)
  compare_lines_3(3, 2, case_insensitive)
  compare_lines_3(3, 3, case_insensitive)
  compare_lines_3(3, 4, case_insensitive)

  compare_lines_3(4, 1, case_insensitive)
  compare_lines_3(4, 2, case_insensitive)
  compare_lines_3(4, 3, case_insensitive)
  compare_lines_3(4, 4, case_insensitive)

  AddLine('', log_id)
  AddLine('Comparing lines within one file with default case-insensitivity',
          log_id)
  AddLine('after a case-sensitive call:', log_id)

  case_insensitive = FALSE
  compare_lines_3(1, 1, case_insensitive)

  compare_lines_2(1, 1)
  compare_lines_2(1, 2)
  compare_lines_2(1, 3)
  compare_lines_2(1, 4)

  compare_lines_2(2, 1)
  compare_lines_2(2, 2)
  compare_lines_2(2, 3)
  compare_lines_2(2, 4)

  compare_lines_2(3, 1)
  compare_lines_2(3, 2)
  compare_lines_2(3, 3)
  compare_lines_2(3, 4)

  compare_lines_2(4, 1)
  compare_lines_2(4, 2)
  compare_lines_2(4, 3)
  compare_lines_2(4, 4)

  AddLine('', log_id)
  AddLine('Comparing lines within one file with default case-insensitivity',
          log_id)
  AddLine('after a case-insensitive call:', log_id)

  case_insensitive = TRUE
  compare_lines_3(1, 1, case_insensitive)

  compare_lines_2(1, 1)
  compare_lines_2(1, 2)
  compare_lines_2(1, 3)
  compare_lines_2(1, 4)

  compare_lines_2(2, 1)
  compare_lines_2(2, 2)
  compare_lines_2(2, 3)
  compare_lines_2(2, 4)

  compare_lines_2(3, 1)
  compare_lines_2(3, 2)
  compare_lines_2(3, 3)
  compare_lines_2(3, 4)

  compare_lines_2(4, 1)
  compare_lines_2(4, 2)
  compare_lines_2(4, 3)
  compare_lines_2(4, 4)

  GotoBufferId(log_id)
  AddLine('')
  BegFile()

  AbandonFile(id1)
  AbandonFile(id2)
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

