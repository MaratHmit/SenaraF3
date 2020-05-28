unit Forms.Config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Storage, Api, Consts, LNetworkService,
  Soap.InvokeRegistry, System.Net.URLClient, Soap.Rio, Soap.SOAPHTTPClient, WSSE,
  Vcl.ExtCtrls, Vcl.ComCtrls, VirtualTrees, Forms.CardPoint, Data.DB, MemDS,
  DBAccess, Uni, DataModule, Service.Handler, SuperObject, Vcl.CheckLst;

type

  TfrmSettings = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    pgMain: TPageControl;
    tsRusGuard: TTabSheet;
    tsTerminal: TTabSheet;
    pnlRusGuard: TPanel;
    pnlTerminal: TPanel;
    Label2: TLabel;
    edtURLRusGuard: TEdit;
    Label1: TLabel;
    edtLoginRusGuard: TEdit;
    Label3: TLabel;
    edtPasswordRusGuard: TEdit;
    btnTestRusGuard: TButton;
    Label7: TLabel;
    edtDBServer: TEdit;
    Label8: TLabel;
    edtDBName: TEdit;
    Label9: TLabel;
    edtDBLogin: TEdit;
    edtDBPassword: TEdit;
    Label10: TLabel;
    tsRusGuardImport: TTabSheet;
    cbConnectDB: TCheckBox;
    Panel1: TPanel;
    Label11: TLabel;
    edtEmployeeGroup: TEdit;
    btnSave: TButton;
    Label5: TLabel;
    edtLoginTerminal: TEdit;
    Label6: TLabel;
    edtPasswordTerminal: TEdit;
    tsTests: TTabSheet;
    Panel2: TPanel;
    btnTestEmployes: TButton;
    cbLevels: TCheckListBox;
    Label4: TLabel;
    edtUrlTerminal: TEdit;
    Label12: TLabel;
    btnTestVisits: TButton;
    btnTestAll: TButton;
    btnRemoveAllUsers: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnTestTerminalClick(Sender: TObject);
    procedure btnTestRusGuardClick(Sender: TObject);
    procedure btnRunServiceClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnTestEmployesClick(Sender: TObject);
    procedure tsRusGuardImportShow(Sender: TObject);
    procedure btnTestVisitsClick(Sender: TObject);
    procedure btnRemoveAllUsersClick(Sender: TObject);
  private
    FStorage: TStorage;
    FHandler: THandler;
    FNumRequest: Integer;
    FGuid: string;
    function GetGuid: string;
    procedure SetValuesToControl;
    function ApiConnect: Boolean;
    procedure SetParameters;
    procedure SaveConfig;
    function RusGuardConnect: Boolean;

  public

  end;

var
  frmSettings: TfrmSettings;

implementation

uses
  ServiceFunctions;

{$R *.dfm}

function TfrmSettings.ApiConnect;
var
  Api: TApi;
begin
  Api := TApi.Create;
  try
    Result := Api.Auth;
  finally
    Api.Free
  end;
end;

procedure TfrmSettings.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSettings.btnOkClick(Sender: TObject);
begin
  SaveConfig;
  Close;
end;

procedure TfrmSettings.btnRunServiceClick(Sender: TObject);
begin
  try
    StartService(SERVICE_NAME);
  except
  end;
end;

procedure TfrmSettings.btnTestEmployesClick(Sender: TObject);
begin
  SaveConfig;
  SetParameters;
  FHandler.ApiConnect;
  FHandler.SynchroEmploees;
  FStorage.SaveDateTimeSynhro;
end;

procedure TfrmSettings.btnTestRusGuardClick(Sender: TObject);
begin
  SaveConfig;
  SetParameters;

  if RusGuardConnect then
   Application.MessageBox('����������� � ������� RusGuard �������!', APP_DISPLAY, MB_OK + MB_ICONINFORMATION)
  else
    Application.MessageBox('�� ������� ������������ � ������� RusGuard!', APP_DISPLAY, MB_OK + MB_ICONERROR)
end;

procedure TfrmSettings.btnTestTerminalClick(Sender: TObject);
begin
  SaveConfig;
  if ApiConnect then
    Application.MessageBox('����������� � ������� Terminal �������!', APP_DISPLAY, MB_OK + MB_ICONINFORMATION)
  else
    Application.MessageBox('�� ������� ������������ � ������� Terminal!', APP_DISPLAY, MB_OK + MB_ICONERROR)
end;

procedure TfrmSettings.btnTestVisitsClick(Sender: TObject);
begin
  SaveConfig;
  SetParameters;
  FHandler.ApiConnect;
  FHandler.SynchroVisits;

end;

procedure TfrmSettings.btnRemoveAllUsersClick(Sender: TObject);
begin
  FHandler.RemoveAllUsers;
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  SaveConfig
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  FStorage := TStorage.GetInstance;
  FHandler := THandler.Create;
  FStorage.ReadConfig;
  SetValuesToControl;
  pgMain.ActivePageIndex := 0;
end;

function TfrmSettings.GetGuid: string;
begin
  if FGuid = EmptyStr then
  begin
    FGuid := TGUID.NewGuid.ToString;
    FGuid := StringReplace(FGuid, '{', '', []);
    FGuid := StringReplace(FGuid, '}', '', []);
    FGuid := 'uuid-' + LowerCase(FGuid);
  end;
  Inc(FNumRequest);
  Result := FGuid + '-' + IntToStr(FNumRequest);
end;

procedure TfrmSettings.SaveConfig;
var
  I: Integer;
  Levels: string;
begin
  FStorage.UrlTerminal := Trim(edtUrlTerminal.Text);
  FStorage.LoginTerminal := Trim(edtLoginTerminal.Text);
  FStorage.PasswordTerminal := Trim(edtPasswordTerminal.Text);

  FStorage.UrlRusGuard := Trim(edtURLRusGuard.Text);
  FStorage.LoginRusGuard := Trim(edtLoginRusGuard.Text);
  FStorage.PasswordRusGuard := Trim(edtPasswordRusGuard.Text);
  FStorage.ConnectionFromDB := cbConnectDB.Checked;
  FStorage.DBServerRusGuard := Trim(edtDBServer.Text);
  FStorage.DBNameRusGuard := Trim(edtDBName.Text);
  FStorage.DBLoginRusGuard := Trim(edtDBLogin.Text);
  FStorage.DBPasswordRusguard := Trim(edtDBPassword.Text);
  FStorage.EmployeeGroupName := Trim(edtEmployeeGroup.Text);

  if cbLevels.Count > 0 then
  begin
    Levels := EmptyStr;
    for I := 0 to cbLevels.Count - 1 do
    begin
      if cbLevels.Checked[I] then
      begin
        if Levels <> EmptyStr then
          Levels := Levels + #1;
        Levels := Levels + cbLevels.Items[I];
      end;
    end;
    FStorage.AccessLevels := Levels;
  end;

  FStorage.SaveConfig;
end;

procedure TfrmSettings.SetParameters;
begin
  dmMain.conMain.Server := FStorage.DBServerRusGuard;
  dmMain.conMain.Username := FStorage.DBLoginRusGuard;
  dmMain.conMain.Password := FStorage.DBPasswordRusguard;
end;

procedure TfrmSettings.SetValuesToControl;
begin
  edtUrlTerminal.Text := FStorage.UrlTerminal;
  cbConnectDB.Checked := FStorage.ConnectionFromDB;
  edtURLRusGuard.Text := FStorage.UrlRusGuard;
  edtLoginRusGuard.Text := FStorage.LoginRusGuard;
  edtPasswordRusGuard.Text := FStorage.PasswordRusGuard;
  edtDBServer.Text := FStorage.DBServerRusGuard;
  edtDBName.Text := FStorage.DBNameRusGuard;
  edtDBLogin.Text := FStorage.DBLoginRusGuard;
  edtDBPassword.Text := FStorage.DBPasswordRusguard;
  edtEmployeeGroup.Text := FStorage.EmployeeGroupName;

  edtLoginTerminal.Text := FStorage.LoginTerminal;
  edtPasswordTerminal.Text := FStorage.PasswordTerminal;


end;

procedure TfrmSettings.tsRusGuardImportShow(Sender: TObject);
var
  Query: TUniQuery;
  Levels: TStringList;
  I, J: Integer;
  IsFind: Boolean;
begin
  if cbLevels.Count > 0 then
    Exit;

  SaveConfig;
  SetParameters;
  Query := TUniQuery.Create(nil);
  Query.Connection := dmMain.conMain;
  Query.SQL.Text := 'SELECT * FROM AcsAccessLevel';
  try
    Levels := TStringList.Create;
    try
      Levels.Delimiter := #1;
      Levels.DelimitedText := FStorage.AccessLevels;

      I := 0;
      Query.Open;
      while not Query.Eof do
      begin
        cbLevels.AddItem(Query.FieldByName('Name').AsString, nil);
        IsFind := False;
        for J := 0 to Levels.Count - 1 do
        begin
          IsFind := Levels[J] = Query.FieldByName('Name').AsString;
          if IsFind then
            Break;
        end;
        cbLevels.Checked[I] := IsFind;
        Inc(I);
        Query.Next
      end;

    except

    end;

  finally
    Query.Free;
    Levels.Free
  end;
end;

function TfrmSettings.RusGuardConnect: Boolean;
var
  Service: ILNetworkService;
  ConnectId: string;
  Query: TUniQuery;
begin
  if FStorage.ConnectionFromDB then
  begin
    try
      Query := TUniQuery.Create(nil);
      Query.Connection := dmMain.conMain;
      Query.SQL.Text := 'SELECT 1';
      try
        Query.Open;
        Result := True;
      except
        Result := False;
      end;
    finally
      Query.Free;
    end;
  end
  else
  begin
    Service := GetILNetworkService(True, FStorage.UrlRusGuard);
    try
      PrepareSoapHeader(Service, GetGuid, FStorage.LoginRusGuard, FStorage.PasswordRusGuard);
      ConnectId := Service.Connect;
      PrepareSoapHeader(Service, GetGuid, FStorage.LoginRusGuard, FStorage.PasswordRusGuard);
      Service.Disconnect(ConnectId);
      Result := True;
    except
      Result := False;
    end;
  end;
end;



end.
