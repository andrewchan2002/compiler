grammar Cactus;

@members {
	int labelCount = 0;
	String newLabel() {
		labelCount ++;
		return (new String("L")) + Integer.toString(labelCount);
	} 
}

/* Parser rules */
program locals [int reg = 0]:
	MAIN '(' ')' '{'
	{ 
		System.out.println("\t" + ".data"); 
	} 
	declarations
	{
		System.out.println("\t" + ".text"); 
		System.out.println("main:"); 
	}
	statements [$reg] 
	'}';

declarations: INT ID 
	{
		System.out.println($ID.text+":\t.word\t0");
	}
	';' declarations 
	|
	;

statements [int reg]: statement[$reg] statements[$reg] 
	|
	;

statement [int reg] : 
	ID ASSIGN arith_expression[$reg] 
	{
		System.out.println("\tla\t\$t"+$arith_expression.nreg+", "+$ID.text);
		System.out.println("\tsw\t\$t"+$arith_expression.place+", 0(\$t"+$arith_expression.nreg+")");
	} ';'
	| IF
	{	
		String b_true = newLabel();
		String b_false = newLabel();
		String b_next = newLabel();
	}
	'(' bool_expression[$reg, b_true, b_false] ')' 
	{
		System.out.println(b_true+": # then");
	}
	'{' statements[$reg] '}' elsestatement[$reg, b_false, b_next] FI

	| WHILE
	{
    	String w_begin = newLabel();
    	String w_body = newLabel();
    	String w_end = newLabel();
		System.out.println(w_begin + ": # while");
	}
	 '(' bool_expression[$reg, w_body, w_end] ')'
	{
    	System.out.println(w_body + ": # body");
	} '{' statements[$reg] '}'
	{
		System.out.println("\tb " + w_begin);
		System.out.println(w_end + ": #end while");
	}

	| READ ID
	{
		System.out.println("\tli\t\$v0, 5");
		System.out.println("\tsyscall");
		System.out.println("\tla\t\$t"+$reg+", "+$ID.text);
		System.out.println("\tsw\t\$v0, 0(\$t"+$reg+")");
	} 
	';'
	| WRITE arith_expression[$reg]
	{
		System.out.println("\tmove\t\$a0, \$t"+$arith_expression.place);
		System.out.println("\tli\t\$v0, 1");
		System.out.println("\tsyscall");
	} ';'
	| RETURN {
		System.out.println("\tli\t\$v0, 10");
		System.out.println("\tsyscall");
	} ';'
	| ';';
	
elsestatement [int reg , String b_false, String b_next] 
	: ELSE 
	{
		System.out.println("\tb\t"+$b_next);
		System.out.println($b_false+": # else");
	} 
	'{' statements[$reg] '}' {System.out.println($b_next+": # end if");} 
	| {System.out.println($b_false+":");} ;


arith_expression [int reg] returns [int nreg, int place]
	: arith_term[$reg] arith_expression1[$arith_term.nreg, $arith_term.place] 
	{
		$nreg = $arith_expression1.nreg;
		$place = $arith_expression1.place;
	};

arith_expression1 [int reg, int s_place] returns [int nreg, int place] 
	: '+' arith_term[$reg] {
		System.out.println("\tadd\t\$t"+$s_place+", \$t"+$s_place+", \$t"+$arith_term.place);
	} aee = arith_expression1[$arith_term.nreg, $s_place] {
		$nreg = $aee.nreg-1;
		$place = $aee.place;
	}
	| '-' arith_term[$reg] {
		System.out.println("\tsub\t\$t"+$s_place+", \$t"+$s_place+", \$t"+$arith_term.place);
	} aee = arith_expression1[$arith_term.nreg, $s_place] {
		$nreg = $aee.nreg-1;
		$place = $aee.place;
	}
	| {
		$nreg = $reg;
		$place = $s_place;
	}
	;

arith_term [int reg] returns [int nreg, int place]
	: arith_factor[$reg] arith_term1[$arith_factor.nreg, $arith_factor.place] {
		$nreg = $arith_term1.nreg;
        $place = $arith_term1.place;
	};

arith_term1[int reg, int s_place] returns [int nreg, int place] :
	  '*' arith_factor[$reg] {
		System.out.println("\tmul\t\$t"+$s_place+", \$t"+$s_place+", \$t"+$arith_factor.place);
		$nreg = $arith_factor.nreg;
        $place = $arith_factor.place;
	}
	| '/' arith_factor[$reg] {
		System.out.println("\tdiv\t\$t"+$s_place+", \$t"+$s_place+", \$t"+$arith_factor.place);
		$nreg = $arith_factor.nreg;
        $place = $arith_factor.place;
	}
	| '%' arith_factor[$reg] {
		System.out.println("\trem\t\$t"+$s_place+", \$t"+$s_place+", \$t"+$arith_factor.place);
		$nreg = $arith_factor.nreg;
        $place = $arith_factor.place;
	}
	|{
		$nreg = $reg;
		$place = $s_place;
	};

arith_factor[int reg] returns [int nreg, int place]
	: '-' a=arith_factor [$reg] {
		System.out.println("\tneg\t\$t"+$a.place+", \$t"+$a.place);
		$nreg = $a.nreg;
		$place = $a.place;
	}
	| primary_expression[$reg] {
		$nreg = $primary_expression.nreg;
		$place = $primary_expression.place;
	};

primary_expression[int reg] returns [int nreg, int place] :
	ID {
		System.out.println("\tla\t\$t"+$reg+", "+$ID.text);
		System.out.println("\tlw\t\$t"+$reg+", 0(\$t"+$reg+")");
		$nreg = $reg + 1;
		$place = $reg;
	}
	| CONST {
		System.out.println("\tli\t\$t"+$reg+", "+$CONST.text);
		$nreg = $reg + 1;
		$place = $reg;
	}
	| '(' arith_expression[$reg] ')'{
		$nreg = $arith_expression.nreg;
		$place = $arith_expression.place;
	};

bool_expression[int reg, String b_true, String b_false] returns [int nreg]
	: bool_term[$reg, $b_true, $b_false] {
		String L4 = newLabel();
		String L5 = newLabel();
		System.out.println("\t\$t"+($bool_term.nreg-1)+", \$t"+$bool_term.nreg+", "+L5);
	}  bool_expression1[$bool_term.nreg-1, $b_true, $b_false] {
		System.out.println("\tb\t"+L4);

		System.out.println(L5+":"); 
		System.out.println("\tb\t"+$b_true);
		System.out.println(L4+":"); 
		System.out.println("\tb\t"+$b_false);
	};


bool_expression1[int reg, String b_true, String b_false] returns [int nreg] 
	: {
		System.out.println("\tb\tL"+labelCount); 
		System.out.println("L"+labelCount+":"); 
		String L = newLabel();
	}'||' bool_term[$reg, $b_true, $b_false] bool_expression1[$reg , $b_true, $b_false] {
		System.out.println("\t\$t0"+", \$t1"+", "+$b_true);
	}
	|{
		$nreg = $reg;
	};

bool_term [int reg, String b_true, String b_false] returns [int nreg]
	: bool_factor[$reg, $b_true, $b_false] 
	bool_term1[$bool_factor.nreg, $b_true, $b_false] 
	{
		$nreg = $bool_term1.nreg;
	};

bool_term1 [int reg, String b_true, String b_false] returns [int nreg]
	: {
		System.out.println("\t\$t"+($reg-1)+", \$t"+$reg+", L"+labelCount);
		System.out.println("\tb\tL"+$b_false);
		System.out.println("L"+labelCount+":");
		$reg = $reg-1;
		labelCount++;
	}'&&' bool_factor[$reg, $b_true, $b_false] bool_term1[$bool_factor.nreg-1, $b_true, $b_false] {
		$nreg = $bool_term1.nreg;

	}
	| {
		$nreg = $reg;

	};
bool_factor[int reg, String b_true, String b_false] returns [int nreg]
	: '!' rel_expression [$reg, $b_false, $b_true] {
		$nreg = $rel_expression.nreg;
	}
	| rel_expression[$reg, $b_false, $b_true] {
		$nreg = $rel_expression.nreg;
	};

rel_expression[int reg, String b_true, String b_false] returns [int nreg]
	: a=arith_expression[$reg] relation_op b=arith_expression[$a.nreg]{
		System.out.print("\t"+$relation_op.op);
		$nreg = $a.nreg;
	};

relation_op returns [String op] 
	: '==' {$op = "beq";}
	| '!=' {$op = "bne";}
	| '>'  {$op = "bgt";}
	| '>=' {$op = "bge";}
	| '<'  {$op = "blt";}
	| '<=' {$op = "ble";}
	;

identifier: ID;

constant: CONST;

/* Lexer rules */
ELSE: 'else';
FI: 'fi';
IF: 'if';
INT: 'int';
MAIN: 'main';
RETURN: 'return';
WHILE: 'while';
READ: 'read';
WRITE: 'write';

ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
MOD: '%';
EQ: '==';
NEQ: '!=';
GT: '>';
GTE: '>=';
LT: '<';
LTE: '<=';
AND: '&&';
OR: '||';
NOT: '!';
ASSIGN: '=';
LPAREN: '(';
RPAREN: ')';
LBRACE: '{';
RBRACE: '}';
SEMI: ';';

ID: [a-zA-Z_][a-zA-Z0-9_]*;
CONST: [0-9]+;

WS: [ \t\r\n]+ -> skip;
COMMENT: '/*' .*? '*/' -> skip;
LINE_COMMENT: '//' ~[\r\n]* -> skip;
