unit PermisosCod;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, System.Actions,
  FMX.ActnList;

type
  TfrmPermisos = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    Panel1: TPanel;
    Button2: TButton;
    Layout1: TLayout;
    LabelUsuario: TLabel;
    EditUsuario: TEdit;
    LabelPassword: TLabel;
    EditPassword: TEdit;
    CheckBoxNuevoUsuario: TCheckBox;
    PanelNuevoUsuario: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    ActionList1: TActionList;
    ActValidar: TAction;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBoxNuevoUsuarioChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActValidarExecute(Sender: TObject);
  private
    { Private declarations }
    function coalesce(texto1,TEXTO2:string):string;
  public
    { Public declarations }
  end;

var
  frmPermisos: TfrmPermisos=nil;

implementation

{$R *.fmx}

uses PrincipalCod, DatoscentralesCod;
function TfrmPermisos.coalesce(texto1,TEXTO2:string):string;
begin
    if texto2.IsNullOrEmpty(texto2) then
        RESULT:=''
    else
    begin
        Result:=texto1;
    end;;
end;

procedure TfrmPermisos.ActValidarExecute(Sender: TObject);
var
    aceptado:Boolean;
    usuariocreado:registroderespuesta;
begin
    aceptado:=False;
//buscamos al usuario suponiendo que está presente
    if not CheckBoxNuevoUsuario.IsChecked then
    BEGIN
      if Datoscentrales.tbUsuarios.Locate('usuario;clavesecreta',
          VarArrayOf([EditUsuario.Text,EditPassword.text]),[]) then
      begin
      //Se halló el usuario y el password y valida si está activo
        aceptado:=True;
        if Datoscentrales.tbUsuariosESTADOACTUAL.Value<>'Validado'
            then showmessage(
            '''
                Usuario sin validación central. Puede tomar fotos pero necesita autorización para enviar. Solicítela');
            ''');
      end
      else
        ShowMessage('Usuario no encontrado. Active la opción de alta');
    END
    else
    //Se va a dar de alta a un usuario local nuevo
    begin
        usuariocreado:=Datoscentrales.insertausuariolocal(
            EditUsuario.Text,EditPassword.Text,Edit1.Text,
            Edit2.Text,Edit3.text);
        If usuariocreado.códigodeerror<>0 then
            ShowMessage(usuariocreado.códigodeerror.ToString
                +' '+ usuariocreado.Mensaje);
        aceptado:=usuariocreado.esvalidado;
    end;
      //si no está activo, checa con el servidor central
//      else
//      begin
//          //Validar remoto...
//          VALIDACIÓNREMOTA:=
//              Datoscentrales.validausuario(EditUsuario.Text,EditPassword.Text,
//              false);
//          //Si la validación es completa, y está activo, actualizamos.
//          if VALIDACIÓNREMOTA.usuarioactivo then
//          begin
//            textodelsql:=
//                'update USUARIOS set '+
//                'NOMBRE='+VALIDACIÓNREMOTA.NombrePropio+
//                COALESCE(', APELLIDOPATERNO='+VALIDACIÓNREMOTA.apellidopaterno,
//                    VALIDACIÓNREMOTA.apellidopaterno)+
//                coalesce(', APELLIDOMATERNO='+VALIDACIÓNREMOTA.ApellidoMaterno,
//                VALIDACIÓNREMOTA.ApellidoMaterno)+
//                ' ESTADOACTUAL=Validado where usuario='+EditUsuario.text;
//            Datoscentrales.Conexión.ExecSQL(textodelsql);
//            aceptado:=True;
//          end
//          //si no se validó centralmente, mandar mensaje de error
//          else
//              ShowMessage('Por favor solicitar su alta con su Administrador');
//        end;
//    END
//    else
//    //Vamos a dar de alta un usuario
//    begin
//    //primero intentamos insertar localmente
//    try
//
//    finally
//
//    end;
//
//    try
//
//    finally
//
//    end;
//        usuariocreado:=
//            Datoscentrales.insertausuario(EditUsuario.Text,
//                EditPassword.Text,Edit1.Text,Edit2.Text,Edit3.text);
//        if usuariocreado.esvalidado then
//            ShowMessage('El usuario está pendiente de autorización.'+Chr(13)+
//                'Por favor comuníquese con su administrador');
//    end;
    if aceptado then
        Close;

end;

procedure TfrmPermisos.Button1Click(Sender: TObject);
begin
    Self.close;
end;

procedure TfrmPermisos.CheckBoxNuevoUsuarioChange(Sender: TObject);
begin
    PanelNuevoUsuario.Visible:=
        CheckBoxNuevoUsuario.IsChecked;

end;

procedure TfrmPermisos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action:=TCloseAction.caFree;
end;

procedure TfrmPermisos.FormCreate(Sender: TObject);
begin
    CheckBoxNuevoUsuario.IsChecked:=False;
    PanelNuevoUsuario.Visible:=
        CheckBoxNuevoUsuario.IsChecked;
end;

procedure TfrmPermisos.FormDestroy(Sender: TObject);
begin
    frmPermisos:=nil;
end;

end.
