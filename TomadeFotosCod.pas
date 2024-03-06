unit TomadeFotosCod;

interface

uses
  {$IFDEF ANDROID} Androidapi.Helpers, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.OS, System.Permissions, Androidapi.JNI.Telephony,
  Androidapi.JNI.Provider, Androidapi.JNIBridge,
  Androidapi.JNI.GraphicsContentViewText, FMX.Helpers.Android,
  Androidapi.Jni.App, {$ENDIF} Data.Bind.Components, Data.Bind.Controls,
  Data.Bind.DBScope, Data.Bind.EngExt, FMX.ActnList, FMX.Controls,
  FMX.Controls.Presentation, FMX.Dialogs, FMX.Forms, FMX.Graphics, FMX.Layouts,
  FMX.ListBox, FMX.Media, FMX.MediaLibrary, FMX.MediaLibrary.Actions, FMX.Memo,
  FMX.Memo.Types, FMX.MultiView, FMX.ScrollBox, FMX.StdActns, FMX.StdCtrls,
  FMX.TMSFNCCustomControl, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCImage, FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TabControl, FMX.Types,
  Fmx.Bind.DBEngExt, Fmx.Bind.Editors, Fmx.Bind.Navigator, System.Actions,
  System.Bindings.Outputs, System.Classes, System.Rtti, System.Sensors,
  System.Sensors.Components, System.SysUtils, System.Types, System.UITypes,
  System.Variants;

type
  TfrmTomadefotos = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    Páginas: TTabControl;
    tabProyectos: TTabItem;
    tabFotografías: TTabItem;
    BotónFotos: TButton;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    botóncomentarios: TCornerButton;
    ActionList1: TActionList;
    SeleccionaProyectos: TAction;
    SeleccionaFotografiar: TAction;
    SeleccionaComentarios: TAction;
    TomaFoto: TTakePhotoFromCameraAction;
    Localizador: TLocationSensor;
    Camarita: TCameraComponent;
    fotito: TImageControl;
    ToolBar2: TToolBar;
    MiraConfirmación: TMultiView;
    Memo1: TMemo;
    ComboBox1: TComboBox;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    NextTabAction1: TNextTabAction;
    PreviousTabAction1: TPreviousTabAction;
    ToolBar3: TToolBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    insertalafoto: TAction;
    Cancelafoto: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SeleccionaFotografiarExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TomaFotoDidFinishTaking(Image: TBitmap);
    procedure PáginasChange(Sender: TObject);
    procedure insertalafotoExecute(Sender: TObject);
    procedure CancelafotoExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    { Private declarations }
    latitudleída,longitudleída:string;
    fotografiando:Boolean;
    fototemporal:TBitmap;
  public
    { Public declarations }
  end;

var
  frmTomadefotos: TfrmTomadefotos=nil;

implementation

{$R *.fmx}

uses
  DatoscentralesCod;



procedure TfrmTomadefotos.SeleccionaFotografiarExecute(Sender: TObject);
begin
    Páginas.ActiveTab:=
        tabFotografías;
end;

procedure TfrmTomadefotos.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
begin
    insertalafoto.Enabled:=fotografiando;
    botóncomentarios.Enabled:=fotografiando;
    Cancelafoto.Enabled:=fotografiando;
end;

procedure TfrmTomadefotos.Button1Click(Sender: TObject);
begin
//    Camarita.Active:=False;
    Self.close;
end;

procedure TfrmTomadefotos.CancelafotoExecute(Sender: TObject);
begin
    fotografiando:=False;
    fotito.Bitmap.Clear(0);
end;

procedure TfrmTomadefotos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 //   Action:=TCloseAction.caFree;
end;

procedure TfrmTomadefotos.FormCreate(Sender: TObject);
var
    permisodeaccesoalteléfono,
    permisodecámara,
    permisodelectura,
    permisodeescritura,
    permisodeubicación:string;
    permisoautorizado:Boolean;

begin
     fotografiando:=False;
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
        camarita.Active:=permisoautorizado;
        Tomafoto.Enabled:=permisoautorizado;
//Permiso sensor GPS
        permisoautorizado:=(Length(AGrantResults) = 5) and
            (AGrantResults[4] =TPermissionStatus.Granted);
        localizador.active:=permisoautorizado;
      end);

{$ENDIF}


end;

procedure TfrmTomadefotos.FormDestroy(Sender: TObject);
begin

    frmTomadefotos:=nil;
end;

procedure TfrmTomadefotos.insertalafotoExecute(Sender: TObject);
var
    éxito:registroderespuesta;
begin
    éxito:=Datoscentrales.insertalafoto(fotito.Bitmap,latitudleída,longitudleída,
        Datoscentrales.tbusuariosUSUARIO,Datoscentrales.tbProyectosPROYECTO.Value,
        Datoscentrales.tbProyectosPROYECTO.Value,Memo1.Text);
    fotografiando:=False;
end;

procedure TfrmTomadefotos.PáginasChange(Sender: TObject);
begin
if Páginas.ActiveTab=tabProyectos then
begin
    if not Datoscentrales.tbsitios.active then
    begin
        datoscentrales.tbSitios.Open;
        Datoscentrales.tbProyectos.Open;
        Datoscentrales.tbConceptos.open;
    end;
end;

end;

procedure TfrmTomadefotos.TomaFotoDidFinishTaking(Image: TBitmap);
var
  latitud,longitud:double;
  MyRect: TRectF;
  anchodelcuadro,altodelcuadro:integer;
  altodelafoto:integer;
  puntoinicial:TPoint;
  brinco:string;
  localización:string;
//  resultado:registroderespuesta;
begin
    fotografiando:=True;//la foto se aceptó y se debe guardar o cancelar
    Fotito.Bitmap.Assign(image);
        anchodelcuadro:=320;
    altodelcuadro:=320;
    altodelafoto:=image.Canvas.Height;
    brinco:=chr(13);
    puntoinicial.X:=10;
    puntoinicial.Y:=altodelafoto-altodelcuadro;
    latitud:=
        localizador.Sensor.Latitude;
    longitud:=
        localizador.Sensor.Longitude;
    latitudleída:=latitud.ToString;
    longitudleída:=longitud.ToString;
   localización:=
 //       datoscentrales.damelosdatosdelconcepto(BUSCAconcepto.LookupValue.
 //       ToInteger)+
        brinco+
        'Latitud: '+latitud.ToString+
        brinco+'Longitud: '+longitud.ToString+
        brinco+DateTimeToStr(Now);
    MyRect := TRectF.Create(puntoinicial,anchodelcuadro,altodelcuadro);
    fotito.Bitmap.Canvas.Font.Size:=24;
    fotito.Bitmap.Canvas.Font.Style :=[tfontstyle.fsbold];
       fotito.Bitmap.Canvas.BeginScene;
    fotito.Bitmap.Canvas.FillText(MyRect, localización, false, 100,
      [TFillTextFlag.RightToLeft], TTextAlign.leading,
      TTextAlign.trailing);
    fotito.Bitmap.Canvas.EndScene;
    MiraConfirmación.ShowMaster;
end;

end.
