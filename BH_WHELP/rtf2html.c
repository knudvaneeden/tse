/* rtf2html.c - compact RTF to searchable HTML converter
   Written for Borland C++ 5.5 (C89-compatible). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static void html_char(FILE *out, int ch)
{
    if (ch == '&') fputs("&amp;", out);
    else if (ch == '<') fputs("&lt;", out);
    else if (ch == '>') fputs("&gt;", out);
    else if (ch == '"') fputs("&quot;", out);
    else if (ch >= 32 || ch == '\n' || ch == '\t') fputc(ch, out);
}

static int hexval(int ch)
{
    if (ch >= '0' && ch <= '9') return ch - '0';
    ch = tolower(ch);
    if (ch >= 'a' && ch <= 'f') return ch - 'a' + 10;
    return -1;
}

static void html_header(FILE *out, const char *title)
{
    fputs("<!doctype html><html><head><meta charset=\"windows-1252\">", out);
    fputs("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">", out);
    fputs("<title>", out); while (*title) html_char(out, (unsigned char)*title++);
    fputs("</title><style>body{font:16px Segoe UI,Arial,sans-serif;margin:0;color:#202124}", out);
    fputs("header{position:sticky;top:0;background:#174ea6;color:white;padding:12px 18px}", out);
    fputs("input{width:min(760px,75vw);font-size:16px;padding:7px}button{padding:8px 14px}", out);
    fputs("main{max-width:1100px;margin:20px auto;padding:0 18px;white-space:pre-wrap;line-height:1.45}", out);
    fputs("mark{background:#ffeb3b}.status{margin-left:10px}</style></head><body>", out);
    fputs("<header><input id=\"q\" aria-label=\"Search\" placeholder=\"Search this Help file\">", out);
    fputs(" <button onclick=\"searchNow()\">Search</button> <button onclick=\"findNext()\">Find next</button><span class=\"status\" id=\"s\"></span></header>", out);
    fputs("<main id=\"help\">", out);
}

static void html_footer(FILE *out)
{
    fputs("</main><script>(function(){var q='',h=location.hash;", out);
    fputs("if(h.indexOf('#q=')===0){try{q=decodeURIComponent(h.substring(3))}catch(e){q=h.substring(3)}}", out);
    fputs("else{q=new URLSearchParams(location.search).get('q')||''}document.getElementById('q').value=q;if(q)highlight(q);", out);
    fputs("document.getElementById('q').addEventListener('keydown',function(e){if(e.key==='Enter')highlight(this.value)});", out);
    fputs("})();function highlight(q){var h=document.getElementById('help');", out);
    fputs("h.querySelectorAll('mark').forEach(function(m){m.replaceWith(document.createTextNode(m.textContent))});", out);
    fputs("if(!q){document.getElementById('s').textContent='';return}var w=document.createTreeWalker(h,NodeFilter.SHOW_TEXT);", out);
    fputs("var a=[],n,r=new RegExp(q.replace(/[.*+?^${}()|[\\]\\\\]/g,'\\\\$&'),'ig');", out);
    fputs("while(n=w.nextNode()){r.lastIndex=0;if(r.test(n.data))a.push(n)}var count=0;a.forEach(function(t){", out);
    fputs("var frag=document.createDocumentFragment(),last=0;t.data.replace(r,function(x,i){frag.append(document.createTextNode(t.data.slice(last,i)));", out);
    fputs("var m=document.createElement('mark');m.textContent=x;frag.append(m);last=i+x.length;count++});frag.append(document.createTextNode(t.data.slice(last)));t.replaceWith(frag)});", out);
    fputs("document.getElementById('s').textContent=count+' match(es)';var m=h.querySelector('mark');if(m)m.scrollIntoView({block:'center'})}", out);
    fputs("function searchNow(){highlight(document.getElementById('q').value)}", out);
    fputs("function findNext(){var m=document.querySelectorAll('mark');if(!m.length){highlight(document.getElementById('q').value);m=document.querySelectorAll('mark')}if(!m.length)return;", out);
    fputs("var y=scrollY+100,i=0;while(i<m.length&&m[i].getBoundingClientRect().top+scrollY<=y)i++;m[i%m.length].scrollIntoView({block:'center'})}</script></body></html>", out);
}

int main(int argc, char **argv)
{
    FILE *in, *out; int ch, next, h1, h2; char word[64]; int wi;
    if (argc < 3) { fprintf(stderr, "Usage: rtf2html input.rtf output.html [title]\n"); return 1; }
    in = fopen(argv[1], "rb"); if (!in) { perror(argv[1]); return 2; }
    out = fopen(argv[2], "wb"); if (!out) { perror(argv[2]); fclose(in); return 3; }
    html_header(out, argc > 3 ? argv[3] : "Converted Windows Help");
    while ((ch = fgetc(in)) != EOF) {
        if (ch == '{' || ch == '}') continue;
        if (ch != '\\') { html_char(out, ch); continue; }
        next = fgetc(in); if (next == EOF) break;
        if (next == '\\' || next == '{' || next == '}') { html_char(out, next); continue; }
        if (next == '\'') { h1=hexval(fgetc(in)); h2=hexval(fgetc(in)); if (h1>=0 && h2>=0) html_char(out,h1*16+h2); continue; }
        if (next == '~') { fputs("&nbsp;",out); continue; }
        if (next == '-') continue;
        if (!isalpha(next)) continue;
        wi=0; word[wi++]=(char)next;
        while ((next=fgetc(in))!=EOF && isalpha(next)) if (wi<63) word[wi++]=(char)next;
        word[wi]=0;
        if (next=='-' || isdigit(next)) { while ((next=fgetc(in))!=EOF && isdigit(next)); }
        if (next!=EOF && next!=' ') ungetc(next,in);
        if (!strcmp(word,"par") || !strcmp(word,"line")) fputs("\n",out);
        else if (!strcmp(word,"tab")) fputc('\t',out);
        else if (!strcmp(word,"page")) fputs("\n\n----------------------------------------\n\n",out);
    }
    html_footer(out); fclose(out); fclose(in); return 0;
}
