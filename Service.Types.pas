unit Service.Types;

interface

uses
  IdHashMessageDigest, SysUtils;

type
  IAdapter = interface
    function EmployeesToTerminal: Boolean;     // ��������� ����������� � ��������
    function EmployeesFromTerminal: Boolean;   // ��������� ����������� �� ���������
  end;

  function md5(s: string): string;

implementation

function md5(s: string): string;
begin
  Result := '';
  with TIdHashMessageDigest5.Create do
  try
    Result := AnsiLowerCase(HashStringAsHex(s));
  finally
    Free;
  end;
end;

end.
