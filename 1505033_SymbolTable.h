
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>

#include<stdio.h>
#include<iostream>
#include<fstream>

using namespace std;


class position
{
public:
    int x;
    int y;
};

class parameter
{
public:
	string type;
	string name;
	int flag;

	parameter(string t,string n)
	{
		type=t;
		name=n;
		flag=2;
	}
	parameter(string t)
	{
		type=t;
		flag=1;
	}
};


class SymbolInfo
{
   public:
         string name;
         string type;
         string indicator;
	string func_dec_def;
    	int arrayIndex;
	string code;
	string symbol;
	int found_in_scope;
	vector <parameter> parameterList;
	int number_of_parameters;
    	
        SymbolInfo * next;
        SymbolInfo()
        {
        	name="";
        	type="";
        	code="";
        	symbol="";
        }
	SymbolInfo(string n, string t)
	{
		name=n;
		type=t;
	}
	
        void setname(string Name)
        {
            this->name=Name;
        }
        string getname()
        {
            return this->name;
        }
        void setType(string Type)
        {
            this->type=Type;

        }
        string getType()
        {
            return this->type;
        }
        string getSymbol()
        {
        	return this->symbol;
        }
        void setSymbol(string symbol)
        {
        this->symbol=symbol;
        }

};

class ScopeTable
{
    SymbolInfo **hashtable;
    int no_of_buckets;
    public:

    ScopeTable *parent;
    int scopeNumber=0;

    SymbolInfo * Lookup(SymbolInfo element);

    ScopeTable(int n)
    {
        no_of_buckets=n;
        hashtable=new SymbolInfo*[no_of_buckets];
        for(int i=0; i<no_of_buckets; i++)
        {
            hashtable[i]=NULL;
        }

    }


    ~ScopeTable()
    {
        //printf("Entering destructor\n");
        delete [] hashtable;
        //printf("Exiting destructor\n");

    }

    unsigned int hashfunction(string str)
    {
        unsigned long hash = 5381;
            int c;
            int i=0;

            while (i<str.length())
            {
                c=(int)str[i];
                hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
                i++;
            }

            return (hash%no_of_buckets);
    }


    SymbolInfo makeSymbolInfo(string name, string type)
    {
        SymbolInfo ret;
        ret.setname(name);
        ret.setType(type);

        return ret;
    }

    position FindPosition(string str_name)
    {
       // SymbolInfo * p=Lookup(str_name);
        //if(p!=NULL)
        //{
            position ret;
            int hashidx=hashfunction(str_name);
            ret.x=hashidx;
            int y=0;
            SymbolInfo *head=hashtable[hashidx];
            while(head!=NULL)
            {
                if(head->getname()==str_name)//&& head->getType()==str_type)
                {
                    break;
                }
                head=head->next;
                y++;
            }
            ret.y=y;
            return ret;

        //}


    }

    bool Insert(string ind, int arr_index,string str_name, string str_type)
    {

        //string str_name=element.getname();
        //string str_type=element.getType();
        int hashidx=hashfunction(str_name);

        SymbolInfo * p=Lookup(str_name);
        if(p!=NULL)
        {
            return false;
        }

        if(hashtable[hashidx]==NULL)
        {
            hashtable[hashidx]=new SymbolInfo();
            hashtable[hashidx]->setname(str_name);
            hashtable[hashidx]->setType(str_type);
            hashtable[hashidx]->indicator=ind;
            hashtable[hashidx]->arrayIndex=arr_index;
            hashtable[hashidx]->found_in_scope=scopeNumber;
            hashtable[hashidx]->next=NULL;
            return true;

        }

        else
        {
            SymbolInfo *head=hashtable[hashidx];
            SymbolInfo *prev=NULL;
            while(head!=NULL)
            {
                prev=head;
                head=head->next;
                //CAN WE INSERT TWO INSTANCES OF THE SAME VARIABLE??
            }
            //printf("2\n");
            prev->next=new SymbolInfo();
            prev->next->setname(str_name);
            prev->next->setType(str_type);
            hashtable[hashidx]->indicator=ind;
            hashtable[hashidx]->arrayIndex=arr_index;
            hashtable[hashidx]->found_in_scope=scopeNumber;
            prev->next->next=NULL;

            //cout<<prev->next->getname()<<endl;
            return true;

        }

    }
    
    
    bool Insert_func(string str_name, string str_type,vector <parameter> list,int no_of_parameters,string f)
    {

        //string str_name=element.getname();
        //string str_type=element.getType();
        int hashidx=hashfunction(str_name);

        SymbolInfo * p=Lookup(str_name);
        if(p!=NULL)
        {
            return false;
        }

        if(hashtable[hashidx]==NULL)
        {
            hashtable[hashidx]=new SymbolInfo();
            hashtable[hashidx]->setname(str_name);
            hashtable[hashidx]->setType(str_type);
            hashtable[hashidx]->indicator="func";
            hashtable[hashidx]->arrayIndex=0;
            hashtable[hashidx]->parameterList=list;
            hashtable[hashidx]->number_of_parameters=no_of_parameters;	
	    hashtable[hashidx]->func_dec_def=f;
            hashtable[hashidx]->next=NULL;
            return true;

        }

        else
        {
            SymbolInfo *head=hashtable[hashidx];
            SymbolInfo *prev=NULL;
            while(head!=NULL)
            {
                prev=head;
                head=head->next;
                //CAN WE INSERT TWO INSTANCES OF THE SAME VARIABLE??
            }
            //printf("2\n");
            prev->next=new SymbolInfo();
            prev->next->setname(str_name);
            prev->next->setType(str_type);
            hashtable[hashidx]->indicator="func";
            hashtable[hashidx]->arrayIndex=0;
            hashtable[hashidx]->parameterList=list;
            hashtable[hashidx]->number_of_parameters=no_of_parameters;
            hashtable[hashidx]->func_dec_def=f;
            prev->next->next=NULL;

            //cout<<prev->next->getname()<<endl;
            return true;

        }

    }

    SymbolInfo * Lookup(/*SymbolInfo element*/string str_name)
    {
       // string str_name=element.getname();
       // string str_type=element.getType();
        int hashidx=hashfunction(str_name);
        SymbolInfo *head=hashtable[hashidx];
        while(head!=NULL)
        {
            if(head->getname()==str_name)//&& head->getType()==str_type)
            {
                position p=FindPosition(str_name);
                //printf("Found in ScopeTable# %d at position %d,%d\n",scopeNumber,p.x,p.y);
                return head;
            }
            head=head->next;
        }
        return NULL;
    }



    bool Delete(/*SymbolInfo element*/string str_name)
    {
        int hashidx=hashfunction(str_name);
        SymbolInfo *head=hashtable[hashidx];
        int f=0;
        position p;
        while(head!=NULL)
        {
            if(head->getname()==str_name)//&& head->getType()==str_type)
            {
                p=FindPosition(str_name);
                //printf("Found in ScopeTable# %d at position %d,%d\n",scopeNumber,p.x,p.y);
                f=1;
                break;
            }
            head=head->next;
        }

        //SymbolInfo * p=Lookup(str_name);
        if(f==0)
        {
            //printf("Not Found\n");
            return false;

        }
        else
        {
            int flag=0;
            //printf("Here in else\n");
            //string str_name=element.getname();
            //string str_type=element.getType();
            int hashidx=hashfunction(str_name);
            SymbolInfo *head=hashtable[hashidx];
            SymbolInfo *prev=NULL;
            while(head!=NULL)
            {

                if(head->getname()==str_name /*&& head->getType()==str_type*/)
                {
                    flag=1;
                    break;
                }
                prev=head;
                head=head->next;


            }

            if(flag==1){
            if(prev==NULL && head==hashtable[hashidx])
            {
                //printf("1\n");
                SymbolInfo * firstElement=head->next;
                hashtable[hashidx]=firstElement;
                delete head;
               // printf("Deleted entry at %d, %d from current ScopeTable\n",p.x, p.y);
                return true;
            }
            else
            {
                prev->next=head->next;
                delete head;
                //printf("Deleted entry at %d, %d from current ScopeTable\n",p.x,p.y);
                return true;
            }

        }

    }
}

    void Print(FILE *logout)
    {
        fprintf(logout,"ScopeTable# %d\n",scopeNumber);
        for(int i=0;i<no_of_buckets;i++)
        {
            //fprintf(logout,"%d--> ",i);
            if(hashtable[i]!=NULL)
            {
                fprintf(logout,"%d--> ",i);
                SymbolInfo *head=hashtable[i];
                while(head!=NULL)
                {
                    //cout << "< "<<head->getname() <<": "<<head->getType()<<" >  ";
                    string ind=head->indicator;
                    int index=head->arrayIndex;
                    string name=head->getname();
                    string type=head->getType();
                    
                    if(ind=="func")
                    {
                    	fprintf(logout,"< %s: %s,%s,%d >",name.c_str(),type.c_str(),ind.c_str(),head->number_of_parameters);
                    }
                    else
                    {
                    	fprintf(logout,"< %s: %s,%s,%d >",name.c_str(),type.c_str(),ind.c_str(),index);
                    }
                    head=head->next;
                }
		fprintf(logout,"\n");

            }
            //fprintf(logout,"\n");
            //cout<<endl;
        }
    }

};



class SymbolTable
{
    ScopeTable *current=NULL;
    int buckets_per_table;
    int num;
    public:

    SymbolTable(int n)
    {
	num=1;
        buckets_per_table=n;
        current=new ScopeTable(buckets_per_table);
        current->parent=NULL;
        current->scopeNumber=num;

    }
    int getScopeNumber()
    {
    	return current->scopeNumber; 
    }	
    void EnterScope(FILE *logout)
    {
    	
	if(current!=NULL)
        {ScopeTable *newParent=current;
        current=new ScopeTable(buckets_per_table);
        current->parent=newParent;
	num=num+1;
        current->scopeNumber=num;

        fprintf(logout,"New ScopeTable with id %d created\n",current->scopeNumber);}
        else
        {
       		 current=new ScopeTable(buckets_per_table);
        	 current->parent=NULL;
        	 current->scopeNumber=1;
		 num=1;
        	 fprintf(logout,"New ScopeTable with id %d created\n",current->scopeNumber);
        }

    }

    void ExitScope(FILE *logout)
    {
        if(current!=NULL)
        {
            int id=current->scopeNumber;
            ScopeTable *head=current->parent;
            delete current;
            current=head;
            fprintf(logout," ScopeTable with id %d removed\n",id);
        }
        else
        {
            fprintf(logout,"No Scope Table instantiated yet.\n");
        }

    }

    void Insert(string indicator, int arr_index, string name, string type,FILE *logout)
    {
        if(current!=NULL)
        {
            //SymbolInfo element=current->makeSymbolInfo(name,type);
            bool r=current->Insert(indicator,arr_index,name,type);
            if(r==true)
            {
                position ret=current->FindPosition(name);
                fprintf(logout,"Inserted in ScopeTable# %d at position %d,%d\n",current->scopeNumber,ret.x,ret.y);
            }
            else
            {
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in current scope table"<<endl;
                fprintf(logout,"id with name: %s, type: %s already exists in current scopetable.\n",name.c_str(),type.c_str());
            }


        }
        else
        {
            //EnterScope();
            //printf("No Scope Table instantiated yet.\n");
            current=new ScopeTable(buckets_per_table);
            current->parent=NULL;
            current->scopeNumber=1;
            bool r=current->Insert(indicator,arr_index,name,type);
            if(r==true)
            {
                position ret=current->FindPosition(name);
                fprintf(logout,"Inserted in ScopeTable# %d at position %d,%d\n",current->scopeNumber,ret.x,ret.y);
            }
            else
            {
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in current scope table"<<endl;
                fprintf(logout,"id with name: %s, type: %s already exists in current scopetable.\n",name.c_str(),type.c_str());
            }


        }
    }
    
    
    void InsertFunction( string name, string ret_type,vector<parameter> list,int no_of_parameters,FILE *logout,string f)
    {
        if(current!=NULL)
        {
            //SymbolInfo element=current->makeSymbolInfo(name,type);
            bool r=current->Insert_func(name,ret_type,list,no_of_parameters,f);
            if(r==true)
            {
                position ret=current->FindPosition(name);
                fprintf(logout,"Inserted in ScopeTable# %d at position %d,%d\n",current->scopeNumber,ret.x,ret.y);
            }
            else
            {
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in current scope table"<<endl;
                fprintf(logout,"function with name: %s, return type: %s already exists in current scopetable.\n",name.c_str(),ret_type.c_str());
            }


        }
        else
        {
            //EnterScope();
            //printf("No Scope Table instantiated yet.\n");
            current=new ScopeTable(buckets_per_table);
            current->parent=NULL;
            current->scopeNumber=1;
            bool r=current->Insert_func(name,ret_type,list,no_of_parameters,f);
            if(r==true)
            {
                position ret=current->FindPosition(name);
                fprintf(logout,"Inserted in ScopeTable# %d at position %d,%d\n",current->scopeNumber,ret.x,ret.y);
            }
            else
            {
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in current scope table"<<endl;
                fprintf(logout,"function with name: %s, return type: %s already exists in current scopetable.\n",name.c_str(),ret_type.c_str());
            }


        }
    }
    void Remove(string name)
    {

        bool ret=current->Delete(name);
        if(ret==false)
        {
            //cout<<name;
            //printf(" not found\n");
        }

    }
	
    SymbolInfo *Lookup_currentScope(string name)
    {
    	ScopeTable *head=current;
        SymbolInfo *ret;
        ret=head->Lookup(name);
        if(ret!=NULL)
        {

            return ret;
        }
        else
        {
        	return NULL;
        }
    }	
	
    SymbolInfo *Lookup(string name)
    {
        ScopeTable *head=current;
        SymbolInfo *ret;
        while(head!=NULL)
        {
            //SymbolInfo element=head->makeSymbolInfo(name,type);
            ret=head->Lookup(name);
            if(ret!=NULL)
            {

                return ret;
            }
            else
            {
                head=head->parent;
            }
        }
        //printf("Not Found\n\n");
        return NULL;
    }

    void PrintCurrentScopeTable(FILE *logout)
    {
        current->Print(logout);
        fprintf(logout,"\n");

    }

    void PrintAllScopeTables(FILE *logout)
    {
        ScopeTable *head=current;

        while(head!=NULL)
        {
            head->Print(logout);
            fprintf(logout,"\n\n");
            head=head->parent;
        }
    }
};

