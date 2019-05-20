%option noyywrap yylineno
%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<cstring>
#include<vector>

#include<stdio.h>
#include<iostream>
#include<fstream>
#include "1505033_SymbolTable.h"
#include "y.tab.h"

using namespace std;


extern YYSTYPE yylval;
//extern SymbolTable *table;

int line_count=1;




%}

NEWLINE \n
WHITESPACE [ \t\f\r\v]+ 
FLOAT [0-9]*(\.)?[0-9]+(E[+-]?[0-9]+)? 
FLOAT_WITH_POINT	[0-9]*(\.)[0-9]+(E[+-]?[0-9]+)?
%%
{WHITESPACE}	{}

{NEWLINE} {line_count++;
	yylineno=line_count;
	
	}

"if"	{
		string str(yytext);
		string type="IF";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return IF;
	}
		
"else"	{
		string str(yytext);
		string type="ELSE";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return ELSE;                
	}

"for"  {

		string str(yytext);
		string type="FOR";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return FOR;
	}

"while"  {

		string str(yytext);
		string type="WHILE";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return WHILE;
	}

"do"  {

		string str(yytext);
		string type="DO";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return DO;
	}
"break"  {

		string str(yytext);
		string type="BREAK";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return BREAK;
	}
"int"  {

		
		string str(yytext);
		string type="INT";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return INT;
	}
"char"  {


		string str(yytext);
		string type="CHAR";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return CHAR;
	}
"float"  {
		string str(yytext);
		string type="FLOAT";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return FLOAT;
	}
"double"  {

		string str(yytext);
		string type="DOUBLE";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return DOUBLE;
	}
"void"  {

		string str(yytext);
		string type="VOID";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return VOID;
	}
"printf"  {
		string str(yytext);
		string type="PRINTLN";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return PRINTLN;
	 }
"return"  {

		string str(yytext);
		string type="RETURN";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return RETURN;
	}
"switch"  {

		string str(yytext);
		string type="SWITCH";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return SWITCH;
	}
"case"  {
		string str(yytext);
		string type="CASE";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return CASE;
	}
"default"  {

		string str(yytext);
		string type="DEFAULT";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return DEFAULT;
	}
"continue"  {

		string str(yytext);
		string type="CONTINUE";
		SymbolInfo *ret=new SymbolInfo(str,type);
            	ret->next=NULL;
            	yylval.symbolinfo =ret;
		return CONTINUE;
	}

[0-9]+ 	{
				/*fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="CONST_INT";
				table.Insert(str,type);
				table.PrintCurrentScopeTable();*/

				string str(yytext);
				string type="CONST_INT";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return CONST_INT;

			}


\'\\[\'\"nt\\afrbv0]\'	{

	if(yytext[2]=='n')
	{
		/*string name;
		name.push_back('\n');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
		line_count++;*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='t')
	{
		/*string name;
		name.push_back('\t');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='a')
	{
		/*string name;
		name.push_back('\a');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR; 
		
	}
	else if(yytext[2]=='f')
	{
		/*string name;
		name.push_back('\f');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='r')
	{
		/*string name;
		name.push_back('\r');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='b')
	{
		/*string name;
		name.push_back('\b');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='v')
	{
		/*string name;
		name.push_back('\v');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='0')
	{
		/*string name;
		name.push_back('\0');
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='\'')
	{
		/*string name;
		name.push_back('\'');
		string type="CONST_CHAR";
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='\"')
	{
		/*string name;
		name.push_back('\"');
		string type="CONST_CHAR";
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
	else if(yytext[2]=='\\')
	{
		/*string name;
		name.push_back('\\');
		string type="CONST_CHAR";
		fprintf(tokenout,"<CONST_CHAR,%s>",name.c_str());
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;
		
	}
}


\'[^\'\"\\\n]\'	{

		/*string name(yytext);
		string type="CONST_CHAR";
		table.Insert(name,type);
		table.PrintCurrentScopeTable();
		fprintf(tokenout,"<CONST_CHAR,%c>",yytext[1]);
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);*/
		return CONST_CHAR;

}

[A-Za-z_][a-zA-Z0-9_]*	{
				/*fprintf(tokenout,"<ID,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="ID";
				table.Insert(str,type);
				table.PrintCurrentScopeTable();*/
				
				string str(yytext);
				string type="ID";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return ID;
			}



"-"|"+" 			{
				//fprintf(tokenout,"<ADDOP,%s>",yytext);
				//fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="ADDOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return ADDOP;

			}

[*/%]			{
				string str(yytext);
				string type="MULOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return MULOP;

			}

"++"		{
				string str(yytext);
				string type="INCOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return INCOP;

			}
"--"		{
				string str(yytext);
				string type="DECOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return DECOP;
		}
(<)|(<=)|(>)|(>=)|(==)|(!=)	{
				string str(yytext);
				string type="RELOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return RELOP;

			}
"="			{
				string str(yytext);
				string type="ASSIGNOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
            			return ASSIGNOP;

			}
"&&"|"||"	{
				string str(yytext);
				string type="LOGICOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return LOGICOP;

			}

"&"|"|"|"^"|"<<"|">>" 		{
				string str(yytext);
				string type="BITOP";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return BITOP;
	
			}
"!"	{
				string str(yytext);
				string type="NOT";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return NOT;

			}

"("			{
				string str(yytext);
				string type="LPAREN";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return LPAREN;

			}
")"			{
				string str(yytext);
				string type="RPAREN";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return RPAREN;

			}
"{"			{
				//fprintf(tokenout,"<LCURL,%s>",yytext);
				//fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="LCURL";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return LCURL;

			}
"}"			{
				//fprintf(tokenout,"<RCURL,%s>",yytext);
				//fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="RCURL";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return RCURL;

			}
","			{
				string str(yytext);
				string type="COMMA";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return COMMA;

			}
";"			{
				string str(yytext);
				string type="SEMICOLON";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return SEMICOLON;

			}
"[" 	{
				//fprintf(tokenout,"<LTHIRD,%s>",yytext);
				//fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
								string str(yytext);
				string type="LTHIRD";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return LTHIRD;

			}
"]" 	{
				string str(yytext);
				string type="RTHIRD";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return RTHIRD;

			}



[0-9]*(\.)?[0-9]+(E[+-]?[0-9]+)?  {
				/*fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				string str(yytext);
				string type="CONST_FLOAT";
				table.Insert(str,type);
				table.PrintCurrentScopeTable();*/
				string str(yytext);
				string type="CONST_FLOAT";
				SymbolInfo *ret=new SymbolInfo(str,type);
            			ret->next=NULL;
            			yylval.symbolinfo =ret;
				return CONST_FLOAT;
			}


\/\/([^\n]|(\\\n))*	{
	
	//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_count,yytext);
	int len =strlen(yytext);
	for(int i=0;i<len;i++)
	{
		if(yytext[i]=='\\'&& yytext[i+1]=='\n')
		{
			line_count++;
		}
		
	}
	return COMMENT;
}

\/\*(.|\n)*\*\/	{
	//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_count,yytext);
	int len =strlen(yytext);
	for(int i=0;i<len;i++)
	{
		if(yytext[i]=='\n')
		{
			line_count++;
		}
		
	}
	return COMMENT;
}


\".*\" {
	int len =strlen(yytext);
	string str;
	for(int i=0;i<len;i++)
	{
		if(yytext[i]=='\\'&& yytext[i+1]=='n')
		{
			str.push_back('\n');
			i=i+1;
		}
		else if(yytext[i]=='\\'&& yytext[i+1]=='t')
		{
			str.push_back('\t');
			i=i+1;			
		}//more escape characters to be added
		else if(yytext[i]!='\\')
		{
			str.push_back(yytext[i]);
		}
	}
	//fprintf(tokenout,"<STRING,%s>",str.c_str());
	//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,yytext);
	return STRING;
}

\"([^\"\n]|(\\\n))*\"	{
	
	int len =strlen(yytext);
	string str;
	for(int i=0;i<len;i++)
	{
		if(yytext[i]=='\\'&& yytext[i+1]=='\n')
		{
			i=i+2;
			line_count++;
		}
		if(yytext[i]=='\\'&& yytext[i+1]=='n')
		{
			str.push_back('\n');
			i=i+1;
		}
		else if(yytext[i]=='\\'&& yytext[i+1]=='t')
		{
			str.push_back('\t');
			i=i+1;			
		}//more escape characters to be added
		else if(yytext[i]!='\\')
		{
			str.push_back(yytext[i]);
		}
	
	}
	//fprintf(tokenout,"<STRING,%s>",str.c_str());
	//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,yytext);
	return STRING;
	

}



%%



