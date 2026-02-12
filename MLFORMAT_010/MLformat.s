/*
   Macro          MLformat
   Author         Carlo.Hogeveen@xs4all.nl
   Date           9 November 2006
   Version        0.1
   Compatibility  TSE Pro 2.5e upwards

   Purpose
      To (re)format XML and HTML files.

      The first version aims at a simple proof of concept.

   Theory of this formatter:
      A markup language file consists of a hierarchic tree of nodes.
      There are four types of nodes:
         1.    Multi-line comments.
         2.    Opening tags with matching closing tags.
         3.    Tags that don't have a closing tag.
         4.    Values between tags.
      The plan of attack for the first version is simple:
         1.    Start reformatting the file from an indentation of 0.
         2.    The first line of a multi-line comment gets the current
               indentation.
               All other lines of a multi-line comment are indented so,
               that they retain their alignment to the first line.
               Inside a multi-line comment all other node types are ignored.
         3.    Type-2 thru type-4 nodes are reformatted so that each
               occurrence occupies a line (for now).
         4.    After each opening type-2 node, increase the indentation.
         5.    At each closing type-2 node, decrease the indentation.
      Notes:
         1.    The construction < ... /> is treated as a type-3 node.
         2.    Physical tabs are replaced by a single space.
         3.    After indentation: unquoted consecutive spaces are reduced to
               one space.
         4.    Lines, the length of which exactly matches TSE's maximum line
               length, are assumed to be broken lines which are continued on
               the next line.
         5.    There are already formatting choices to be made. How many
               spaces is one indent for example. For now those choices are
               implemented by global variables at the start of the macro:
               this can later be replaced by something user-friendlier.
         6.    The macro should be HTML-aware. It needs a table of tags which
               constitute type-2 nodes, other tags implicitly being type-3
               nodes.
*/

proc Main()
   Warn("This macro is not implemented yet.")
end

