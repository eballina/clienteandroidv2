program ClienteV2;

uses
  System.StartUpCopy,
  FMX.Forms,
  PrincipalCod in 'PrincipalCod.pas' {frmPrincipal},
  TomadeFotosCod in 'TomadeFotosCod.pas' {frmTomadefotos},
  PermisosCod in 'PermisosCod.pas' {frmPermisos},
  SeleccionaProyectosCod in 'SeleccionaProyectosCod.pas' {frmSeleccionaProyecto},
  DatoscentralesCod in 'DatoscentralesCod.pas' {Datoscentrales: TDataModule},
  EnviarFotosCod in 'EnviarFotosCod.pas' {frmEnviarFotos};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDatoscentrales, Datoscentrales);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
