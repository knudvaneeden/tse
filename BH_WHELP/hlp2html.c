/* hlp2html.c - BH portable conversion front end, Borland C++ 5.5 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <direct.h>
#include <windows.h>

static void basename_no_ext(const char *path, char *name)
{
    const char *p = path, *q; char *dot;
    for (q=path; *q; q++) if (*q=='\\' || *q=='/') p=q+1;
    strcpy(name,p); dot=strrchr(name,'.'); if(dot)*dot=0;
}

int main(int argc, char **argv)
{
    char olddir[MAX_PATH], exedir[MAX_PATH], outdir[MAX_PATH], fullhlp[MAX_PATH], base[MAX_PATH];
    char rtf[MAX_PATH], html[MAX_PATH], cmd[3*MAX_PATH], *slash; FILE *check; int rc;
    if (argc < 2) { puts("Usage: hlp2html helpfile.hlp [output_directory]"); return 1; }
    GetFullPathName(argv[1],MAX_PATH,fullhlp,NULL); basename_no_ext(fullhlp,base);
    GetModuleFileName(NULL,exedir,MAX_PATH); slash=strrchr(exedir,'\\'); if(slash)*slash=0;
    if (argc > 2) strcpy(outdir,argv[2]); else sprintf(outdir,"%s_html",base);
    _getcwd(olddir,MAX_PATH); _mkdir(outdir); if (chdir(outdir)!=0) { perror(outdir); return 2; }
    sprintf(cmd,"\"%s\\helpdeco.exe\" \"%s\" /r /y /n",exedir,fullhlp);
    puts("Decompiling HLP file..."); rc=system(cmd); if(rc!=0){puts("HELPDECO failed.");chdir(olddir);return 3;}
    sprintf(rtf,"%s.rtf",base); sprintf(html,"%s.html",base);
    check=fopen(rtf,"rb"); if(!check){printf("Expected output %s was not created.\n",rtf);chdir(olddir);return 3;} fclose(check);
    sprintf(cmd,"\"%s\\rtf2html.exe\" \"%s\" \"%s\" \"%s\"",exedir,rtf,html,base);
    puts("Converting RTF to searchable HTML..."); rc=system(cmd); chdir(olddir);
    if(rc!=0){puts("RTF conversion failed.");return 4;}
    printf("Created %s\\%s\n",outdir,html); return 0;
}
