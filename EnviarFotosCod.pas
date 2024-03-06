unit EnviarFotosCod;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors;

type
  TfrmEnviarFotos = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    ListView1: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField1: TLinkListControlToField;
    ToolBar1: TToolBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEnviarFotos: TfrmEnviarFotos=nil;

implementation

{$R *.fmx}

uses DatoscentralesCod;

procedure TfrmEnviarFotos.Button1Click(Sender: TObject);
begin
    Close;
end;

procedure TfrmEnviarFotos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        Action:=TCloseAction.caFree;
end;

procedure TfrmEnviarFotos.FormCreate(Sender: TObject);
begin
    Label1.Text:=
        Datoscentrales.tbUsuariosNOMBRE.Value+' '+
        Datoscentrales.tbUsuariosAPELLIDOPATERNO.value+' '+
        datoscentrales.tbUsuariosAPELLIDOMATERNO.Value;
end;

procedure TfrmEnviarFotos.FormDestroy(Sender: TObject);
begin
    frmEnviarFotos:=nil;
    ListView1.Selected
end;

end.
