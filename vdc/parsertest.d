// This file is part of Visual D
//
// Visual D integrates the D programming language into Visual Studio
// Copyright (c) 2010-2011 by Rainer Schuetze, All Rights Reserved
//
// License for redistribution is given by the Artistic License 2.0
// see file LICENSE for further details

module parsertest;

version(MAIN)
{

import util;
import semantic;
import simplelexer;
import parser.engine;
import parser.mod;

import ast = ast.all;

import std.exception;
import std.stdio;
import std.string;
import std.conv;
import std.file;
import std.path;

////////////////////////////////////////////////////////////////

ast.Node parse(TokenId[ ] tokens)
{
	Parser p = new Parser;
	p.pushState(&Module.enter);
	
	foreach(tok; tokens)
	{
		p.lexerTok.id = tok;
		p.shift(p.lexerTok);
	}
	
	if(!p.shiftEOF())
		return null;
	
	return p.popNode();
}

version(none)
unittest
{
	TokenId[] tokens = [ TOK_Identifier, TOK_assign, TOK_null ];
	Node n = parse(tokens);
	assert(n);
	n.print(0);

	tokens = [ TOK_Identifier, TOK_assign, TOK_null, TOK_addass, TOK_this ];
	n = parse(tokens);
	assert(n);
	n.print(0);
	
	tokens = [ TOK_Identifier, TOK_min,  TOK_null, TOK_add,      TOK_this ];
	n = parse(tokens);
	assert(n);
	n.print(0);
}

void testParse(string txt, string filename = "")
{
	Parser p = new Parser;
	ast.Node n;
	try
	{
		p.filename = filename;
		n = p.parseText(txt);
	}
	catch(ParseException e)
	{
		writeln(e.msg);
		return;
	}

	debug
	{
	string app;
	DCodeWriter writer = new DCodeWriter(getStringSink(app));
	writer(n);

	version(log)
	{
		writeln("########################################");
		writeln(app);
		writeln(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	}

	if(filename.length)
	{
		string ofile1 = "c:/tmp/d/a1/" ~ basename(filename);
		std.file.write(ofile1, app);
	}
	
	p.filename = filename ~ "_D";
	ast.Node n2 = p.parseText(app);

version(all)
{	
	bool eq = n.compare(n2);
	assert(eq);
}
else
{
	string app2;
	DCodeWriter writer2 = new DCodeWriter(getStringSink(app2));
	writer2(n2);
	
	if(filename.length)
	{
		string ofile2 = "c:/tmp/d/a2/" ~ basename(filename);
		std.file.write(ofile2, app2);
	}
	
	for(int i = 0; i < app.length && i < app2.length; i++)
		if(app[i] != app2[i])
		{
			string a1 = app[i..$];
			string a2 = app2[i..$];
			assert(a1 == a2);
		}
	assert(app == app2);
	}
}

	string app3;
	CCodeWriter writer3 = new CCodeWriter(getStringSink(app3));
	writer3.writeNode(n);

	if(filename.length)
	{
		string ofile3 = "c:/tmp/d/c1/" ~ basename(filename);
		writeln(ofile3);
		std.file.write(ofile3, app3);
	}
}

version(all) unittest
{
	//Node n = p.parseText("a = b + c * 4 - 6");
	//n.print(0);
	//p.parseText("a, b, c = (1 ? 2 : 3 || d && 5 ^ *x)[3 .. 5]").print(0);

	string txt = q{
void fn()
{
		auto bar()(int x)
		{
			return 5 + x;
		}
		
	typeof(x)();
	extern (C) int Foo1;
	
		(x, y){ return x; };
	assert(!__traits(compiles, immutable(S43)(3, &i)));
	assert(ti.tsize==(void*).sizeof);
}

private static extern (C)
{
	shared char* function () uloc_getDefault;
}
		C14 c = new class C14 { };
		mixin typeof(c).m d;
		typeof(s).Foo j;

		size_t vsize = void.sizeof;

const const(int)* ptr() { return a.ptr; }

		mixin Foo!(uint);
		
		import id = std.imp;

		myint foo(myint x = myint.max)
		{}
		
		int[] x = 0.0 + (4 - 5);
		pure:
			synchronized
			{
				void y;
			}
		mixin(test);
		
		enum ENUM { a = 1, b = 2 }
		
		const(int) i = 4;
		const int j = 4;
	};
	testParse(txt, "unittest1");
}

unittest
{
	string txt = q{
		int y;
		int x;
	};
	testParse(txt, "unittest2");
}

unittest
{
	string txt = q{
		void main(string[] argv)
		{
			return;
			return 1;
			
			break;
			break wusel;
			while(1)
				mixin(argv[0]);
		}
	};
	testParse(txt, "unittest3");
}

unittest
{
	string txt = q{
		class A : public B, private C, D
		{
			int x;
			int[] y;
		}
	};
	testParse(txt, "unittest4");
}

	//alias 4 test;
	//uint[test] arr;
	//pragma(msg,arr.sizeof);

import core.exception;
import std.file;
	
int main(string[] argv)
{
	Project prj = new Project;

	foreach(file; argv[1..$])
	{
		if(indexOf(file, '*') >= 0 || indexOf(file, '?') >= 0)
		{
			string path = dirname(file);
			string pattern = basename(file);
			foreach(string name; dirEntries(path, SpanMode.shallow))
				if(fnmatch(basename(name), pattern))
					prj.addFile(name);
		}
		else
		{
			prj.addFile(file);
		}
	}
	prj.semantic();

	prj.writeCpp("c:/tmp/d/cproject.cpp");

	return 0;
}
}
