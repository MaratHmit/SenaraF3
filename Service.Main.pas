unit Service.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.SvcMgr,
  Storage, Vcl.ExtCtrls, Service.Handler, Consts;

type
  TSenaraAdapterF3 = class(TService)
    tmrMain: TTimer;
    tmrClear: TTimer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure tmrMainTimer(Sender: TObject);
    procedure tmrClearTimer(Sender: TObject);
  private

    FHandler: THandler;
    procedure SynchronizeTerminal;

  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  SenaraAdapterF3: TSenaraAdapterF3;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SenaraAdapterF3.Controller(CtrlCode);
end;

function TSenaraAdapterF3.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TSenaraAdapterF3.ServicePause(Sender: TService; var Paused: Boolean);
begin
  tmrMain.Enabled := False;
end;

procedure TSenaraAdapterF3.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FHandler := THandler.Create;

  if DEBUG_MODE then
    FHandler.Debug('ServiceStart');

  FHandler.ReadConfig;
  tmrMain.Enabled := True;
  tmrClear.Enabled := True;
end;

procedure TSenaraAdapterF3.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  if DEBUG_MODE then
    FHandler.Debug('ServiceStop');

  tmrMain.Enabled := False;

  try
    FHandler.Free
  except
  end;
end;

procedure TSenaraAdapterF3.SynchronizeTerminal;
begin
  if DEBUG_MODE then
    FHandler.Debug('SynchronizeTerminal');

  FHandler.Run;
end;

procedure TSenaraAdapterF3.tmrClearTimer(Sender: TObject);
begin
  tmrClear.Enabled := False;
  FHandler.ClearVisitsRusGuard;
  tmrClear.Enabled := True;
end;

procedure TSenaraAdapterF3.tmrMainTimer(Sender: TObject);
begin
  tmrMain.Enabled := False;
  SynchronizeTerminal;
  tmrMain.Enabled := True;
end;

end.
