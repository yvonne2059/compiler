%{

#include <string>
#include <vector>
#include <map>

using namespace std;

#define MAX_LINE_LENG 256
#define LIST strcat(buf, yytext)
#define token(t) { LIST; printf("<%s>\n", #t); }
#define tokenChar(t) { LIST; printf("<'%c'>\n", t); }
#define tokenInteger(t,i) { LIST; printf("<%s: %d>\n", #t, i); }
#define tokenString(t,s) { LIST; printf("<%s: %s>\n", #t, s); }

int linenum = 1;
char buf[MAX_LINE_LENG];

class SymbolTable {
  private:
    vector<string> symbols;
    map<string, int> table_map;
    int index;
  public:
    SymbolTable();
    int lookup(string s);
    int insert(string s);
    int dump();
};

SymbolTable *table;

%}


RELATIONAL              ([<>=])
IDENTIFIER              ([A-Za-z_][0-9A-Za-z_]*)
DIGIT                   ([0-9]+)
INTEGERC                 ({DIGIT})
REAL                    ([-+]?{DIGIT}\.{DIGIT}?([Ee](-+)?{DIGIT})?)
STRING                  (\"(\"\"|[^"\n])*\")
SINGLE_COMMENT          (\/\/[^\n]*)


%x COMMENT

%%

"("                    {token('(');}
")"                    {token(')');}
","                    {token(',');}
"."                    {token('.');}
":"                    {token(':');}
";"                    {token(';');}
"["                    {token('[');}
"]"                    {token(']');}
"{"                    {token('{');}
"}"                    {token('}');}

"+"                    {token('+');}
"-"                    {token('-');}
"*"                    {token('*');}
"/"                    {token('/');}
"%"                    {token('%');}

{RELATIONAL}            { tokenChar(yytext[0]); }


"<="                    { token('<='); }
">="                    { token('>='); }
"<>"                    { token('<>'); }
"&&"                    { token('&&'); }
"||"                    { token('||'); }
"~"                    { token('~'); }
":="                    { token(':='); }

 /* keyword */
"array"                  { token(ARRAY); }
"boolean"                  { token(BOOLEAN); }
"begin"                 { token(BEGIN); }
"break"                 { token(BREAK); }
"char"                  { token(CHAR); }
"case"                  { token(CASE); }
"const"                  { token(CONST); }
"continue"              { token(CONTINUE); }
"do"                    { token(DO); }
"else"                  { token(ELSE); }
"end"                  { token(END); }
"exit"                { token(EXIT); }
"false"                 { token(FALSE); }
"for"                   { token(FOR); }
"fn"                    { token(FN); }
"if"                    { token(IF); }
"in"                    { token(IN); }
"integet"                   { token(INTEGER); }
"loop"                  { token(LOOP); }
"module"                 { token(MODULE); }
"print"                 { token(PRINT); }
"println"               { token(PRINTLN); }
"procedure"                   { token(PROCEDURE); }
"repeat"                { token(REPEAT); }
"return"                { token(RETURN); }
"real"                  { token(REAL); }
"string"                   { token(STRING); }
"record"                { token(RECORD); }
"then"                  { token(THEN); }
"true"                  { token(TRUE); }
"type"                  { token(TYPE); }
"use"                   { token(USE); }
"util"                   { token(UTIL); }
"var"                 { token(VAR); }
"while"                 { token(WHILE); }

{IDENTIFIER}            {
                          tokenString(IDENTIFIER, yytext);
                          //push to symbol table
                          table->insert(yytext);
                        }

{INTEGERC}               {
                          tokenInteger(INTEGER, atoi(yytext));
                        }

{REAL}                  {
                          tokenString(REAL, yytext);
                        }

{STRING}                {
                          char s[MAX_LINE_LENG] = {0};
                          int idx = 0;
                          for (int i = 1; i < yyleng - 1; ++i) {
                            if (yytext[i] == '"') ++i;
                            s[idx++] = yytext[i];
                          }
                          tokenString(STRING, s);
                        }

  /* comment */
{SINGLE_COMMENT}        { LIST; }

"*"         {
                          LIST;
                          BEGIN COMMENT;
                        }

<COMMENT>[^\n]          {
                          LIST;
                        }

<COMMENT>\n             {
                          LIST;
                          printf("%d: %s", linenum, buf);
                          linenum++;
                          buf[0] = '\0';
                        }

<COMMENT>"*"  {
                          LIST;
                          BEGIN INITIAL;
                        }

\n                      {
                          LIST;
                          printf("%d: %s", linenum, buf);
                          linenum++;
                          buf[0] = '\0';
                        }

[ \t]*                  { LIST; }

.                       {
                          LIST;
                          printf("%d:%s\n", linenum, buf);
                          printf("bad character:'%s'\n",yytext);
                          exit(-1);
                        }

%%

SymbolTable::SymbolTable()
{
  index = 0;
}

int SymbolTable::lookup(string s)
{
  if (table_map.find(s) != table_map.end()) {
    return table_map[s];
  }
  else {
    return -1;
  }
}

int SymbolTable::insert(string s)
{
  if (table_map.find(s) != table_map.end()) {
    return -1;
  }
  else {
    symbols.push_back(s);
    table_map[s] = index;
    return index++;
  }
}

int SymbolTable::dump()
{
  for (int i = 0; i < index; ++i) {
    printf("%d:\t%s\n", i, symbols[i].c_str());
  }
  return index;
}

void create()
{
  table = new SymbolTable();
}

int main()
{
  create();
  yylex();
  printf("\nSymbol Table:\n");
  table->dump();
  fflush(yyout);
  exit(0);
}
