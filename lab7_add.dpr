program lab7_add;

{$APPTYPE CONSOLE}
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
        error:=error+ #10#13 +' - There are two numbers in a row';
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
    err:= err + #10#13 + ' - At the end of the expression, a sign is found';
  end;
  if (str[1] in prior1) then
  begin
    isError:=true;
    err:= err + #10#13 + ' - At the begin of the expression, a sign is found';
  end;
  while(i <= Length(str)) do
  begin
    if (not (str[i] in acceptChar)) then
    begin
      isError:=true;
      err:= err + #10#13 + ' - Illegal characters used: "' + str[i]+'"';
    end;
    if (str[i] = ')') then
    begin
      Inc(closeparentheses);
      if(str[i+1] in numbers) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - After the parentheses there is no mathematical sign';
      end;
      if(str[i-1] in prior1) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - Before the parentheses there is no mathematical sign';
      end;
    end;
    if (str[i] = '(') then
    begin
      Inc(openparentheses);
      if(str[i-1] in numbers) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - Before the parentheses there is no mathematical sign';
      end;
      if((str[i+1] in prior1) or (str[i+1] = ')')) then
      begin
        isError:=True;
        err:= err + #10#13 + ' - After the parentheses there is no mathematical sign';
      end;
    end;
    if((closeparentheses > openparentheses) and (not isError))then
    begin
      isError:=True;
      err:= err + #10#13 + ' - A closing parenthesis is encountered without an appropriate opening';
    end;
    if ((str[i] in sign) and (str[i+1] in sign)) then
    begin
      isError:=True;
      err:= err + #10#13 + ' - I met two signs in a row. Please use parentheses';
    end;
    inc(i);
  end;
  if (openparentheses <> closeparentheses ) then
  begin
    isError:=true;
    err:= err + #10#13 + ' - The number of opening and closing parentheses does not match';
  end;
  isErrorExpression:=isError;
end;

procedure formatingFistPrioritet(var str:string);
var i,j:byte;
csign:char;
L,r,ml,mr:Byte;
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
      //Delete(str,i,1);
      str[i]:= ' ';
      ml:=0;
      mr:=0;
      for j:=i to Length(str)+1 do
      begin
        case str[j] of
          ')': Inc(mr);
          '(': Inc(ml);
        end;
        if (((str[j] in sign) or(str[j] = '')) and (ml=mr)) then
        begin
          Insert(' ' + csign,str,j);
          i:=j+1;
          break;
        end;
      end;
    end;
    Inc(i);
  end;
end;

procedure formatingSecondPrioritet(var str:string);
var i,j:byte;
csign:char;
l,r,ml,mr:Byte;
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
      //Delete(str,i,1);
      str[i]:= ' ';
      ml:=0;
      mr:=0;
      for j:=i+1 to Length(str)+1 do
      begin
        case str[j] of
          ')': Inc(mr);
          '(': Inc(ml);
        end;
        if (((str[j] in prior2) or(str[j] = '')) and (ml=mr)) then
        begin
          Insert(' ' + csign,str,j);
          i:=j+1;
          break;
        end;
      end;
    end;
    Inc(i);
  end;
end;

procedure workWithParentheses(var str:string);
var substr:string;
    i,j,lpos,rpos,nl,nr:byte;
    ParNum:Byte;
begin
  ParNum:=0;
  for i:=1 to Length(str) do
  begin
    if(str[i] = '(') then
      Inc(ParNum);
  end;
  while (ParNum <> 0) do
  begin
    for j:=1 to Length(str) do
    begin
      if(str[j]  = '(') then
      begin
        lpos:=j;
        Break;
      end;
    end;
    nl:=0;
    nr:=0;
    for j:=lpos to Length(str) do
    begin
      if(str[j]  = '(') then
        Inc(nl);
      if(str[j]  = ')') then
        Inc(nr);
      if((str[j]  = ')') and (nr = nl)) then
      begin
        rpos:=j;
        Break;
      end;
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
  Writeln('Please, enter your mathematical expression');
  repeat
    errstatus:=false;
    if (error <> '') then
    begin
      Writeln('===============================================================');
      writeln('The following errors are entered in the expression you entered:');
      Writeln(error);
      Writeln(#10#13, 'Please re-enter the expression');
      Writeln('===============================================================');
    end;
    Readln(expr);
    error:='';
    removeSpaces(Expr);
    Writeln(expr);
    isErr:=isErrorExpression(ErrStatus,Expr,error);
  until(not isErr);
  formatingFistPrioritet(Expr);
  formatingSecondPrioritet(Expr);
  workWithParentheses(Expr);
  Writeln(expr);
  Readln;
end.
