module ast

import token

pub struct Instruction {
	pub mut:
		instr_name string
		left_hs    Expr
		right_hs   Expr
		code       []u8
		offset     int
		pos        token.Position
}

pub type Expr = IntExpr | RegExpr | IdentExpr

pub struct RegExpr {
	pub:
	    bit int
	    lit  string
	    pos  token.Position
}

pub struct IntExpr {
	pub:
	    lit  string
	    pos  token.Position
}

pub struct IdentExpr {
	pub:
		lit string
		pos  token.Position
}


