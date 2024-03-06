unit PrincipalCod;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
    {$IFDEF ANDROID}
    Androidapi.Helpers,Androidapi.JNI.JavaTypes,Androidapi.JNI.OS,
    System.Permissions,Androidapi.JNI.Telephony,Androidapi.JNI.Provider,
    Androidapi.JNIBridge,Androidapi.JNI.GraphicsContentViewText,
    FMX.Helpers.Android,Androidapi.Jni.App,
    {$ENDIF}
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  System.Actions, FMX.ActnList, FireDAC.Comp.QBE;

type
  TfrmPrincipal = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    botónSincronizar: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Acciones: TActionList;
    AccióndePermisos: TAction;
    AccióndeTomadeFotos: TAction;
    AcciónDeEnviar: TAction;
    AccióndeSincronizar: TAction;
    CornerButton1: TCornerButton;
    procedure AccióndeTomadeFotosExecute(Sender: TObject);
    procedure AccióndePermisosExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AccióndeSincronizarExecute(Sender: TObject);
  private
    { Private declarations }
    inicio:Boolean;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

uses PermisosCod, TomadeFotosCod, SeleccionaProyectosCod, DatoscentralesCod;
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmPrincipal.AccióndePermisosExecute(Sender: TObject);
begin
    if not Assigned(frmPermisos) then
        frmPermisos:=TfrmPermisos.Create(self);
    frmPermisos.Show;
end;

procedure TfrmPrincipal.AccióndeSincronizarExecute(Sender: TObject);
var
    respuesta:registroderespuesta;
begin
    respuesta:=Datoscentrales.actualizalastablaslocales(
        datoscentrales.tbUsuariosUSUARIO.value,
        datoscentrales.tbUsuariosCLAVESECRETA.Value);

end;

procedure TfrmPrincipal.AccióndeTomadeFotosExecute(Sender: TObject);
begin
    if not Assigned(frmTomadefotos) then
        frmTomadefotos:=TfrmTomadefotos.Create(Self);
    frmTomadefotos.Show;
end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
begin
    if inicio then
    begin
      inicio:=false;
      if not Assigned(frmPermisos) then
        frmPermisos:=TfrmPermisos.Create(self);
      frmPermisos.Show;
    end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
    permisodeaccesoalteléfono,
    permisodecámara,
    permisodelectura,
    permisodeescritura,
    permisodeubicación:string;
    permisoautorizado:Boolean;
begin

//Sección de validación de permisos de Android
  {$IFDEF ANDROID}
    permisodelectura:=JStringToString(
        TJManifest_permission.JavaClass.read_EXTERNAL_STORAGE);
    permisodeaccesoalteléfono:=JStringToString(TJManifest_permission.JavaClass.
        READ_PHONE_STATE);
    permisodeescritura:=JStringToString(TJManifest_permission.JavaClass.
        WRITE_EXTERNAL_STORAGE);
    permisodecámara:=JStringToString(TJManifest_permission.JavaClass.
        CAMERA);
    permisodeubicación:=JStringToString(TJManifest_permission.JavaClass.
        ACCESS_FINE_LOCATION);
//Solicitud de permisos
    PermissionsService.RequestPermissions([permisodeaccesoalteléfono,
    permisodelectura,permisodeescritura,permisodecámara,permisodeubicación],
      procedure(const APermissions: TClassicStringDynArray; const
        AGrantResults: TClassicPermissionStatusDynArray)
      begin
//Respuesta acceso al Tel fono
        permisoautorizado:=
            ((Length(AGrantResults) = 5) and
                (AGrantResults[0] =TPermissionStatus.Granted));
//Respuesta de lectura
        permisoautorizado:=
            ((Length(AGrantResults) = 5) and
                (AGrantResults[1] =TPermissionStatus.Granted));
//Respuesta de escritura
        permisoautorizado:=
            ((Length(AGrantResults) = 5) and
            (AGrantResults[2] =TPermissionStatus.Granted));
//Respuesta de Cámara
        permisoautorizado:=(Length(AGrantResults) = 5) and
            (AGrantResults[3] =TPermissionStatus.Granted);

//Permiso sensor GPS
        permisoautorizado:=(Length(AGrantResults) = 5) and
            (AGrantResults[4] =TPermissionStatus.Granted);
      end);

{$ENDIF}

    inicio:=True;
end;

end.
