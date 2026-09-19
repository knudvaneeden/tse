/*
   lowlevel.inc
   TSE SAL interface to lowlevel.dll for Microsoft Windows.

   Version : 1.0.0.0.5
   Date    : 2026-09-19 23:36 CEST
   LLM     : GPT-5.6 Sol
*/

dll "lowlevel.dll"
    integer proc PASCAL _open(string path : cstrval) : "LOWOPEN"
    integer proc PASCAL _seek(integer handle, integer offset, integer method) : "LOWSEEK"
    integer proc PASCAL _read(integer handle, var string buffer, integer bytes) : "LOWREAD"
    integer proc PASCAL _close(integer handle) : "LOWCLOSE"
end

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
