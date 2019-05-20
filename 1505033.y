%define parse.error verbose

%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
//#include "SymbolInfo.h"
#include "1505033_SymbolTable.h"
#include<stdlib.h>
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
 FILE *fp;
 FILE *logout;
 FILE *errorFile;
 FILE *assembly;

int labelCount=0;
int tempCount=0;

int error_count=0;
int syntax_error=0;

SymbolTable table(100);

string globalType;
string func_ret_Type;
int arrayIndex=0;
vector <parameter> list;
vector <string> arg_type_list;
vector <string> data_field;
vector <string> arg_list;
//data_field.push(".DATA\n");

int globalRetFlag=0;

string type1, type2, type3, type4;
string name1, name2;

string function;
void yyerror(const char *s)
{
	//write your code
	fprintf(errorFile, "%s at Line no. : %d\n\n ",s,yylineno);
}


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	data_field.push_back(string(t)+" DW "+" ?\n");
	return t;
}

char *scopeNo(int sn)
{
	char *n=new char[10];
	char b[33];
	//itoa(sn,b,10);
	sprintf(b,"%d",sn);
	strcpy(n,b);
	return n;
}

%}
%union{
SymbolInfo * symbolinfo;

}
%token <symbolinfo> ID
%token <symbolinfo> INT
%token <symbolinfo> FLOAT
%token <symbolinfo> VOID
%token <symbolinfo> SEMICOLON
%token <symbolinfo> COMMA
%token <symbolinfo> LPAREN
%token <symbolinfo> RPAREN
%token <symbolinfo> ADDOP
%token <symbolinfo> CONST_INT
%token <symbolinfo> CONST_CHAR
%token <symbolinfo> CONST_FLOAT
%token <symbolinfo> RETURN
%token <symbolinfo> LCURL
%token <symbolinfo> RCURL
%token <symbolinfo> ASSIGNOP
%token <symbolinfo> LTHIRD
%token <symbolinfo>  RTHIRD
%token <symbolinfo> IF 
%token <symbolinfo> ELSE
%token <symbolinfo> FOR
%token <symbolinfo> WHILE
%token <symbolinfo> DO
%token <symbolinfo> BREAK
%token <symbolinfo> CHAR
%token <symbolinfo> DOUBLE
%token <symbolinfo> SWITCH
%token <symbolinfo> CASE
%token <symbolinfo> DEFAULT
%token <symbolinfo> CONTINUE
%token <symbolinfo> MULOP
%token <symbolinfo> INCOP
%token <symbolinfo> RELOP
%token <symbolinfo> LOGICOP
%token <symbolinfo> BITOP
%token <symbolinfo> NOT
%token <symbolinfo> COMMENT
%token <symbolinfo> STRING
%token <symbolinfo> DECOP
%token <symbolinfo> PRINTLN 
%token LOWER_THAN_ELSE

%type <symbolinfo> start
%type <symbolinfo> program
%type <symbolinfo> unit
%type <symbolinfo> type_specifier
%type <symbolinfo> declaration_list
%type <symbolinfo> var_declaration
%type <symbolinfo> func_declaration
%type <symbolinfo> compound_statement
%type <symbolinfo> parameter_list
%type <symbolinfo> statements
%type <symbolinfo> expression_statement
%type <symbolinfo> statement
%type <symbolinfo> expression
%type <symbolinfo> variable
%type <symbolinfo> logic_expression
%type <symbolinfo> rel_expression
%type <symbolinfo> simple_expression
%type <symbolinfo> unary_expression
%type <symbolinfo> term
%type <symbolinfo> factor
%type <symbolinfo> argument_list
%type <symbolinfo> arguments
%type <symbolinfo> func_definition

/*%left 
%right
*/
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{

		fprintf(logout,"At line no: %d start: program\n\n",yylineno);
		table.PrintAllScopeTables(logout);
		string code_body=$1->code;
		$$->code="";
		$$->code+=".MODEL SMALL\n";
		$$->code+=".STACK 100H\n";
		$$->code+=".DATA\n";
		for(int i=0;i<data_field.size();i++)
		{
			$$->code+=data_field[i];  //temporary variables will go in too, append scopenumber for uniqueness
		}
		$$->code+=".CODE\n";
		$$->code+="PRINT_ PROC\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nOR AX,AX\nJGE POSITIVE\nNEGATIVE:\nPUSH AX \nMOV AH,2\nMOV DL,'-' \nINT 21h\n POP AX\n NEG AX \nPOSITIVE: \nMOV CX,0\nMOV BX,0Ah\nTOP: \nXOR DX,DX \nDIV BX \nPUSH DX \nINC CX \nOR AX,AX\nJNE TOP \nMOV AH,2 \nPRINT: \nPOP DX \nADD DL,48d \nINT 21h\nLOOP PRINT \nPOP DX  \nPOP CX \nPOP BX \nPOP AX \nRET\nPRINT_ ENDP\n\n"  ;             
		$$->code+=code_body;
		fprintf(assembly,"%s\n\n",$$->code.c_str());
	}
	;

program : program unit {fprintf(logout,"At line no: %d program: program unit\n\n",yylineno);
	//$1->next=$2;
	//$$=$1;
	string str=$1->getname();
	str+=$2->getname();
	fprintf(logout,"%s",str.c_str());
	$$->setname(str);
	$$->code=$1->code+$2->code;
	
	}
	| unit	{fprintf(logout,"At line no: %d program: unit\n\n",yylineno);

		string str=$1->getname();
	        fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		$$->code=$1->code;
		}
	;
	
unit : var_declaration 
	{	
		fprintf(logout,"At line no: %d unit: var_declaration\n\n",yylineno);

		string str=$1->getname();
	        fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		  	
		
		
		
	}
     | func_declaration {fprintf(logout,"At line no: %d unit: func_declaration\n\n",yylineno);

		string str=$1->getname();
	        fprintf(logout,"%s",str.c_str());
		$$->setname(str);
     
     }
     | func_definition {fprintf(logout,"At line no: %d unit: func_definition\n\n",yylineno);
     		string str=$1->getname();
	        fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		$$->code=$1->code;
     }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {fprintf(logout,"At line no: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",yylineno);
		int no_of_parameters=list.size();
		//table.InsertFunction( $2->getname(), $1->getname(),list,no_of_parameters,logout,"dec");	
		string n=$2->getname();
		SymbolInfo *ret=table.Lookup(n);
		if(ret==NULL){
		table.InsertFunction( $2->getname(), $1->getname(),list,no_of_parameters,logout,"dec");
		}
		else
		{
			string ind=ret->indicator;
			string flag=ret->func_dec_def;
			
			if(ind=="arr")
			{
				fprintf(errorFile,"Error at line %d: Array with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="var")
			{
				fprintf(errorFile,"Error at line %d: Variable with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="func" && flag=="dec")
			{
				fprintf(errorFile,"Error at line %d: Multiple declarations of the same function.\n\n",yylineno,ret->name);
				error_count++;
	
			}
			else if(ind=="func" && flag=="def")
			{
				fprintf(errorFile,"Error at line %d: Function already defined.Declaration should come before definition.\n\n",yylineno,ret->name);
				error_count++;
			}
		}
		list.clear();	
		table.PrintAllScopeTables(logout);
		
		string str=$1->getname();
		str+=" ";
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+=$6->getname();
 		str+="\n\n";
 		fprintf(logout,"%s",str.c_str());
 		$$->setname(str);
		
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {fprintf(logout,"At line no: %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",yylineno);
		int no_of_parameters=list.size();
		string n=$2->getname();
		SymbolInfo *ret=table.Lookup(n);
		if(ret==NULL){
		table.InsertFunction( $2->getname(), $1->getname(),list,no_of_parameters,logout,"dec");
		}
		else
		{
			
			string ind=ret->indicator;
			string flag=ret->func_dec_def;
			
			if(ind=="arr")
			{
				fprintf(errorFile,"Error at line %d: Array with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="var")
			{
				fprintf(errorFile,"Error at line %d: Variable with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="func" && flag=="dec")
			{
				fprintf(errorFile,"Error at line %d: Multiple declarations of the same function.\n\n",yylineno,ret->name);
				error_count++;	
			}
			else if(ind=="func" && flag=="def")
			{
				fprintf(errorFile,"Error at line %d: Function already defined.Declaration should come before definition.\n\n",yylineno,ret->name);
				error_count++;
			}
		}
		list.clear();		
		table.PrintAllScopeTables(logout);

		string str=$1->getname();
		str+=" ";
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+="\n\n";
 		fprintf(logout,"%s",str.c_str());
 		$$->setname(str);
		
		}
		|type_specifier ID LPAREN parameter_list RPAREN error{yyerror("Semicolon should end function declaration");
		syntax_error++;}
		|type_specifier ID LPAREN parameter_list RPAREN RPAREN  error SEMICOLON {yyerror("Too many )s"); syntax_error++;}
		|type_specifier ID LPAREN LPAREN parameter_list RPAREN error SEMICOLON {yyerror("Too many (s"); syntax_error++;}
		|type_specifier ID LPAREN RPAREN error{yyerror("Semicolon should end function declaration"); syntax_error++;}
		|type_specifier ID LPAREN RPAREN RPAREN  error SEMICOLON {yyerror("Too many )s"); syntax_error++;}
		|type_specifier ID LPAREN LPAREN RPAREN error SEMICOLON {yyerror("Too many (s"); syntax_error++;}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {int no_of_parameters=list.size();
		string procedure_name=$2->getname();
		function=procedure_name;
		string c="";
		$1->code=procedure_name+" PROC\n";
		$1->code+="PUSH BP\n";
		$1->code+="MOV BP,SP\n";
		//cout<<"here:"<<$1->code<<endl;
		
		string n=$2->getname();
		string returnType1=$1->getname();
		func_ret_Type=returnType1;
		SymbolInfo *ret=table.Lookup(n);
		if(ret==NULL){
		table.InsertFunction( $2->getname(), $1->getname(),list,no_of_parameters,logout,"def");
		}
		else
		{
			string ind=ret->indicator;
			string flag=ret->func_dec_def;
			string returnType2=ret->type;
			if(ind=="arr")
			{
				fprintf(errorFile,"Error at line %d: Array with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="var")
			{
				fprintf(errorFile,"Error at line %d: Variable with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="func" && flag=="dec")
			{
				ret->func_dec_def="def";
				vector <parameter> list2=ret->parameterList;
				if(returnType1!=returnType2)
				{
					fprintf(errorFile,"Error at line %d: Return types of function declaration (%s) and definition(%s) do not match\n\n",yylineno,returnType1.c_str(),
					returnType2.c_str());
					error_count++;
				}
				if(list.size()!=list2.size())
				{
					fprintf(errorFile,"Error at line %d: Number of parameters in function definition (%d) and function declaration(%d) do not match\n\n",yylineno,list.size(),
					list2.size());
					error_count++;
				}
				else{
				for(int i=0;i<list.size();i++)
				{
					parameter p1=list[i];
					parameter p2=list2[i];

					if(p2.flag!=p1.flag)
					{
						fprintf(errorFile,"Error at line %d: Parameter lists of function(%s) definition and declaration do not match\n\n",yylineno,ret->name.c_str());
						error_count++;
					}
					else if(p2.flag==2)
					{
						if(p1.type!=p2.type || p1.name!=p2.name)
						{
							fprintf(errorFile,"Error at line %d: Parameter lists of function(%s) definition and declaration do not match\n\n",yylineno,ret->name.c_str());
							error_count++;
						}
					}
					else if(p2.flag==1)
					{
						if(p1.type!=p2.type)
						{
							fprintf(errorFile,"Error at line %d: Parameter lists of function(%s) definition and declaration do not match\n\n",yylineno,ret->name.c_str());
							error_count++;
						}
					}
				}
				}
				
			}
			else if(ind=="func" && flag=="def")
			{
				fprintf(errorFile,"Error at line %d: Multiple definitions of the same function\n\n",yylineno);
				error_count++;
			}
		}
		
		}compound_statement {

		
		fprintf(logout,"At line no: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",yylineno);
		string procedure_name=$2->getname();
		string str=$1->getname();
		str+=" ";
		str+=$2->getname();
		str+=$3->getname();
		str+=$4->getname();
		str+=$5->getname();
		str+=$7->getname();
		str+="\n\n";
 		fprintf(logout,"%s",str.c_str());
 		$$->setname(str);
 		$$->code=$1->code;
 		$$->code+=$7->code;
		//$$->code+="POP BP\n";
		//$$->code+="POP DX\n";

		//$$->code+="push ax\n";
		//$$->code+="push dx\n";		
		//$$->code+="RET\n";
		$$->code+=procedure_name+" ENDP\n";
		}
		| type_specifier ID LPAREN RPAREN {
		string n=$2->getname();
		function=n;
		string returnType1=$1->getname();
		func_ret_Type=returnType1;
		SymbolInfo *ret=table.Lookup(n);
		if(ret==NULL){													
		table.InsertFunction( $2->getname(), $1->getname(),list,0,logout,"def");
		}
		else
		{
			string ind=ret->indicator;
			string flag=ret->func_dec_def;
			string returnType2=ret->type;
			//fprintf(errorFile,"Sure: %s %s\n\n",ind.c_str(),flag.c_str());
			if(ind=="arr")
			{
				fprintf(errorFile,"Error at line %d: Array with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="var")
			{
				fprintf(errorFile,"Error at line %d: Variable with name %s already exists in symbol table\n\n",yylineno,ret->name);
				error_count++;
			}
			else if(ind=="func" && flag=="dec")
			{
				vector <parameter> list2=ret->parameterList;
				//fprintf(errorFile,"Here: %d %d\n\n",list.size(),list2.size());
				ret->func_dec_def="def";
				if(returnType1!=returnType2)
				{
					fprintf(errorFile,"Error at line %d: Return types of function declaration (%s) and definition(%s) do not match\n\n",yylineno,returnType1.c_str(),
					returnType2.c_str());
					error_count++;
				}
				if(list2.size()!=0)
				{
					fprintf(errorFile,"Error at line %d: Number of parameters in function definition (%d) and function declaration(%d) do not match\n\n",yylineno,list.size(),
					list2.size());
					error_count++;
				}

				
			}
			else if(ind=="func" && flag=="def")
			{
				fprintf(errorFile,"Error at line %d: Multiple definitions of the same function\n\n",yylineno);
				error_count++;
			}
		}
		table.EnterScope(logout);
		} compound_statement {
		//table.PrintAllScopeTables(logout);
		//table.ExitScope(logout);
		fprintf(logout,"At line no: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",yylineno);
		string n=$2->getname();
		string str=$1->getname();
		str+=" ";
		str+=$2->getname();
		str+=$3->getname();
		str+=$4->getname();
		str+=$6->getname();
		str+="\n\n";
 		fprintf(logout,"%s",str.c_str());
 		$$->setname(str);
 		if(n!="main")
 		{
 			$$->code=n+" PROC\n";
 			$1->code+="PUSH BP\n";		
			$$->code+=$6->code;
			//$$->code+="POP DX\n";
			//$$->code+="push ax\n";
			//$$->code+="push dx\n";
			//$$->code+="RET\n";
			$$->code+=n+" ENDP\n";
		}
		else
		{
		 	$$->code="\n\nMAIN PROC\n";	
		 	$$->code+="MOV AX, @DATA\nMOV DS,AX\n\nXOR AX,AX\n";	
			$$->code+=$6->code;
			$$->code+="\nMAIN ENDP\nEND MAIN\n";
		}
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {fprintf(logout,"At line no: %d parameter_list  : parameter_list COMMA type_specifier ID\n\n",yylineno);
		

		string str=$1->getname();
 		str+=$2->getname();
 		str+=" ";
 		str+=$3->getname();
 		str+=" ";
 		str+=$4->getname();
 		fprintf(logout,"%s\n\n",str.c_str());
 		$$->setname(str);
 		parameter p($3->getname(),$4->getname());
		list.push_back(p);
		}
		| parameter_list COMMA type_specifier {fprintf(logout,"At line no: %d parameter_list  : parameter_list COMMA type_specifier\n\n",yylineno);
		

		string str=$1->getname();
 		str+=$2->getname();
 		str+=" ";
 		str+=$3->getname();
 		fprintf(logout,"%s\n\n",str.c_str());
 		$$->setname(str);
 		parameter p($3->getname());
		list.push_back(p);
		}
 		| type_specifier ID {fprintf(logout,"At line no: %d parameter_list  : type_specifier ID \n\n",yylineno);
		string n=$2->getname();
		string t=$1->getname();
 		string str=$1->getname();
 		str+=" ";
 		str+=$2->getname();
 		fprintf(logout,"%s\n\n",str.c_str());
 		$$->setname(str);
 		parameter p(t,n);
 		
		list.push_back(p);
 		}
		| type_specifier {fprintf(logout,"At line no: %d parameter_list  : type_specifier\n\n",yylineno);
		$$=$1;
		fprintf(logout,"%s\n\n",$1->getname().c_str());
		
		parameter p($1->getname());
		
		list.push_back(p);
		}
 		;

 		
compound_statement : LCURL {table.EnterScope(logout);
			int j=list.size()-1;
			$1->code="";
			for(int i=0;i<list.size();i++)
			{
				parameter p=list[i];
				if(p.flag==2)
				{
					
					string var_name=p.name+string(scopeNo(table.getScopeNumber()));
					table.Insert("var",0,p.name,p.type,logout);
					data_field.push_back(p.name+string(scopeNo(table.getScopeNumber()))+" DW "+" ?\n");
					$1->code+="MOV AX, [BP+"+string(scopeNo(j*2+4))+"]\n";
					$1->code+="MOV "+var_name+" ,AX\n";
				}
				j--;
				
			}
			list.clear();	
			} statements RCURL {
			table.PrintAllScopeTables(logout);
			table.ExitScope(logout);
			fprintf(logout,"At line no: %d compound_statement : LCURL statements RCURL\n\n",yylineno);
		        string str=$1->getname();
			str+=$3->getname();
			str+=$4->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->code=$1->code;
		  	$$->code+=$3->code;
		  	
		    
		    }
 		    | LCURL{table.EnterScope(logout);} RCURL {
 		    	table.PrintAllScopeTables(logout);
			table.ExitScope(logout);
 		    	fprintf(logout,"At line no: %d compound_statement : LCURL RCURL\n\n",yylineno);
 		        string str=$1->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	//table.EnterScope();
		  	
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON 
		{
			fprintf(logout,"At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n\n",yylineno);

		  	string str=$1->getname();
		  	str+=" ";
			str+=$2->getname();
			str+=$3->getname();
			str+="\n\n";
			fprintf(logout,"%s",str.c_str());
			$$->setname(str);
			//fprintf(logout,"%s",$$->getname().c_str());

			
		} |type_specifier declaration_list error {yyerror("Semicolon required at the end of varibale declaration!"); syntax_error++;}
 		 ;
 		 
type_specifier	: INT {fprintf(logout,"At line no: %d type_specifier: INT\n\n",yylineno); 
			string str=$1->getname();
			fprintf(logout,"%s\n\n",str.c_str()); 
			$$->setname(str);
			$$->setType("int");
			globalType=str;
			}
 		| FLOAT {fprintf(logout,"At line no: %d type_specifier: FLOAT\n\n",yylineno);		
 			string str=$1->getname();
			fprintf(logout,"%s\n\n",str.c_str());
			$$->setname(str); 
			$$->setType("float");
			globalType=str;}
 		| VOID	{fprintf(logout,"At line no: %d type_specifier: VOID\n\n",yylineno);			
 			string str=$1->getname();
			fprintf(logout,"%s\n\n",str.c_str());
			$$->setname(str);
			$$->setType("void");
			globalType=str;}
 		;
		
declaration_list : declaration_list COMMA ID 
		  {
		  	fprintf(logout,"At line no: %d declaration_list : declaration_list COMMA ID\n\n",yylineno);
			string n=$3->getname();
		  	string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	
		  	SymbolInfo *ret=table.Lookup_currentScope($3->getname());
			 if(ret==NULL) 
			 {
			 	
			 	table.Insert("var",0,$3->getname(),globalType,logout);
			 }
			 else
			 {
			 	fprintf(errorFile,"Error at line %d: 1 Multiple declarations of the same variable %s\n\n",yylineno,$3->getname().c_str());
			 	error_count++;
			 }
		  	data_field.push_back(n+string(scopeNo(table.getScopeNumber()))+" DW "+" ?\n");
		  	
		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
 		  {
 		  	fprintf(logout,"At line no: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",yylineno);
 		  	
 		  	string n=$3->getname();
 		  	string dim=$5->getname();
 		  	
 		  	string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			str+=$4->getname();
			str+=$5->getname();
			str+=$6->getname();
			fprintf(logout,"%s\n\n",str.c_str());
			$$->setname(str);
			const char *c=$5->getname().c_str();
			int ind=atoi(c);
			 SymbolInfo *ret=table.Lookup_currentScope($3->getname());
			 if(ret==NULL) 
			 {
			 	
			 	table.Insert("arr",ind,$3->getname(),globalType,logout);
			 }
			 else
			 {
			 	fprintf(errorFile,"Error at line %d: 2 Multiple declarations of the same variable %s\n",yylineno,$3->getname().c_str());
			 	error_count++;
			 }
			 data_field.push_back(n+string(scopeNo(table.getScopeNumber()))+" DW "+dim+" DUP (?)\n");
			
		  }
 		  | ID { fprintf(logout,"At line no: %d declaration_list: ID\n\n",yylineno);
 		  	 string str=$1->getname();
			 fprintf(logout,"%s\n\n",str.c_str());
			 //$$=$1;
			 $$->setname(str);
			 SymbolInfo *ret=table.Lookup_currentScope($1->getname());
			 if(ret==NULL) 
			 {
			 	table.Insert("var",0,$1->getname(),globalType,logout);
			 }
			 else
			 {
			 	fprintf(errorFile,"Error at line %d: 3 Multiple declarations of the same variable %s\n\n",yylineno,str.c_str());
			 	error_count++;
			 }
			data_field.push_back(str+string(scopeNo(table.getScopeNumber()))+" DW "+" ?\n");
			 }
 		  | ID LTHIRD CONST_INT RTHIRD {fprintf(logout,"At line no: %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n",yylineno);
 		  		 		  	
 		string dim=$3->getname(); 
 		string name=$1->getname();  
 		string str=$1->getname();
		str+=$2->getname();
		str+=$3->getname();
		str+=$4->getname();
		fprintf(logout,"%s\n\n",str.c_str());
		$$->setname(str);
		const char *c=$3->getname().c_str();
		int ind=atoi(c);
		
		SymbolInfo *ret=table.Lookup_currentScope(name);
	        if(ret==NULL) 
		{
			 table.Insert("arr",ind,name,globalType,logout);
		}
		 else
		 {
			 fprintf(errorFile,"Error at line %d: 4 Multiple declarations of the same variable %s\n\n",yylineno,name.c_str());
			 error_count++;
		 }
		 
		data_field.push_back(name+string(scopeNo(table.getScopeNumber()))+" DW "+dim+" DUP (?)\n");
		 
		}
 		  ;		  
statements : statement {fprintf(logout,"At line no: %d statements : statement\n\n",yylineno);
		  	 string str=$1->getname();
			 fprintf(logout,"%s",str.c_str());
			 $$->setname(str);
			 $$->code=$1->code;

}
	   | statements statement {fprintf(logout,"At line no: %d statements : statements statement\n\n",yylineno);
	   	string str=$1->getname();
		str+=$2->getname();
		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		$$->code=$1->code+$2->code;
	   }
	   ;
	   
statement : var_declaration {fprintf(logout,"At line no: %d statement : var_declaration\n\n",yylineno);
		  	 string str=$1->getname();
			 fprintf(logout,"%s",str.c_str());
			 $$->setname(str);}
	  | expression_statement {fprintf(logout,"At line no: %d statement : expression_statement \n\n",yylineno);
	  		 string str=$1->getname();
			 fprintf(logout,"%s",str.c_str());
			 $$->setname(str);}
	  | compound_statement {fprintf(logout,"At line no: %d statement : compound_statement\n\n",yylineno);
	  		 string str=$1->getname();
			 fprintf(logout,"%s",str.c_str());
			 $$->setname(str);
			 $$->code=$1->code;}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {fprintf(logout,"At line no: %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",yylineno);
	  	string str=$1->getname();
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 	        str+=$6->getname();
 		str+=$7->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		
		
							/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code*/
		char *label1=newLabel();
		char *label2=newLabel();			
		$$->code=$3->code;
		$$->code+=string(label1)+":\n";
		$$->code+=$4->code;
		$$->code+="mov ax,"+$4->getSymbol()+"\n";
		$$->code+="cmp ax,0\n";
		$$->code+="je "+string(label2)+"\n";
		$$->code+=$7->code;
		$$->code+=$5->code;
		$$->code+="jmp "+string(label1)+"\n";
		$$->code+=string(label2)+":\n";
		
		
		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{fprintf(logout,"At line no: %d statement : IF LPAREN expression RPAREN statement \n\n",yylineno);
	  		  	
	  	string str=$1->getname();
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
							
		char *label=newLabel();
		$$->code+=$3->code;
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label)+"\n";
		$$->code+=$5->code;
		$$->code+=string(label)+":\n";
					
		$$->setSymbol("if");
		//fprintf(assembly,"%s\n\n",$$->code.c_str());
		
		}
	  | IF LPAREN expression RPAREN statement ELSE statement {fprintf(logout,"At line no: %d statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",yylineno);
	  	string str=$1->getname();
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+=$6->getname();
 		str+=$7->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		
		char *label1=newLabel();
		char *label2=newLabel();
		$$->code+=$3->code;
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label1)+"\n";
		$$->code+=$5->code;
		$$->code+="jmp "+string(label2)+"\n";
		$$->code+=string(label1)+":\n";
		$$->code+=$7->code;
		$$->code+=string(label2)+":\n";
		
		$$->setSymbol("if-else");
		}
	  | WHILE LPAREN expression RPAREN statement {fprintf(logout,"At line no: %d statement : WHILE LPAREN expression RPAREN statement\n\n",yylineno);
	   	string str=$1->getname();
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		
		char *label1=newLabel();
		char *label2=newLabel();			
		$$->code+=string(label1)+":\n";
		$$->code+=$3->code;
		$$->code+="mov ax,"+$3->getSymbol()+"\n";
		$$->code+="cmp ax,0\n";
		$$->code+="je "+string(label2)+"\n";
		$$->code+=$5->code;
		$$->code+="jmp "+string(label1)+"\n";
		$$->code+=string(label2)+":\n";
		
			
	  }//left!!!
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {fprintf(logout,"At line no: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n",yylineno);
	  	string val=$3->getname();
	  	string str=$1->getname();
 		str+=$2->getname();
 		str+=$3->getname();
 		str+=$4->getname();
 		str+=$5->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		
		$$->code+="mov AX, "+val+string(scopeNo(table.getScopeNumber()))+"\n";
		$$->code+="CALL PRINT_\n";
		
		
		
	  }//left!!!!
	  | RETURN expression SEMICOLON {fprintf(logout,"At line no: %d statement : RETURN expression SEMICOLON \n\n",yylineno);
	  	globalRetFlag=1;
	  	string str=$1->getname();
		str+=" ";
 		str+=$2->getname();
 		str+=$3->getname();
 		str+="\n";
 		fprintf(logout,"%s",str.c_str());
		$$->setname(str);
		string t=$2->getType();
		if(t!=func_ret_Type)
		{
		fprintf(errorFile,"Error at line %d: Return expression does not match function return type.\n\n",yylineno);
		error_count++;
		}
		//char *temp=newTemp();
		$$->code+=$2->code;
		//$$->code+="mov ax, "+$2->getSymbol()+"\n";
						if(function != "main"){
								$$->code += "MOV DX, " + $2->getSymbol() + "\n";
								$$->code += "POP BP\n";
								$$->code += "RET \n";
						}


						$$->setSymbol($2->getSymbol());
		//$$->code+="mov "+string(temp)+", ax\n";
		//cout<<"printing: "<<$2->getSymbol()<<endl;
		//$$->setSymbol(temp);
	  }
	  ;
	  
expression_statement 	: SEMICOLON	{fprintf(logout,"At line no: %d expression_statement 	: SEMICOLON	\n\n",yylineno);
			 string str=$1->getname();
			 fprintf(logout,"%s",str.c_str());
			 $$->setname(str);
			}		
			| expression SEMICOLON {fprintf(logout,"At line no: %d expression_statement 	: expression SEMICOLON\n\n",yylineno);
			string str=$1->getname();
			str+=$2->getname();
			str+="\n\n";
			fprintf(logout,"%s",str.c_str());
			$$->setname(str);
			$$->code=$1->code;
			$$->setSymbol($1->getSymbol());}
			;
	  
variable : ID 		{fprintf(logout,"At line no: %d variable : ID \n\n",yylineno);
	fprintf(logout,"%s\n\n",$1->getname().c_str());
	//$$=$1;
	name1=$1->getname();
	SymbolInfo *ret=table.Lookup(name1); 
	if(ret!=NULL){
	type2=ret->getType();
	
	if(ret->indicator=="arr")
	{
		fprintf(errorFile,"Error at line %d: Need array indexing\n\n",yylineno);
		error_count++;
	}
	name1+=string(scopeNo(ret->found_in_scope));
	}
	else 
	{	type2="not specified!!";
		fprintf(errorFile,"Error at line %d: Undeclared variable %s\n\n",yylineno,name1.c_str());
		error_count++;
		
	}

	$$->setname(name1);
	$$->setType(type2);
	$$->indicator="var";
	$$->setSymbol(name1); //+string(scopeNo(ret->found_in_scope))
	$$->code="";
	
	 }
	 | ID LTHIRD expression RTHIRD {fprintf(logout,"At line no: %d variable : ID LTHIRD expression RTHIRD \n\n",yylineno);
	 	name1=$1->getname();
		SymbolInfo *ret=table.Lookup(name1);
	        if(ret!=NULL)
		{
			type2=ret->getType();
			$$->setType(type2);
			string number=$3->getType();
			if(ret->indicator!="arr")
			{
				fprintf(errorFile,"Error at Line %d : No matching array declared for %s\n\n",yylineno,ret->getname().c_str());
				error_count++;
			}
			if(number!="int")
			{
				fprintf(errorFile,"Error at Line %d : Non-integer Array Index\n\n",yylineno);
				error_count++;
			}
			name1+=string(scopeNo(ret->found_in_scope));
		}
		else
		{
			type2="not specified!!";
			$$->setType(type2);
			fprintf(errorFile,"Error at line %d: Undeclared variable %s\n\n",yylineno,name1.c_str());
			error_count++;
		
		}
		$$->code=$3->code+"mov bx, " +$3->getSymbol() +"\nadd bx, bx\n";
		$$->indicator="arr";
		$$->setSymbol(name1); //+string(scopeNo(ret->found_in_scope))
		//fprintf(assembly,"%s\n\n",$$->code.c_str());
	 	string str=$1->getname();
		str+=$2->getname();
		str+=$3->getname();
		str+=$4->getname();
		fprintf(logout,"%s\n\n",str.c_str());
		$$->setname(str);
		//fprintf(logout,"HERE:%s\n\n",name1.c_str());
		}
	 //left!!!
	 ;
	 
 expression : logic_expression	{fprintf(logout,"At line no: %d expression : logic_expression	\n\n",yylineno);
 		//string t=$1->getType();
	     fprintf(logout,"%s\n\n",$1->getname().c_str());
	     /* $$->setname($1->getname());
		$$->setType(t);*/
		$$=$1;
		
	 	 }
	   | variable ASSIGNOP logic_expression 
		{fprintf(logout,"At line no: %d expression :  variable ASSIGNOP logic_expression\n\n",yylineno);//= HERE!!!!
		
		
		type1=$1->getType();
		type2=$3->getType();
		string str=$1->getname();
		str+=$2->getname();
		str+=$3->getname();
		fprintf(logout,"%s\n\n",str.c_str());
		$$->setname(str);
		//SEMANTIC ERROR GENERATION!!
		if(type1=="int" && type2=="float")
		{
			fprintf(errorFile,"%s %s\n",type1.c_str(),type2.c_str());
			fprintf(errorFile,"Error at line %d : Type Mismatch \n\n",yylineno);
			error_count++;
		}
		else if(type2=="int" && type1=="float")
		{
			fprintf(errorFile,"%s %s\n",type1.c_str(),type2.c_str());
			fprintf(errorFile,"Error at line %d : Type Mismatch \n\n",yylineno);
			error_count++;
		}
		 else if( type2=="void")
     		{
     			     	fprintf(errorFile,"Here: Error at line: %d : Function returns void\n\n",yylineno);
     				error_count++;
     		}
		
		$$->code=$3->code+$1->code;
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		if($$->indicator=="var"){ 
		$$->code+= "mov "+$1->getSymbol()+", ax\n";
		}
				
		else if($$->indicator=="arr"){
		$$->code+= "mov  "+$1->getSymbol()+"[bx], ax\n";
		}		
		//fprintf(assembly,"%s\n\n",$$->code.c_str());
		}
		
		
	   	
	   ;
			
logic_expression : rel_expression {fprintf(logout,"At line no: %d logic_expression : rel_expression\n\n",yylineno);
		string t=$1->getType();
		//fprintf(errorFile,"rel expression: %s\n\n",t.c_str());
	 	 fprintf(logout,"%s\n\n",$1->getname().c_str());
	 	/* $$->setname($1->getname());
 		 $$->setType(t);*/
 		$$=$1;
	 	 
	 	 }	
		 | rel_expression LOGICOP rel_expression {fprintf(logout,"At line no: %d logic_expression : rel_expression LOGICOP rel_expression \n\n",yylineno);
		 	string op=$2->getname();
		 	string part1=$1->getSymbol();
		 	string part2=$3->getSymbol();
		 	string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
			$$->setType("int");
		        type3=$1->getType();
			type4=$3->getType();
		        if(type3=="void"||type4=="void")
		  	{
		  		fprintf(errorFile,"Error at line: %d : Void return type.\n\n",yylineno);
		  	}
		  	char *temp=newTemp();
			char *label1=newLabel();
			char *label2=newLabel();
			char *label3=newLabel();
			if(op=="&&")
			{
				$$->code+=$1->code;
				$$->code+=$3->code;
				$$->code+="mov ax,"+part1+"\n";
				$$->code+="mov bx,"+part2+"\n";
				$$->code+="cmp ax,1\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="mov "+string(temp)+", 0\n";
				$$->code+="jmp "+string(label3)+"\n";
				$$->code+=string(label1)+":\ncmp bx, 1\nje "+string(label2)+"\nmov "+string(temp)+", 0\njmp "+string(label3)+"\n";
				$$->code+=string(label2)+":\nmov "+string(temp)+", 1\n"+string(label3)+":\n";
				$$->setSymbol(temp);
			}
			else if(op=="||")
			{
				$$->code+=$1->code;
				$$->code+=$3->code;
				$$->code+="mov ax, "+part1+"\n";
				$$->code+="cmp ax,1\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="mov ax, "+part2+"\n";
				$$->code+="cmp ax,1\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="jmp "+string(label2)+"\n";
				$$->code+=string(label1)+":\n";
				$$->code+="mov "+string(temp)+", 1\n";
				$$->code+="jmp "+string(label3)+"\n";
				$$->code+=string(label2)+":\n";
				$$->code+="mov "+string(temp)+", 0\n";
				$$->code+=string(label3)+":\n";
				
				$$->setSymbol(temp);
			}

}	
		 ;
			
rel_expression	: simple_expression {fprintf(logout,"At line no: %d rel_expression	: simple_expression \n\n",yylineno);

		//fprintf(errorFile,"simple expression: %s\n\n",$1->getType().c_str());
	 	 fprintf(logout,"%s\n\n",$1->getname().c_str());
	 	/* $$->setname($1->getname());
	 	 $$->setType($1->getType());*/
	 	 $$=$1;
	 	 
		}
		| simple_expression RELOP simple_expression {fprintf(logout,"At line no: %d rel_expression	:  simple_expression RELOP simple_expression \n\n",yylineno);
		        type3=$1->getType();
			type4=$3->getType();
			string op=$2->getname();
			$$->setType("int");
		        if(type3=="void"||type4=="void")
		  	{
		  		fprintf(errorFile,"Error at line: %d : Void return type.\n\n",yylineno);
		  	}


			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	
		  					
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->getSymbol()+"\n";
				$$->code+="cmp ax, " + $3->getSymbol()+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				if(op=="<"){
					$$->code+="jl " + string(label1)+"\n";
				}
				else if(op=="<="){
				$$->code+="jle " + string(label1)+"\n";
				}
				else if(op==">"){
				$$->code+="jg " + string(label1)+"\n";
				}
				else if(op==">="){
				$$->code+="jge " + string(label1)+"\n";
				}
				else if(op=="=="){
				$$->code+="je " + string(label1)+"\n";
				}
				else{
				}
				
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->setSymbol(temp);
				//fprintf(assembly,"%s\n\n",$$->code.c_str());
		  	
		}	
		;
				
simple_expression : term {fprintf(logout,"At line no: %d simple_expression : term \n\n",yylineno);
//fprintf(errorFile,"term: %s\n\n",$1->getType().c_str());
	fprintf(logout,"%s\n\n",$1->getname().c_str());	
	$$->setname($1->getname());
	$$->setType($1->getType());
	$$->setSymbol($1->getSymbol());
	//cout<<"hello here: "<<$$->getSymbol()<<endl;
	$$->code=$1->code;
	//$$=$1;
	}
		  | simple_expression ADDOP term {fprintf(logout,"At line no: %d simple_expression : simple_expression ADDOP term \n\n",yylineno);
		       	string part1=$1->getSymbol();
     			string part2=$3->getSymbol();
     			string op=$2->getname();
		 	type3=$1->getType();
			type4=$3->getType();
			if(type3=="float"||type4=="float")
			{
				$$->setType("float");
			}
			else if(type3=="int" && type4=="int")
			{
				$$->setType("int");
			}
			else if(type3=="void" || type4=="void")
     			{
     			     	//fprintf(errorFile,"Error at line: %d : Function returns void\n\n",yylineno);
				$$->setType("void");
     				//error_count++;
     			}
			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
			$$->code=$3->code+$1->code;
			//cout<<"here!!"<<$$->code<<" "<<part1<<" "<<part2<<endl;
			char *temp=newTemp();
			if(op=="+"){
			$$->code+="mov ax, "+part1+"\n";
			$$->code+="mov bx, "+part2+"\n";
			$$->code+="add ax,bx\n";
			$$->code+="mov "+string(temp)+", ax\n";
			$$->setSymbol(temp);
				
				}		  	
				
			else if(op=="-")
			{
			$$->code+="mov ax, "+part1+"\n";
			$$->code+="mov bx, "+part2+"\n";
			$$->code+="sub ax,bx\n";
			$$->code+="mov "+string(temp)+", ax\n";
			$$->setSymbol(temp);
				
			}	
				
		        $$->setname(str);
			

	 	 }
		  ;
					
term :	unary_expression {fprintf(logout,"At line no: %d term : unary_expression \n\n",yylineno);

	fprintf(logout,"%s\n\n",$1->getname().c_str());	

	$$=$1;
	//cout<<"term: "<<$$->code<<endl;	
	}
     |  term MULOP unary_expression {
     		type3=$1->getType();
		type4=$3->getType();
     		string mod=$2->getname();

     		
     		if(type3=="void" || type4=="void")
     		{

     				$$->setType("void");
     		}
     		else{
     		if(mod=="%")
     		{
     			if(type3=="int" && type4=="float")
     			{
     				fprintf(errorFile,"Error at line: %d : Integer operand on modulus operator\n\n",yylineno);
     				error_count++;
     			}
     			else if(type4=="int" && type3=="float")
     			{
     				fprintf(errorFile,"Error at line: %d : Integer operand on modulus operator\n\n",yylineno);
     				error_count++;
     			}
     			else if(type4=="float" && type3=="float")
     			{
     				fprintf(errorFile,"Error at line: %d : Integer operand on modulus operator\n\n",yylineno);
     				error_count++;
     			}
			$$->setType("int");
     		}
     		
		else if(mod=="*")
		{	if(type3=="float"||type4=="float")
			{
				$$->setType("float");
			}
			else if(type3=="int" && type4=="int")
			{
				$$->setType("int");
			}
			
     		}
     		}
		fprintf(logout,"At line no: %d term :  term MULOP unary_expression \n\n",yylineno);
     			string part1=$1->getSymbol();
     			string part2=$3->getSymbol();
     			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	
			$$->code= $3->code+$1->code;
			$$->code += "mov ax, "+ part1+"\n";
			$$->code += "mov bx, "+ part2 +"\n";
			char *temp=newTemp();
			if(mod=="*"){
				$$->code += "mul bx\n";
				$$->code += "mov "+ string(temp) + ", ax\n";
			}
			else if(mod=="/"){
				$$->code+="XOR dx,dx\n";
				$$->code+="mov bx, "+part1+"\n";		// clear dx, perform 'div bx' and mov ax to temp
				$$->code+="mov ax, "+part2+"\n";
				$$->code+="div bx\n";
				$$->code+="mov "+string(temp)+", ax\n";
				$$->setSymbol(string(temp));
											
			}
			else{			
			        $$->code+="XOR dx,dx\n";		// clear dx, perform 'div bx' and mov dx to temp
				$$->code+="mov bx, "+part1+"\n";		
				$$->code+="mov ax, "+part2+"\n";
				$$->code+="div bx\n";
				$$->code+="mov "+string(temp)+", dx\n";
				$$->setSymbol(string(temp));
			}
			$$->setSymbol(temp);

     }
     ;

unary_expression : ADDOP unary_expression  {fprintf(logout,"At line no: %d unary_expression : ADDOP unary_expression\n\n",yylineno);
			string op=$1->getname();
			string part1=$2->getSymbol();
			string str=$1->getname();
			str+=$2->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	
		  	$$->setType($2->getType());
		  	if($2->getType()=="void")
		  	{
		  		
		  		$$->setType("void");
		  		//error_count++;
		  	}
		  	$$->code=$2->code;
		  	if(op=="+")
		  	{
		  		$$->setSymbol($2->getSymbol());

		  	}
		  	else if(op=="-")
		  	{
		  		char *temp=newTemp();
				$$->code="mov ax, " + $2->getSymbol() + "\n";
				$$->code+="not ax\n";
				$$->code+="mov "+string(temp)+", ax\n";
				$$->setSymbol(string(temp));
		  	}
		  	
		  	}
		 | NOT unary_expression {fprintf(logout,"At line no: %d unary_expression : NOT unary_expression\n\n",yylineno);
		 	string str=$1->getname();
			str+=$2->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->setType($2->getType());
		  	if($2->getType()=="void")
		  	{
		  		//fprintf(errorFile,"Error at line: %d : Function returns void.\n\n",yylineno);
		  		$$->setType("void");
		  		//error_count++;
		  	}
		  	
			char *temp=newTemp();
			$$->code=$2->code;
			$$->code="mov ax, " + $2->getSymbol() + "\n";
			$$->code+="not ax\n";
			$$->code+="mov "+string(temp)+", ax";
			$$->setSymbol(temp);		  	
		  	
		  	}
		 | factor {fprintf(logout,"At line no: %d unary_expression : factor\n\n",yylineno);
		 //fprintf(errorFile,"factor: %s\n\n",$1->getType().c_str());
		 	fprintf(logout,"%s \n\n",$1->getname().c_str());
		 	//$$=$1;
		 	$$->setname($1->getname());
		 	$$->setType($1->getType());
		 	$$->code=$1->code;
		 	$$->symbol=$1->symbol;
		 	//cout<<"hello here 2: "<<$$->code<<endl;
		 	}
		 ;
	
factor	: variable {fprintf(logout,"At line no: %d factor : variable\n\n",yylineno);
		
	fprintf(logout,"%s\n\n",$1->getname().c_str());	
	//$$=$1;
	$$->setname($1->getname());
	
	$$->setType(type2);
	//cout<<"type:"<<$$->indicator<<endl;
	if($$->indicator=="var"){
			char *temp= newTemp();
			$$->code+="mov ax, " + $1->getSymbol() + "\n";
			$$->code+= "mov " + string(temp) + ", ax\n";
			$$->setSymbol(temp);				
			}
			
	else{
			char *temp= newTemp();
			//cout<<"here"<<$1->getname()<<$1->getType()<<endl;
			$$->code+="mov ax, " + $1->getSymbol() + "[bx]\n";
			$$->code+= "mov " + string(temp) + ", ax\n";
			$$->setSymbol(temp);
		}
		//cout<<"hello here: 3"<<$$->code<<endl;
		}
	| ID LPAREN argument_list RPAREN {fprintf(logout,"At line no: %d factor : ID LPAREN argument_list RPAREN\n\n",yylineno);
			string func_name=$1->getname();
			string name2=$1->getname();
			SymbolInfo *ret=table.Lookup(name2); 
			if(ret!=NULL)
			{
				type2=ret->getType();
				$$->setType(type2);
				//fprintf(errorFile,"%s\n\n",type2.c_str());
				if(ret->indicator=="var" )
				{
					fprintf(errorFile,"Error at line %d: No matching function found, %s is a variable\n\n",yylineno, name2.c_str());
					error_count++;
				}
				else if(ret->indicator=="arr" )
				{
					fprintf(errorFile,"Error at line %d: No matching function found, %s is an array.\n\n",yylineno,name2.c_str());
					error_count++;
				}
				
				else if(ret->indicator=="func" && ret->func_dec_def=="dec")
				{
					fprintf(errorFile,"Error at line %d: Function definition required\n\n",yylineno);
					error_count++;
				}
				else if(ret->indicator=="func" && ret->func_dec_def=="def")
				{
					vector <parameter> list3=ret->parameterList;
					if(list3.size()!=arg_type_list.size())
					{
						fprintf(errorFile,"Error at line %d: Function call does not match function definition, incompatible number of parameters.\n\n",yylineno);
						error_count++;
					}
					else{
					
					for(int i=0;i<arg_type_list.size();i++)
					{
						
						if(arg_type_list[i]!=list3[i].type)
						{
							
							fprintf(errorFile,"Error at line %d: Arguments do not match function declaration, incompatible parameter types\n\n",yylineno);
							error_count++;
						}
					}
					}
				}
			}
			else
			{
				$$->setType("not specified\n\n");
				fprintf(errorFile,"Error at line %d: Undeclared function\n\n",yylineno);
				error_count++;
			}
			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			str+=$4->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	
		  	$$->code=$3->code;
		  	$$->code+="CALL "+func_name+"\n";
		  	/*if(globalRetFlag==1)
		  	{
		  	char *temp= newTemp();
		  	//$$->code+="POP AX\n";
		  	$$->code+="mov "+string(temp)+", ax\n";
		  	$$->setSymbol(string(temp));
		  	globalRetFlag=0;
		  	}*/
		  		char *temp= newTemp();			
				$$->code += "MOV " + string(temp) + ",DX\n"; // Return statement e DX e set kore dite hobe
				$$->setSymbol(string(temp));
		/*for(int i=0;i<arg_type_list.size();i++)
		{
		     $$->code+="POP CX\n";
		}*/
		  	
		  	
		  	
		  	
		  	}
	|ID LPAREN RPAREN{ fprintf(logout,"At line no: %d factor : ID LPAREN RPAREN\n\n",yylineno);
			string func_name=$1->getname();
			string name2=$1->getname();
			SymbolInfo *ret=table.Lookup(name2); 
			if(ret!=NULL)
			{
				type2=ret->getType();
				$$->setType(type2);
				//fprintf(errorFile,"%s\n\n",type2.c_str());
				if(ret->indicator=="var" )
				{
					fprintf(errorFile,"Error at line %d: No matching function found, %s is a variable\n\n",yylineno, name2.c_str());
					error_count++;
				}
				else if(ret->indicator=="arr" )
				{
					fprintf(errorFile,"Error at line %d: No matching function found, %s is an array.\n\n",yylineno,name2.c_str());
					error_count++;
				}
				
				else if(ret->indicator=="func" && ret->func_dec_def=="dec")
				{
					fprintf(errorFile,"Error at line %d: Function definition required\n\n",yylineno);
					error_count++;
				}
				else if(ret->indicator=="func" && ret->func_dec_def=="def")
				{
					vector <parameter> list3=ret->parameterList;
					//fprintf(errorFile,"Checking here: %d \n\n",list3.size());
					if(list3.size()!=0)
					{
						fprintf(errorFile,"Error at line %d: Function call does not match function definition, incompatible number of parameters.\n\n",yylineno);
						error_count++;
					}
				}
			}
			else
			{
				$$->setType("not specified\n\n");
				fprintf(errorFile,"Error at line %d: Undeclared function\n\n",yylineno);
				error_count++;
			}
			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->code+="CALL "+func_name+"\n";
		  	/*if(globalRetFlag==1)
		  	{
		  	char *temp= newTemp();
		  	$$->code+="POP AX\n";
		  	$$->code+="mov "+string(temp)+", ax\n";
		  	$$->setSymbol(string(temp));
		  	globalRetFlag=0;*/
		  	char *temp = newTemp();

				
				$$->code += "MOV " + string(temp) + ",DX\n"; // Return statement e DX e set kore dite hobe
				$$->setSymbol(string(temp));
				
		  }
		  	
		  	
	
	
	| LPAREN expression RPAREN {fprintf(logout,"At line no: %d factor : LPAREN expression RPAREN\n\n",yylineno);
			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->setType($2->getType());
		  	$$->code=$2->code;
		  	$$->symbol=$2->symbol;
			}
	| CONST_INT {fprintf(logout,"At line no: %d factor : CONST_INT\n\n",yylineno);
	fprintf(logout,"%s\n\n",$1->getname().c_str());
	$$=$1;
	$$->setType("int");
	$$->setSymbol($1->getname());
	}
	| CONST_FLOAT {fprintf(logout,"At line no: %d factor	: CONST_FLOAT \n\n",yylineno);
         fprintf(logout,"%s\n\n",$1->getname().c_str());	
	$$=$1;
	$$->setType("float");
	}
	| variable INCOP {fprintf(logout,"At line no: %d factor : variable INCOP \n\n",yylineno);
			string val=$1->getname();
			string str=$1->getname();
			str+=$2->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->setType(type2);
		  	$$->code=$1->code;
		  	if($$->indicator=="var"){ 
				$$->code+= "mov ax, "+$1->getSymbol()+"\n";
			}
				
			else if($$->indicator=="arr"){
				$$->code+= "mov  ax,"+$1->getSymbol()+"[bx]\n";
			}

			$$->code+="inc ax\n";
			$$->code+="mov "+val+", ax\n";
			$$->setSymbol(val);	  	
		  	

		  	}
	| variable DECOP {fprintf(logout,"At line no: %d factor : variable DECOP\n\n",yylineno);
			string val=$1->getname();
			string str=$1->getname();
			str+=$2->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	$$->setType(type2);
			
		  	$$->code=$1->code;
		  	if($$->indicator=="var"){ 
				$$->code+= "mov ax, "+$1->getSymbol()+"\n";
			}
				
			else if($$->indicator=="arr"){
				$$->code+= "mov  ax,"+$1->getSymbol()+"[bx]\n";
			}
			
			
			$$->code+="dec ax\n";
			$$->code+="mov "+val+", ax\n";
			$$->setSymbol(val);	  	
		  	


}
	;
	
argument_list : arguments {fprintf(logout,"At line no: %d argument_list : arguments\n\n",yylineno);
		string str=$1->getname();
		fprintf(logout,"%s\n\n",str.c_str());
		$$->setname(str);
		$$->code=$1->code;
		};
			  
	
arguments : arguments COMMA logic_expression {fprintf(logout,"At line no: %d arguments : arguments COMMA logic_expression \n\n",yylineno);
			
			string t=$1->getType();
			string str=$1->getname();
			str+=$2->getname();
			str+=$3->getname();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	arg_type_list.push_back(t);
		  	$$->code=$1->code+$3->code;
		  	
		  	$$->code+="mov ax, "+$3->getSymbol()+"\n";
		  	
		  	$$->code+="push ax\n";
		  	}
	      | logic_expression {fprintf(logout,"At line no: %d arguments : logic_expression \n\n",yylineno);
	      		string str=$1->getname();
	      		string t=$1->getType();
			fprintf(logout,"%s\n\n",str.c_str());
		  	$$->setname(str);
		  	arg_type_list.clear();
		  	arg_type_list.push_back(t);
		  	$$->code=$1->code;
		  	
		  	$$->code+="mov ax, "+$1->getSymbol()+"\n";
		  	$$->code+="push ax\n";
		  	}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	
	logout= fopen("log.txt","w");

	errorFile= fopen("error.txt","w");
	assembly=fopen("code.txt","w");
	
	yyin=fp;
	yyparse();

	//fprintf(logout,"Total Lines: %d\nTotal Errors: %d\n",line_count,error_count);
	//table.PrintCurrentScopeTable();
	fprintf(logout,"Total Lines:%d\n\n",yylineno);
	fprintf(logout,"Total Semantic Errors:%d\n\n",error_count);
	fprintf(errorFile,"Total Semantic Errors:%d\n\n",error_count);
	fprintf(errorFile,"Total Syntax Errors:%d\n\n",syntax_error);
	fclose(yyin);
	fclose(errorFile);
	fclose(logout);
	return 0;
	
}



