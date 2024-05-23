{
{-# OPTIONS -Werror=missing-fields #-}

module RbParser( parseProgram ) where

-- *******************
-- *                 *
-- * project imports *
-- *                 *
-- *******************
import Ast
import RbLexer
import Location
import qualified Token

-- *******************
-- *                 *
-- * general imports *
-- *                 *
-- *******************
import Data.Maybe
import Data.Either
import Data.List ( map )
import Data.Map ( fromList, empty )

}

-- ***********************
-- *                     *
-- * API function: parse *
-- *                     *
-- ***********************
%name parse

-- *************
-- * tokentype *
-- *************
%tokentype { AlexTokenTag }

-- *********
-- * monad *
-- *********
%monad { Alex }

-- *********
-- * lexer *
-- *********
%lexer { lexwrap } { AlexTokenTag TokenEOF _ }

-- ***************************************************
-- * Call this function when an error is encountered *
-- ***************************************************
%error { parseError }

%token 

-- ***************
-- *             *
-- * parentheses *
-- *             *
-- ***************

'('    { AlexTokenTag AlexRawToken_LPAREN _ }
')'    { AlexTokenTag AlexRawToken_RPAREN _ }
'['    { AlexTokenTag AlexRawToken_LBRACK _ }
']'    { AlexTokenTag AlexRawToken_RBRACK _ }
'{'    { AlexTokenTag AlexRawToken_LBRACE _ }
'}'    { AlexTokenTag AlexRawToken_RBRACE _ }

-- ***************
-- *             *
-- * punctuation *
-- *             *
-- ***************

':'    { AlexTokenTag AlexRawToken_COLON  _ }
','    { AlexTokenTag AlexRawToken_COMMA  _ }

-- *********************
-- *                   *
-- * reserved keywords *
-- *                   *
-- *********************

'kw'                    { AlexTokenTag AlexRawToken_KW              _ }
'id'                    { AlexTokenTag AlexRawToken_KWID            _ }
'op'                    { AlexTokenTag AlexRawToken_OP              _ }
'end'                   { AlexTokenTag AlexRawToken_END             _ }
'raw'                   { AlexTokenTag AlexRawToken_RAW             _ }
'self'                  { AlexTokenTag AlexRawToken_SELF            _ }
'call'                  { AlexTokenTag AlexRawToken_CALL            _ }
'superclass'            { AlexTokenTag AlexRawToken_SUPER           _ }
'hash'                  { AlexTokenTag AlexRawToken_DICT2           _ }
'bare_assoc_hash'       { AlexTokenTag AlexRawToken_DICT            _ }
'assoc'                 { AlexTokenTag AlexRawToken_ASSOC           _ }
'label'                 { AlexTokenTag AlexRawToken_LABEL           _ }
'period'                { AlexTokenTag AlexRawToken_PERIOD          _ }
'parent'                { AlexTokenTag AlexRawToken_PARENT          _ }
'receiver'              { AlexTokenTag AlexRawToken_RECEIVER        _ }
'assocs'                { AlexTokenTag AlexRawToken_ASSOCS          _ }
'string_literal'        { AlexTokenTag AlexRawToken_STRING1         _ }
'symbol_literal'        { AlexTokenTag AlexRawToken_STRING3         _ }
'tstring_content'       { AlexTokenTag AlexRawToken_STRING2         _ }
'class'                 { AlexTokenTag AlexRawToken_CLASS           _ }
'sclass'                { AlexTokenTag AlexRawToken_SCLASS          _ }
'assign'                { AlexTokenTag AlexRawToken_ASSIGN          _ }
'location'              { AlexTokenTag AlexRawToken_LOC             _ }
'command'               { AlexTokenTag AlexRawToken_COMMAND         _ }
'message'               { AlexTokenTag AlexRawToken_MESSAGE         _ }
'comment'               { AlexTokenTag AlexRawToken_COMMENT         _ }
'constant'              { AlexTokenTag AlexRawToken_CONSTANT        _ }
'const_ref'             { AlexTokenTag AlexRawToken_CONSTANT2       _ }
'const_path_ref'        { AlexTokenTag AlexRawToken_CONSTANT4       _ }
'const'                 { AlexTokenTag AlexRawToken_CONSTANT3       _ }
'key'                   { AlexTokenTag AlexRawToken_KEY             _ }
'var_field'             { AlexTokenTag AlexRawToken_VAR             _ }
'field'                 { AlexTokenTag AlexRawToken_FIELD           _ }
'null'                  { AlexTokenTag AlexRawToken_NULL            _ }
'test'                  { AlexTokenTag AlexRawToken_TEST            _ }
'line'                  { AlexTokenTag AlexRawToken_LINE            _ }
'true'                  { AlexTokenTag AlexRawToken_TRUE            _ }
'args'                  { AlexTokenTag AlexRawToken_ARGS            _ }
'name'                  { AlexTokenTag AlexRawToken_NAME            _ }
'expr'                  { AlexTokenTag AlexRawToken_EXPR            _ }
'Name'                  { AlexTokenTag AlexRawToken_MAME            _ }
'type'                  { AlexTokenTag AlexRawToken_TYPE            _ }
'left'                  { AlexTokenTag AlexRawToken_LEFT            _ }
'loop'                  { AlexTokenTag AlexRawToken_LOOP            _ }
'init'                  { AlexTokenTag AlexRawToken_INIT            _ }
'cond'                  { AlexTokenTag AlexRawToken_COND            _ }
'body'                  { AlexTokenTag AlexRawToken_BODY            _ }
'update'                { AlexTokenTag AlexRawToken_UPDATE          _ }
'parts'                 { AlexTokenTag AlexRawToken_PARTS           _ }
'range'                 { AlexTokenTag AlexRawToken_RANGE           _ }
'index'                 { AlexTokenTag AlexRawToken_INDEX           _ }
'paren'                 { AlexTokenTag AlexRawToken_PAREN           _ }
'false'                 { AlexTokenTag AlexRawToken_FALSE           _ }
'start'                 { AlexTokenTag AlexRawToken_START           _ }
'exprs'                 { AlexTokenTag AlexRawToken_EXPRS           _ }
'value'                 { AlexTokenTag AlexRawToken_VALUE           _ }
'right'                 { AlexTokenTag AlexRawToken_RIGHT           _ }
'stmts'                 { AlexTokenTag AlexRawToken_STMTS           _ }
'array'                 { AlexTokenTag AlexRawToken_ARRAY           _ }
'Param'                 { AlexTokenTag AlexRawToken_PARAM           _ }
'object'                { AlexTokenTag AlexRawToken_OBJECT          _ }
'prefix'                { AlexTokenTag AlexRawToken_PREFIX          _ }
'params'                { AlexTokenTag AlexRawToken_PARAMS          _ }
'column'                { AlexTokenTag AlexRawToken_COLUMN          _ }
'target'                { AlexTokenTag AlexRawToken_TARGET          _ }
'Literal'               { AlexTokenTag AlexRawToken_LITERAL         _ }
'program'               { AlexTokenTag AlexRawToken_PROGRAM         _ }
'property'              { AlexTokenTag AlexRawToken_PROPERTY        _ }
'computed'              { AlexTokenTag AlexRawToken_COMPUTED        _ }
'contents'              { AlexTokenTag AlexRawToken_CONTENTS        _ }
'operator'              { AlexTokenTag AlexRawToken_OPERATOR        _ }
'comments'              { AlexTokenTag AlexRawToken_COMMENTS        _ }
'predicate'             { AlexTokenTag AlexRawToken_PREDICATE       _ }
'requireds'             { AlexTokenTag AlexRawToken_REQUIREDS       _ }
'alternate'             { AlexTokenTag AlexRawToken_ALTERNATE       _ }
'consequent'            { AlexTokenTag AlexRawToken_CONSEQUENT      _ }
'argument'              { AlexTokenTag AlexRawToken_ARGUMENT        _ }
'bodystmt'              { AlexTokenTag AlexRawToken_BODYSTMT        _ }
'arguments'             { AlexTokenTag AlexRawToken_ARGUMENTS       _ }
'arg_paren'             { AlexTokenTag AlexRawToken_ARGUMENTS2      _ }
'collection'            { AlexTokenTag AlexRawToken_COLLECTION      _ }
'generator'             { AlexTokenTag AlexRawToken_GENERATOR       _ }
'expression'            { AlexTokenTag AlexRawToken_EXPRESSION      _ }
'async'                 { AlexTokenTag AlexRawToken_ASYNC           _ }
'callee'                { AlexTokenTag AlexRawToken_CALLEE          _ }
'sourceType'            { AlexTokenTag AlexRawToken_SRC_TYPE        _ }
'Stmt_Echo'             { AlexTokenTag AlexRawToken_STMT_ECHO       _ }
'var_ref'               { AlexTokenTag AlexRawToken_EXPR_VAR        _ }
'Stmt_Expr'             { AlexTokenTag AlexRawToken_STMT_EXPR       _ }
'Scalar_Int'            { AlexTokenTag AlexRawToken_SCALAR_INT      _ }
'ident'                 { AlexTokenTag AlexRawToken_IDENTIFIER      _ }
'returnType'            { AlexTokenTag AlexRawToken_RETURN_TYPE     _ }
'Stmt_Function'         { AlexTokenTag AlexRawToken_STMT_FUNCTION   _ }
'def'                   { AlexTokenTag AlexRawToken_FUNCTION_DEC    _ }

-- *********
-- *       *
-- * other *
-- *       *
-- *********

QUOTED_INT  { AlexTokenTag AlexRawToken_QUOTED_INT  _ }
QUOTED_BOOL { AlexTokenTag AlexRawToken_QUOTED_BOOL _ }

-- ***************
-- *             *
-- * expressions *
-- *             *
-- ***************

'CallExpression'   { AlexTokenTag AlexRawToken_EXPR_CALL   _ }
'MemberExpression' { AlexTokenTag AlexRawToken_EXPR_MEMBER _ }
'binary'           { AlexTokenTag AlexRawToken_EXPR_BINOP  _ }
'UpdateExpression' { AlexTokenTag AlexRawToken_EXPR_UPDATE _ }
'AssignExpression' { AlexTokenTag AlexRawToken_EXPR_ASSIGN _ }

-- **************
-- *            *
-- * statements *
-- *            *
-- **************

'IfStatement'         { AlexTokenTag AlexRawToken_STMT_IF     _ }
'ForStatement'        { AlexTokenTag AlexRawToken_STMT_FOR    _ }
'BlockStatement'      { AlexTokenTag AlexRawToken_STMT_BLOCK  _ }
'ReturnStatement'     { AlexTokenTag AlexRawToken_STMT_RETURN _ }
'ExpressionStatement' { AlexTokenTag AlexRawToken_STMT_EXP    _ }

-- *************
-- *           *
-- * operators *
-- *           *
-- *************

'<'  { AlexTokenTag AlexRawToken_OP_LT       _ }
'==' { AlexTokenTag AlexRawToken_OP_EQ       _ }
'='  { AlexTokenTag AlexRawToken_OP_ASSIGN   _ }
'.'  { AlexTokenTag AlexRawToken_OP_DOT      _ }
'+'  { AlexTokenTag AlexRawToken_OP_PLUS     _ }
'-'  { AlexTokenTag AlexRawToken_OP_MINUS    _ }
'*'  { AlexTokenTag AlexRawToken_OP_TIMES    _ }
'..' { AlexTokenTag AlexRawToken_OP_DOTDOT   _ }
'%'  { AlexTokenTag AlexRawToken_OP_PERCENT  _ }
'++' { AlexTokenTag AlexRawToken_OP_PLUSPLUS _ }
'||' { AlexTokenTag AlexRawToken_OP_OR       _ }

-- ****************************
-- *                          *
-- * integers and identifiers *
-- *                          *
-- ****************************

INT    { AlexTokenTag (AlexRawToken_INT  i) _ }
ID     { AlexTokenTag (AlexRawToken_ID  id) _ }

-- *************************
-- *                       *
-- * grammar specification *
-- *                       *
-- *************************
%%

-- **********************
-- *                    *
-- * parametrized lists *
-- *                    *
-- **********************
listof(a):      a { [$1] } | a          listof(a) { $1:$2 }
commalistof(a): a { [$1] } | a ',' commalistof(a) { $1:$3 }

-- ******************
-- *                *
-- * optional rules *
-- *                *
-- ******************
optional(a): { Nothing } | a { Just $1 }

-- *********************
-- *                   *
-- * Ast root: program *
-- *                   *
-- *********************
program:
'{'
    'type' ':' 'program' ','
    'location' ':' location ','
    'stmts' ':' stmts ','
    'comments' ':' '[' ']'
'}'
{
    Ast.Root
    {
        Ast.filename = getFilename $1,
        Ast.stmts = rights (catMaybes $12),
        Ast.decs = lefts (catMaybes $12)
    }
}

-- ************
-- *          *
-- * location *
-- *          *
-- ************
location: '[' INT ',' INT ',' INT ',' INT ']'
{
    Location
    {
        Location.filename = getFilename $1,
        lineStart = tokIntValue $2,
        colStart = tokIntValue $4,
        lineEnd = tokIntValue $6,
        colEnd = tokIntValue $8
    }
}

-- ************
-- *          *
-- * token ID *
-- *          *
-- ************
tokenID:
ID      { unquote (tokIDValue $1) } |
'id'    { "id"                    } |
'self'  { "self"                  } |
'true'  { "true"                  } |
'name'  { "name"                  } |
'start' { "start"                 }

-- *******************
-- *                 *
-- * identifier_type *
-- *                 *
-- *******************
identifier_type:
'const' { Nothing } |
'ident' { Nothing } |
'kw'    { Nothing }

-- **************
-- *            *
-- * identifier *
-- *            *
-- **************
identifier:
'{'
    'type' ':' identifier_type ','
    'location' ':' location ','
    'value' ':' tokenID ','
    'comments' ':' '[' ']' 
'}'
{
    Token.Named
    {
        Token.content = $12,
        Token.location = $8
    }
}

-- *********
-- *       *
-- * param *
-- *       *
-- *********
param:
'{'
    'type' ':' 'ident' ','
    'name' ':' tokenID ','
    'location' ':' location
'}'
{
    Token.Named
    {
        Token.content = $8,
        Token.location = $12
    } 
}

-- ***********
-- *         *
-- * exp_var *
-- *         *
-- ***********
exp_var:
identifier_wrapper { Ast.ExpVarContent $ Ast.VarSimple $ Ast.VarSimpleContent $ Token.VarName $1 }

-- *************
-- *           *
-- * exp_binop *
-- *           *
-- *************
exp_binop:
'{'
    'type' ':' 'binary' ','
    'location' ':' location ','
    'left' ':' exp ','
    'operator' ':' actual_op ','
    'right' ':' exp ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpBinop $ Ast.ExpBinopContent
    {
       Ast.expBinopLeft = $12,
       Ast.expBinopRight = $20,
       Ast.expBinopOperator = $16,
       Ast.expBinopLocation = $8
    }
}

-- **************
-- *            *
-- * var_simple *
-- *            *
-- **************
var_simple:
'{'
    'type' ':' 'var_field' ','
    'location' ':' location ','
    'value' ':' identifier ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- *************
-- *           *
-- * var_field *
-- *           *
-- *************
var_field:
'{'
    'type' ':' 'field' ','
    'location' ':' location ','
    'parent' ':' identifier_wrapper ','
    'operator' ':' operator ','
    'name' ':' identifier ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ************
-- *          *
-- * variable *
-- *          *
-- ************
var:
var_simple { $1 } |
var_field  { $1 }

-- ***************
-- *             *
-- * string_part *
-- *             *
-- ***************
string_part:
'{'
    'type' ':' 'tstring_content' ','
    'location' ':' location ','
    'value' ':' ID ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- *************
-- *           *
-- * exp_str_1 *
-- *           *
-- *************
exp_str_1:
'{'
    'type' ':' 'string_literal' ','
    'location' ':' location ','
    'parts' ':' '[' commalistof(string_part) ']' ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpStr $ Ast.ExpStrContent $ Token.ConstStr
    {
        Token.constStrValue = "MMM",
        Token.constStrLocation = $8
    }
}

-- *************
-- *           *
-- * exp_str_2 *
-- *           *
-- *************
exp_str_2:
'{'
    'type' ':' 'symbol_literal' ','
    'location' ':' location ','
    'value' ':' identifier ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpStr $ Ast.ExpStrContent $ Token.ConstStr
    {
        Token.constStrValue = (Token.content $12),
        Token.constStrLocation = $8
    }
}

-- ***********
-- *         *
-- * exp_str *
-- *         *
-- ***********
exp_str:
exp_str_1 { $1 } |
exp_str_2 { $1 }

-- *******
-- *     *
-- * key *
-- *     *
-- *******
key:
'{'
    'type' ':' 'label' ','
    'location' ':' location ','
    'value' ':' ID ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- *********
-- *       *
-- * assoc *
-- *       *
-- *********
assoc:
'{'
    'type' ':' 'assoc' ','
    'location' ':' location ','
    'key' ':' key ','
    'value' ':' exp ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ************
-- *          *
-- * exp_dict *
-- *          *
-- ************
exp_dict_1:
'{'
    'type' ':' 'bare_assoc_hash' ','
    'location' ':' location ','
    'assocs' ':' '[' commalistof(assoc) ']' ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpInt $ Ast.ExpIntContent $ Token.ConstInt
    {
        Token.constIntValue = 9999,
        Token.constIntLocation = $8
    }
}

-- ************
-- *          *
-- * exp_dict *
-- *          *
-- ************
exp_dict_2:
'{'
    'type' ':' 'hash' ','
    'location' ':' location ','
    'assocs' ':' '[' commalistof(assoc) ']' ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpInt $ Ast.ExpIntContent $ Token.ConstInt
    {
        Token.constIntValue = 9999,
        Token.constIntLocation = $8
    }
}

-- ************
-- *          *
-- * exp_dict *
-- *          *
-- ************
exp_dict:
exp_dict_1 { $1 } |
exp_dict_2 { $1 }

-- ********
-- *      *
-- * args *
-- *      *
-- ********
args:
'{'
    'type' ':' 'args' ','
    'location' ':' location ','
    'parts' ':' '[' commalistof(exp) ']' ','
    'comments' ':' '[' ']'
'}'
{
    $13
}


-- *************
-- *           *
-- * exp_array *
-- *           *
-- *************
exp_array:
'{'
    'type' ':' 'array' ','
    'location' ':' location ','
    'contents' ':' args ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpCall $ Ast.ExpCallContent
    {
        Ast.callee = Ast.ExpVar $ Ast.ExpVarContent $ Ast.VarSimple $ Ast.VarSimpleContent $ Token.VarName $ Token.Named
        {
            Token.content = "listify",
            Token.location = $8
        },
        Ast.args = $12,
        Ast.expCallLocation = $8
    }
}

-- *******
-- *     *
-- * exp *
-- *     *
-- *******
exp:
exp_str    { $1 } |
exp_var    { Ast.ExpVar $1 } |
exp_call   { $1 } |
exp_dict   { $1 } |
exp_array  { $1 } |
exp_binop  { $1 }

-- **************
-- *            *
-- * collection *
-- *            *
-- **************
collection:
'{'
    'type' ':' 'range' ','
    'location' ':' location ','
    'left' ':' exp ','
    'operator' ':' operator ','
    'right' ':' exp ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ************
-- *          *
-- * stmt_for *
-- *          *
-- ************
stmt_for:
'{'
    'type' ':' 'ForStatement' ','
    'location' ':' location ','
    'index' ':' var ','
    'collection' ':' collection ','
    'stmts' ':' stmts ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ************
-- *          *
-- * operator *
-- *          *
-- ************
actual_op:
'..' { Ast.PLUS    } |
'==' { Ast.PLUS    } |
'||' { Ast.PLUS    } |
'+'  { Ast.PLUS    } |
'*'  { Ast.TIMES   } |
'%'  { Ast.PERCENT } |
'-'  { Ast.MINUS   } |
'<'  { Ast.PLUS    } |
'='  { Ast.PLUS    } |
'.'  { Ast.PLUS    }

-- ************
-- *          *
-- * operator *
-- *          *
-- ************
operator_name:
'op'     { Nothing } |
'period' { Nothing }

-- ************
-- *          *
-- * operator *
-- *          *
-- ************
operator:
'{'
    'type' ':' operator_name ','
    'location' ':' location ','
    'value' ':' actual_op ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- *************
-- *           *
-- * arguments *
-- *           *
-- *************
arguments_type_1:
'{'
    'type' ':' 'args' ','
    'location' ':' location ','
    'parts' ':' '[' commalistof(exp) ']' ','
    'comments' ':' '[' ']' 
'}'
{
    $13
}

-- *************
-- *           *
-- * arguments *
-- *           *
-- *************
arguments_type_2:
'{'
    'type' ':' 'args' ','
    'location' ':' location ','
    'parts' ':' '[' ']' ','
    'comments' ':' '[' ']' 
'}'
{
    []
}

-- *************
-- *           *
-- * arguments *
-- *           *
-- *************
arguments:
arguments_type_1 { $1 } |
arguments_type_2 { $1 }

-- *********************
-- *                   *
-- * arguments_wrapper *
-- *                   *
-- *********************
arguments_wrapper:
'{'
    'type' ':' 'arg_paren' ','
    'location' ':' location ','
    'arguments' ':' arguments ','
    'comments' ':' '[' ']'
'}'
{
    $12
}

-- ***************
-- *             *
-- * stmt_assign *
-- *             *
-- ***************
stmt_assign:
'{'
    'type' ':' 'assign' ','
    'location' ':' location ','
    'target' ':' var ','
    'value' ':' exp ','
    'comments' ':' '[' ']' 
'}'
{
    Nothing
}

-- ***********
-- *         *
-- * stmt_if *
-- *         *
-- ***********
stmt_if:
'{'
    'type' ':' 'IfStatement' ','
    'location' ':' location ','
    'predicate' ':' exp ','
    'stmts' ':' stmts ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ************
-- *          *
-- * exp_call *
-- *          *
-- ************
exp_call_without_args:
'{'
    'type' ':' 'call' ','
    'location' ':' location ','
    'receiver' ':' exp ','
    'operator' ':' operator ','
    'message' ':' identifier ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpField $ Ast.ExpFieldContent
    {
        Ast.expFieldLhs = $12,
        Ast.expFieldName = Token.FieldName $20,
        Ast.expFieldLocation = $8
    }
}

-- ************
-- *          *
-- * exp_call *
-- *          *
-- ************
exp_call_with_args:
'{'
    'type' ':' 'call' ','
    'location' ':' location ','
    'receiver' ':' exp ','
    'operator' ':' operator ','
    'message' ':' identifier ','
    'arguments' ':' arguments_wrapper ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpCall $ Ast.ExpCallContent
    {
        Ast.callee = Ast.ExpField $ Ast.ExpFieldContent
        {
            Ast.expFieldLhs = $12,
            Ast.expFieldName = Token.FieldName $20,
            Ast.expFieldLocation = $8
        },
        Ast.args = $24,
        Ast.expCallLocation = $8
    }
}

-- ************
-- *          *
-- * exp_call *
-- *          *
-- ************
exp_call_without_rcvr:
'{'
    'type' ':' 'call' ','
    'location' ':' location ','
    'receiver' ':' 'null' ','
    'operator' ':' 'null' ','
    'message' ':' identifier ','
    'arguments' ':' arguments ','
    'comments' ':' '[' ']'
'}'
{
    Ast.ExpVar $ Ast.ExpVarContent $ Ast.VarSimple $ Ast.VarSimpleContent $ Token.VarName $20
}

-- ************
-- *          *
-- * exp_call *
-- *          *
-- ************
exp_call:
exp_call_with_args    { $1 } |
exp_call_without_rcvr { $1 } |
exp_call_without_args { $1 }

-- ****************
-- *              *
-- * stmt_comment *
-- *              *
-- ****************
stmt_comment:
'{'
    'type' ':' 'comment' ','
    'location' ':' location ','
    'value' ':' ID
'}'
{
    Nothing
}

-- ************
-- *          *
-- * constant *
-- *          *
-- ************
constant_or_value:
'constant'  { Nothing } |
'value'     { Nothing }

-- ***************************
-- *                         *
-- * identifier_wrapper_kind *
-- *                         *
-- ***************************
identifier_wrapper_kind:
'const_ref'      { Nothing } |
'const_path_ref' { Nothing } |
'var_ref'        { Nothing }

-- **********
-- *        *
-- * parent *
-- *        *
-- **********
parent: 'parent' ':' identifier_wrapper ',' { $3 }

-- **********************
-- *                    *
-- * identifier_wrapper *
-- *                    *
-- **********************
identifier_wrapper:
'{'
    'type' ':' identifier_wrapper_kind ','
    'location' ':' location ','
    optional(parent)
    constant_or_value ':' identifier ','
    'comments' ':' '[' ']'
'}'
{
    $13
}

-- **************
-- *            *
-- * stmt_class *
-- *            *
-- **************
stmt_class:
'{'
    'type' ':' 'class' ','
    'location' ':' location ','
    'constant' ':' identifier_wrapper ','
    'superclass' ':' identifier_wrapper ','
    'bodystmt' ':' bodystmt ','
    'comments' ':' '[' ']'
'}'
{
    Just $ Left $ Ast.DecClass $ Ast.DecClassContent
    {
        Ast.decClassName = Token.ClassName $12,
        Ast.decClassSupers = [ Token.SuperName $16 ],
        Ast.decClassDataMembers = Ast.DataMembers Data.Map.empty,
        Ast.decClassMethods = Ast.Methods $ Data.Map.fromList (catMaybes (Data.List.map methodify (catMaybes $20)))
    }
}

-- ****************
-- *              *
-- * stmt_command *
-- *              *
-- ****************
stmt_command:
'{'
    'type' ':' 'command' ','
    'location' ':' location ','
    'message' ':' identifier ','
    'arguments' ':' arguments ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ***************
-- *             *
-- * stmt_method *
-- *             *
-- ***************
stmt_method_type_1:
'{'
    'type' ':' 'def' ','
    'location' ':' location ','
    'target' ':' exp_var ','
    'operator' ':' operator ','
    'name' ':' identifier ','
    'params' ':' params ','
    'bodystmt' ':' bodystmt ','
    'comments' ':' '[' ']'
'}'
{
    Just $ Left $ Ast.DecMethod $ DecMethodContent
    {
        Ast.decMethodReturnType = Token.NominalTy (Token.Named "any" $8),
        Ast.decMethodName = Token.MethdName $20,
        Ast.decMethodParams = $24,
        Ast.decMethodBody = rights (catMaybes $28),
        Ast.decMethodLocation = $8
    }
}

-- ***************
-- *             *
-- * stmt_method *
-- *             *
-- ***************
stmt_method_type_2:
'{'
    'type' ':' 'def' ','
    'location' ':' location ','
    'target' ':' 'null' ','
    'operator' ':' 'null' ','
    'name' ':' identifier ','
    'params' ':' params ','
    'bodystmt' ':' bodystmt ','
    'comments' ':' '[' ']'
'}'
{
    Just $ Left $ Ast.DecMethod $ DecMethodContent
    {
        Ast.decMethodReturnType = Token.NominalTy (Token.Named "any" $8),
        Ast.decMethodName = Token.MethdName $20,
        Ast.decMethodParams = $24,
        Ast.decMethodBody = rights (catMaybes $28),
        Ast.decMethodLocation = $8
    }
}

-- ***************
-- *             *
-- * stmt_method *
-- *             *
-- ***************
stmt_method:
stmt_method_type_1 { $1 } |
stmt_method_type_2 { $1 }

-- ************
-- *          *
-- * stmt_exp *
-- *          *
-- ************
stmt_exp:
exp
{
    Just $ Right $ Ast.StmtIf $ Ast.StmtIfContent
    {
        Ast.stmtIfCond = $1,
        Ast.stmtIfBody = [],
        Ast.stmtElseBody = [],
        Ast.stmtIfLocation = Location "8" 6 5 6 5
    }
}

-- ***************
-- *             *
-- * stmt_sclass *
-- *             *
-- ***************
stmt_sclass:
'{'
    'type' ':' 'sclass' ','
    'location' ':' location ','
    'target' ':' identifier_wrapper ','
    'bodystmt' ':' bodystmt ','
    'comments' ':' '[' ']'
'}'
{
    Nothing
}

-- ********
-- *      *
-- * stmt *
-- *      *
-- ********
stmt:
stmt_if      { $1 } |
stmt_for     { $1 } |
stmt_exp     { $1 } |
stmt_assign  { $1 } |
stmt_class   { $1 } |
stmt_command { $1 } |
stmt_sclass  { $1 } |
stmt_method  { $1 } |
stmt_comment { $1 }

-- *********
-- *       *
-- * stmts *
-- *       *
-- *********
stmts:
'{'
    'type' ':' 'stmts' ','
    'location' ':' location ','
    'body' ':' '[' commalistof(stmt) ']' ','
    'comments' ':' '[' ']'
'}'
{
    $13
}

-- ************
-- *          *
-- * contents *
-- *          *
-- ************
contents:
'{'
    'type' ':' 'params' ','
    'location' ':' location ','
    'requireds' ':' '[' commalistof(identifier) ']' ','
    'comments' ':' '[' ']'
'}'
{
    Data.List.map paramify $13
}

-- **********
-- *        *
-- * params *
-- *        *
-- **********
params_type_1:
'{'
    'type' ':' 'paren' ','
    'location' ':' location ','
    'contents' ':' contents ','
    'comments' ':' '[' ']'
'}'
{
    $12
}

-- **********
-- *        *
-- * params *
-- *        *
-- **********
params_type_2:
'{'
    'type' ':' 'params' ','
    'location' ':' location ','
    'comments' ':' '[' ']'
'}'
{
    []
}

-- **********
-- *        *
-- * params *
-- *        *
-- **********
params:
params_type_1 { $1 } |
params_type_2 { $1 }

-- ************
-- *          *
-- * bodystmt *
-- *          *
-- ************
bodystmt:
'{'
    'type' ':' 'bodystmt' ','
    'location' ':' location ','
    'stmts' ':' stmts ','
    'comments' ':' '[' ']'
'}'
{
    $12
}


{

extractParamSingleName' :: [ Token.ParamName ] -> Maybe Token.ParamName
extractParamSingleName' ps = case ps of { [p] -> Just p; _ -> Nothing }
 
extractParamSingleName :: [ Either Token.ParamName Token.NominalTy ] -> Maybe Token.ParamName
extractParamSingleName = extractParamSingleName' . lefts  

extractParamNominalType' :: [ Token.NominalTy ] -> Maybe Token.NominalTy
extractParamNominalType' ts = case ts of { [t] -> Just t; _ -> Nothing }
 
extractParamNominalType :: [ Either Token.ParamName Token.NominalTy ] -> Maybe Token.NominalTy
extractParamNominalType = extractParamNominalType' . rights 

paramify :: Token.Named -> Ast.Param
paramify token = let
    paramName = Token.ParamName token
    nominalType = Token.NominalTy (Token.Named "any" (Token.location token))
    in Ast.Param paramName nominalType 156

methodify :: Either Ast.Dec Ast.Stmt -> Maybe (Token.MethdName,Ast.DecMethodContent)
methodify (Left (Ast.DecMethod d)) = Just ((Ast.decMethodName d),d)
methodify _ = Nothing

unquote :: String -> String
unquote s = let n = length s in take (n-2) (drop 1 s)

-- add the /real/ serial index of the param
-- the parser just puts an arbitrary value
-- there because it lacks context
enumerateParams :: (Word,[Param]) -> [Param]
enumerateParams (_,[    ]) = []
enumerateParams (i,(p:ps)) =
    let
        n = (paramName        p)
        t = (paramNominalType p)
        head = Param { paramName = n, paramNominalType = t, paramSerialIdx = i }
        tail = (enumerateParams (i+1,ps))
    in
        head:tail

-- ***********
-- *         *
-- * lexwrap *
-- *         *
-- ***********
lexwrap :: (AlexTokenTag -> Alex a) -> Alex a
lexwrap = (alexMonadScan >>=)

-- **************
-- *            *
-- * parseError *
-- *            *
-- **************
parseError :: AlexTokenTag -> Alex a
parseError t = alexError' (tokenLoc t)

-- ****************
-- *              *
-- * parseProgram *
-- *              *
-- ****************
parseProgram :: FilePath -> String -> Either String Ast.Root
parseProgram = runAlex' parse
}

