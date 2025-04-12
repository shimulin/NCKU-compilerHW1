/* Definition section */
%{
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>

   #define YY_NO_UNPUT
   #define YY_NO_INPUT
   #define print_token(token) \
       printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

   int line_num = 0;
   int comment_num = 0;
   int newline_in_comment = 0;
   int newline = 1;
   int same_line_comment_num = 0;
   int last_comment_line = -1;
   char temp[200] = {0};
%}

%x MULTILINE_COMMENT_STATE
%x LINE_COMMENT

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
identifier {letter}({letter}|{digit})*

/* Rules section */
%%
"//" {
    BEGIN(LINE_COMMENT);
    yymore();
}
<LINE_COMMENT>[^\n]+ {
    yymore();
}
<LINE_COMMENT>"\n" {
    yytext[yyleng - 1] = '\0';
    for (int i = 0; yytext[i]; i++) {
        if (yytext[i] == '\n') yytext[i] = yytext[i + 1];
    }
    printf("%-8s \t COMMENT\n", yytext);
    line_num++;
    comment_num++;
    BEGIN(INITIAL);
    print_token("NEWLINE");
}
"/*" {
    if (newline == 0) {
        same_line_comment_num++;
        newline = 1;
    }
    BEGIN(MULTILINE_COMMENT_STATE);
    yymore();
}
<MULTILINE_COMMENT_STATE>"\n" {
    newline_in_comment = 1;
    line_num++;
    comment_num++;
    yymore();
}
<MULTILINE_COMMENT_STATE>"*/" {
    yymore();
    printf("%-8s \t MUTI_LINE_COMMENT\n", yytext);
    if (newline_in_comment == 0 && newline == 0) {
        same_line_comment_num++;
    }
    newline = 0;
    newline_in_comment = 0;
    comment_num++;
    BEGIN(INITIAL);
}

"+"                 {   print_token("ADD"); }
"-"                 {   print_token("SUB"); }
"*"                 {   print_token("MUL"); }
"/"                 {   print_token("QUO"); }
"%"                 {   print_token("REM"); }
">"                 {   print_token("GTR"); }
"<"                 {   print_token("LSS"); }
">="                {   print_token("GEQ"); }
"<="                {   print_token("LEQ"); }
"=="                {   print_token("EQL"); }
"!="                {   print_token("NEQ"); }
"="                 {   print_token("ASSIGN"); }
"+="                {   print_token("ADD_ASSIGN"); }
"-="                {   print_token("SUB_ASSIGN"); }
"*="                {   print_token("MUL_ASSIGN"); }
"/="                {   print_token("QUO_ASSIGN"); }
"%="                {   print_token("REM_ASSIGN"); }
"&"                 {   print_token("BAND"); }
"|"                 {   print_token("BOR"); }
"~"                 {   print_token("BNOT"); }
">>"                {   print_token("RSHIFT"); }
"&&"                {   print_token("LAND"); }
"||"                {   print_token("LOR"); }
"!"                 {   print_token("NOT"); }
"("                 {   print_token("LPAREN"); }
")"                 {   print_token("RPAREN"); }
"["                 {   print_token("LBRACK"); }
"]"                 {   print_token("RBRACK"); }
"{"                 {   print_token("LBRACE"); }
"}"                 {   print_token("RBRACE"); }
";"                 {   print_token("SEMICOLON"); }
","                 {   print_token("COMMA"); }
"\""                {   print_token("QUOTA"); }
":"                 {   print_token("COLON"); }

{digit}+            {   print_token("INT_LIT"); }
{digit}+"."{digit}+ {   print_token("FLOAT_LIT"); }

\"([^\\\"]|\\.)*\"  {   printf("\"        \t QUOTA\n");
                        for (int i = 0; i < 200; i++) temp[i] = 0;
                        for (int i = 1, j = 0; yytext[i + 1] != '\0'; i++) {
                            temp[j] = yytext[i];
                            j++;
                        }
                        if (temp[0] != '\0') {
                            printf("%-8s \t STRING_LIT\n", temp);
                        }
                        printf("\"        \t QUOTA\n");
                        }

"->"                {   print_token("ARROW"); }
"<<"                {   print_token("LSHIFT"); }
"print"             {   print_token("PRINT"); }
"println"           {   print_token("PRINTLN"); }
"if"                {   print_token("IF"); }
"else"              {   print_token("ELSE"); }
"for"               {   print_token("FOR"); }
"i32"               {   print_token("INT"); }
"f32"               {   print_token("FLOAT"); }
".."                {   print_token("DOTDOT"); }
"bool"              {   print_token("BOOL"); }
"true"              {   print_token("TRUE"); }
"false"             {   print_token("FALSE"); }
"let"               {   print_token("LET"); }
"mut"               {   print_token("MUT"); }
"fn"                {   print_token("FUNC"); }
"return"            {   print_token("RETURN"); }
"break"             {   print_token("BREAK"); }
"as"                {   print_token("AS"); }
"in"                {   print_token("IN"); }
"while"             {   print_token("WHILE"); }
"loop"              {   print_token("LOOP"); }
{identifier}        {   print_token("IDENT"); }
"\n"                {
    newline = 1;
    line_num++;
    print_token("NEWLINE");
}

<<EOF>>             {   line_num++; yyterminate(); }
[ \t]+              {;}
.                   {;}
%%

/*  C Code section */
int yywrap(void)
{
   return 1;
}

int main(int argc, char *argv[])
{
   if (argc == 2) {
       yyin = fopen(argv[1], "r");
   } else {
       yyin = stdin;
   }
   yylex();
   printf("\nFinish scanning,\n");
   printf("total line: %d\n", line_num);
   printf("comment line: %d\n", comment_num - same_line_comment_num);
   fclose(yyin);
   return 0;
}
