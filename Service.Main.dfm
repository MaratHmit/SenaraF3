object SenaraAdapterF3: TSenaraAdapterF3
  OldCreateOrder = False
  DisplayName = 'Senara '#1072#1076#1072#1087#1090#1077#1088' - 3 '#1101#1090#1072#1078
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 184
  Width = 215
  object tmrMain: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrMainTimer
    Left = 80
    Top = 40
  end
  object tmrClear: TTimer
    Enabled = False
    OnTimer = tmrClearTimer
    Left = 80
    Top = 104
  end
end
