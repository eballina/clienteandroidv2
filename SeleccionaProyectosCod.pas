unit SeleccionaProyectosCod;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListBox, FMX.ListView, FMX.Layouts, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Actions, FMX.ActnList, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.DBScope;

type
  TfrmSeleccionaProyecto = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    GridPanelLayout1: TGridPanelLayout;
    Button2: TButton;
    ActionList1: TActionList;
    AcciónAbreCamarita: TAction;
    Panel1: TPanel;
    Button3: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    labelProyecto: TLabel;
    comboProyecto: TComboBox;
    labelLugar: TLabel;
    comboLugar: TComboBox;
    labelConcepto: TLabel;
    comboConcepto: TComboBox;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField1: TLinkListControlToField;
    BindSourceDB3: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    LinkListControlToField3: TLinkListControlToField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AcciónAbreCamaritaExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSeleccionaProyecto: TfrmSeleccionaProyecto=nil;

implementation

{$R *.fmx}

uses  TomadeFotosCod, DatoscentralesCod;

procedure TfrmSeleccionaProyecto.AcciónAbreCamaritaExecute(Sender: TObject);
begin
    if not Assigned(frmTomadefotos) then
        frmTomadefotos:=TfrmTomadefotos.Create(Self);
    frmTomadefotos.Show;
end;

procedure TfrmSeleccionaProyecto.Button1Click(Sender: TObject);
begin
    Self.Close;
end;

procedure TfrmSeleccionaProyecto.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action:=TCloseAction.caFree;
end;

procedure TfrmSeleccionaProyecto.FormCreate(Sender: TObject);
begin
    Datoscentrales.tbProyectos.Close;
    Datoscentrales.tbProyectos.Open;
end;

procedure TfrmSeleccionaProyecto.FormDestroy(Sender: TObject);
begin
    frmSeleccionaProyecto:=nil;
end;

end.
