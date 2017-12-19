program lab7_add;

{$APPTYPE CONSOLE}
resourcestring
  rsEnterExpr = 'Please, enter your mathematical expression';
  rsErrorFound = 'The following errors are entered in the expression you entered:';
  rsReenter = 'Please re-enter the expression';
  rsTwoNumInRow = 'There are two numbers in a row';
  rsSignAtEnd = 'At the end of the expression, a sign is found';
  rsSignAtBegin = 'At the begin of the expression, a sign is found';
  rsIllegalChar = 'Illegal characters used:';
  rsAfterParNoSign = 'After the parentheses there is no mathematical sign';
  rsBeforeParNoSign = 'Before the parentheses there is no mathematical sign';
  rsClosingWithoutOpening = 'A closing parenthesis is encountered without an appropriate opening';
  rsTwoSignInRow = 'I met two signs in a row. Please use parentheses';
  rsNoMatchNumCloseOpen = 'The number of opening and closing parentheses does not match';
const acceptChar = ['0'..'9', '+', '-', '*', '/', ')', '('];
const sign=['+', '-', '*', '/'];
const numbers = ['0'..'9'];
const prior1 = ['*', '/'];
const prior2 = ['+', '-'];
type TError = string;
var error: TError;
    Expr: string;
    isErr, errstatus: Boolean;

procedure removeSpaces(var str:string);
var i:Byte;
begin
  i:=1;
  while(i<=Length(str)) do
  begin
    if (str[i] = ' ') then
    begin
      if((str[i-1] in numbers) and (str[i+1] in numbers)) then
      begin
        error:=error+ #10#13 +' - ' + rsTwoNumInRow;
        errstatus:=True;
      end;
      Delete(str,i,1)
    end
    else
      Inc(i);
  end;
end;

function isErrorExpression(var isError:boolean; const str: string; var err: TError):boolean;
var i:byte;
openparentheses, closeparentheses: byte;
begin
  i:=1;
  closeparentheses:=0;
  openparentheses:= 0;
  if (str[length(str)] in sign) then
  begin
    isError:=true;
    err:= err + #10#13 + ' - ' + rsSignAtEnd;
  end;
  if (str[1] in prior1) then
  begin
    isError:=true;
    err:= err + #10#13 + ' - ' + rsSignAtBegin;
  end;
  while(i <= Length(str)) do
  begin
    if (not (str[i] in acceptChar)) then
    begin
      isError:=true;
      err:= err + #10#13 + ' - ' + rsIllegalChar +' "' + str[i]+'"';
    end;
    if (str[i] = ')') then
    begin
      Inc(closeparentheses);
      if(str[i+1] in numbers) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - ' + rsAfterParNoSign;
      end;
      if(str[i-1] in prior1) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - ' + rsBeforeParNoSign;
      end;
    end;
    if (str[i] = '(') then
    begin
      Inc(openparentheses);
      if(str[i-1] in numbers) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - ' + rsBeforeParNoSign;
      end;
      if((str[i+1] in prior1) or (str[i+1] = ')')) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - ' + rsAfterParNoSign;
      end;
    end;
    if((closeparentheses > openparentheses) and (not isError))then
    begin
      isError:=True;
      err:= err + #10#13 + ' - ' + rsClosingWithoutOpening;
    end;
    if ((str[i] in sign) and (str[i+1] in sign)) then
    begin
      isError:=True;
      err:= err + #10#13 + ' - ' + rsTwoSignInRow;
    end;
    inc(i);
  end;
  if (openparentheses <> closeparentheses ) then
  begin
    isError:=true;
    err:= err + #10#13 + ' - ' + rsNoMatchNumCloseOpen;
  end;
  isErrorExpression:=isError;
end;

procedure formatingFistPrioritet(var str:string);
{===============================================
If we find the sign of the first priority - we
move it to the right until the next sign, that
was 3 * 4 * 4, after the first pass will be 3 4 * *,
then go with the next character and do the same,
going to the next character or end of the line
Attention! Brackets are treated as one operand,
those 2 * (3 * 4) will turn into 2 (3 * 4) *
================================================}
var i,j:byte;
csign:char;
L,r,ml,mr:Byte;
brk:boolean;
begin
  i:=1;
  l:=0;
  r:=0;
  while(i<=Length(str)) do
  begin
    case str[i] of
      ')': Inc(r);
      '(': Inc(l);
    end;
    if((str[i] in prior1) and (l=r)) then
    begin
      csign:=str[i];
      str[i]:= ' ';
      ml:=0;
      mr:=0;
      j:=i;
      brk:=false;
      while((j <= length(str)+1) and (not brk)) do
      begin
        case str[j] of
          ')': Inc(mr);
          '(': Inc(ml);
        end;
        if (((str[j] in sign) or(str[j] = '')) and (ml=mr)) then
        begin
          Insert(' ' + csign,str,j);
          i:=j+1;
          brk:=true;
        end;
        Inc(j);
      end;
    end;
    Inc(i);
  end;
end;

procedure formatingSecondPrioritet(var str:string);
{==================================================
If we find the sign of the second priority - we move
it to the right until the next sign of the second
priority, those were 3 + 4 + 4, after the first pass
will be 3 4 + +, then go with the next symbol and do
the same, going to the next character or end of the
line
Attention! Parentheses are treated as one operand,
those 2 + (3 + 4) will become 2 (3 + 4) +
===================================================}
var i,j:byte;
csign:char;
l,r,ml,mr:Byte;
brk:Boolean;
begin
  i:=1;
  l:=0;
  r:=0;
  while(i<=Length(str)) do
  begin
    case str[i] of
      ')': Inc(r);
      '(': Inc(l);
    end;
    if((str[i] in prior2) and (l=r)) then
    begin
      csign:=str[i];
      str[i]:= ' ';
      ml:=0;
      mr:=0;
      j:=i+1;
      brk:=false;
      //for j:=i+1 to Length(str)+1 do
      while((j<=Length(str)+1) and (not brk)) do
      begin
        case str[j] of
          ')': Inc(mr);
          '(': Inc(ml);
        end;
        if (((str[j] in prior2) or(str[j] = '')) and (ml=mr)) then
        begin
          Insert(' ' + csign,str,j);
          i:=j+1;
          brk:=true;
        end;
        Inc(j);
      end;
    end;
    Inc(i);
  end;
end;

procedure workWithParentheses(var str:string);
{=======================================================
In the procedure, work is in progress on the brackets,
where they are opened in turn, calling first the procedure
for the first priority, then for the second. For example
(2 + 3 * (4 + 3 * (3 + 4)) + 2) will first process
2 + 3 * (4 + 3 * (3 + 4)) + 2, and then open the
remaining brackets
========================================================}
var substr:string;
    i,j,lpos,rpos,nl,nr:byte;
    ParNum:Byte;
    brk: boolean;
begin
  ParNum:=0;
  for i:=1 to Length(str) do
  begin
    if(str[i] = '(') then
      Inc(ParNum);
  end;
  while (ParNum <> 0) do
  begin
    j:=1;
    brk:=false;
    //for j:=1 to Length(str) do
    while ((j <= length(str)) and (not brk)) do
    begin
      if(str[j]  = '(') then
      begin
        lpos:=j;
        brk:=true;
      end;
      inc(j);
    end;
    nl:=0;
    nr:=0;
    //for j:=lpos to Length(str) do
    j:=lpos;
    brk:=false;
    while((j<=length(str)) and (not brk)) do
    begin
      if(str[j]  = '(') then
        Inc(nl);
      if(str[j]  = ')') then
        Inc(nr);
      if((str[j]  = ')') and (nr = nl)) then
      begin
        rpos:=j;
        brk:=true;
      end;
      inc(j);
    end;
    substr:=Copy(str,lpos+1,rpos-lpos-1);
    Delete(str,lpos,rpos-lpos+1);
    formatingFistPrioritet(substr);
    formatingSecondPrioritet(substr);
    Insert(substr,str,lpos);
    Dec(ParNum);
  end;
end;

begin
  error:='';
  Writeln(rsEnterExpr);
  repeat
    errstatus:=false;
    if (error <> '') then
    begin
      Writeln('===============================================================');
      writeln(rsErrorFound);
      Writeln(error);
      Writeln(#10#13, rsReenter);
      Writeln('===============================================================');
    end;
    Readln(expr);
    error:='';
    removeSpaces(Expr);
    //Writeln(expr);
    if (expr = '') then
      isErr:=true
    else
      isErr:=isErrorExpression(ErrStatus,Expr,error);
  until(not isErr);
  formatingFistPrioritet(Expr);
  formatingSecondPrioritet(Expr);
  workWithParentheses(Expr);
  Writeln(expr);
  Readln;
end.
