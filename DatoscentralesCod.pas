unit DatoscentralesCod;

interface

uses
  Data.Bind.Components, Data.Bind.ObjectScope, Data.DB, FMX.ImgList,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands, FireDAC.Comp.UI, FireDAC.DApt, FireDAC.DApt.Intf,
  FireDAC.DatS, FireDAC.FMXUI.Error, FireDAC.FMXUI.Wait, FireDAC.Phys,
  FireDAC.Phys.IBBase, FireDAC.Phys.IBWrapper, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Async, FireDAC.Stan.Def, FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Pool, FireDAC.Stan.Util, FireDAC.UI.Intf,
  REST.Client, REST.Types, System.Classes, System.IOUtils, System.ImageList,
  System.JSON, System.StrUtils, System.SysUtils,FMX.Graphics;

type
  registroderespuesta=record
    Mensaje:string;
    esvalidado:Boolean;
    c�digodeerror:Integer;
  end;
  tusuariovalidado=record
    esvalidado:Boolean;
    mensaje:string;
    NombrePropio:string;
    apellidopaterno:string;
    ApellidoMaterno:string;
    usuarioactivo:Boolean;
  end;
  TDatoscentrales = class(TDataModule)
    Conexi�n: TFDConnection;
    trLee: TFDTransaction;
    trEscribe: TFDTransaction;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    scriptCarga: TFDScript;
    FDGUIxErrorDialog1: TFDGUIxErrorDialog;
    tbusuariosUSUARIO: TWideStringField;
    tbusuariosCLAVESECRETA: TWideStringField;
    tbusuariosNOMBRE: TWideStringField;
    tbusuariosAPELLIDOPATERNO: TWideStringField;
    tbusuariosAPELLIDOMATERNO: TWideStringField;
    tbusuariosESTADOACTUAL: TWideStringField;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    tbFotos: TFDQuery;
    dsUsuarios: TDataSource;
    tbFotosFOTO: TFDAutoIncField;
    tbFotosNOMBREDELSITIO: TWideStringField;
    tbFotosdescripcion: TWideStringField;
    tbFotosIMAGEN: TBlobField;
    Im�genes: TImageList;
    tbProyectos: TFDQuery;
    tbusuarios: TFDQuery;
    tbSitios: TFDQuery;
    tbSitiosSITIO: TIntegerField;
    tbSitiosLATITUD: TWideStringField;
    tbSitiosLONGITUD: TWideStringField;
    tbSitiosNOMBREDELSITIO: TWideStringField;
    tbSitiosUSUARIO: TWideStringField;
    dsSitios: TDataSource;
    tbProyectosPROYECTO: TIntegerField;
    tbProyectosDESCRIPCION: TWideMemoField;
    tbProyectosSITIO: TIntegerField;
    tbProyectosTODOSPUEDENTOMARFOTOS: TIntegerField;
    dsproyectos: TDataSource;
    tbConceptos: TFDQuery;
    tbConceptosCONCEPTODELPROYECTO: TIntegerField;
    tbConceptosDESCRIPCIONDELAETAPA: TWideStringField;
    tbConceptosPROYECTO: TIntegerField;
    FDQuery1: TFDQuery;
    FDQuery1FOTO: TFDAutoIncField;
    FDQuery1IMAGEN: TBlobField;
    FDQuery1LATITUD: TWideStringField;
    FDQuery1LONGITUD: TWideStringField;
    FDQuery1USUARIOENVIADOR: TWideStringField;
    FDQuery1FECHADETOMA: TWideMemoField;
    FDQuery1FECHADEENVIO: TWideMemoField;
    FDQuery1CONCEPTODELPROYECTO: TIntegerField;
    FDQuery1PROYECTO: TIntegerField;
    FDQuery1STATUS: TWideStringField;
    FDQuery1COMENTARIOS: TBlobField;
    procedure Conexi�nBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure Conexi�nAfterConnect(Sender: TObject);
  private
    servidor:string;
    puerto:string;
    urlbase:string;
   function generaeltextodelosvalores(tipos, valores: TJSONArray)
    : string;
  function obtieneeltextodelvalor(tipo:string;valor:tjsonvalue)
    :string;

  function creaelupdate(nombredelatabla:string;nombresdeloscampos:
    tjsonarray):string;
  public   { Private declarations }
    FUNCTION actualizalosdatos(objetojson: tjsonvalue):registroderespuesta;
    function validausuario(usuario, clavesecreta: string;
        Esalta:boolean):tusuariovalidado;
    function insertausuariolocal(usuarionuevo,clavesecretanueva,
    nombrepropio,apellidopaterno,apellidomaterno:string): registroderespuesta;
    function insertausuario(usuarionuevo,clavesecretanueva,
    nombrepropio,apellidopaterno,apellidomaterno:string): registroderespuesta;
    function actualizalastablaslocales(usuario,clavesecreta:string):registroderespuesta;
    function insertalafoto(imageninsertada:TBitmap;
        latitudinsertada,longitudinsertada,usuarioenviadorinsertado:string;
        conceptodelproyectoinsertado,proyectoinsertado:Integer;
        comentariosinsertado:STRING):registroderespuesta;
    { Public declarations }
  end;

var
  Datoscentrales: TDatoscentrales;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDatoscentrales.Conexi�nAfterConnect(Sender: TObject);
begin
    IF scriptCarga.ExecuteAll then
    begin
      tbUsuarios.Open;
      tbProyectos.Open;
    end;
end;

procedure TDatoscentrales.Conexi�nBeforeConnect(Sender: TObject);
VAR
    RUTA:string;
begin
  {$IF DEFINED(iOS) or DEFINED(ANDROID)}
//  {$IFDEF ANDROID}
  RUTA:=
    TPath.Combine(TPath.GetDocumentsPath,'SeguimientoDeObras.db');
  conexi�n.Params.Values['ColumnMetadataSupported'] := 'False' ;
  conexi�n.Params.Values['Database'] :=RUTA;
  {$ENDIF}
end;

procedure TDatoscentrales.DataModuleCreate(Sender: TObject);
begin
    if not Conexi�n.CONNECTED then
        Conexi�n.Connected:=True;
    servidor:='192.168.1.17';
    puerto:='8080' ;
    RESTClient1.BaseURL:='http://'+
        servidor+':'+puerto+
        '/datasnap/rest/tservermethods1';
end;

function TDatosCentrales.validausuario(usuario, clavesecreta: string;
    Esalta:boolean):tusuariovalidado;
var
    rutaanterior:string;
    jsonrespuesta:TJSONValue;
begin
    rutaanterior:=RESTClient1.BaseURL;
    try
      RESTClient1.BaseURL:=rutaanterior+'/usuario/'+usuario+'/'+clavesecreta;
      restrequest1.Method:=rmget;
      restrequest1.Resource:='';
      RESTRequest1.Params.Clear;
      restrequest1.Execute;
      jsonrespuesta:=RESTResponse1.JSONValue;
      Result.Mensaje:=jsonrespuesta.GetValue<string>('Resultado');
      Result.esvalidado:=jsonrespuesta.GetValue<boolean>('Validado');
      Result.NombrePropio:=jsonrespuesta.GetValue<string>('NombrePropio');
      Result.apellidopaterno:=jsonrespuesta.GetValue<string>('ApellidoPaterno');
      Result.ApellidoMaterno:=jsonrespuesta.GetValue<string>('ApellidoMaterno');
      Result.usuarioactivo:=jsonrespuesta.GetValue<Boolean>('usuarioactivo');
    finally
        RESTClient1.BaseURL:=rutaanterior;
    end;
end;

function TDatoscentrales.insertausuariolocal(usuarionuevo,clavesecretanueva,
    nombrepropio,apellidopaterno,apellidomaterno:string): registroderespuesta;
var
    insertador:TFDCommand;
    transacci�n:TFDTransaction;
    resultado:registroderespuesta;
begin
    transacci�n:=TFDTransaction.Create(SELF);
    insertador:=TFDCommand.Create(SELF);
    transacci�n.Connection:=Conexi�n;
    insertador.Connection:=Conexi�n;
    transacci�n.Options.AutoStart:=False;
    transacci�n.Options.AutoCommit:=False;
    insertador.Transaction:=transacci�n;
    transacci�n.StartTransaction;
    insertador.CommandText.Text:=
    '''
        INSERT INTO USUARIOS (USUARIO,CLAVESECRETA,NOMBRE,APELLIDOPATERNO,
            APELLIDOMATERNO)
        VALUES
            (:USUARIO,:CLAVESECRETA,:NOMBRE,:APELLIDOPATERNO,:APELLIDOMATERNO)
    ''';
    try
    TRY
        insertador.ParamByName('USUARIO').AsString:=usuarionuevo;
        insertador.ParamByName('CLAVESECRETA').AsString:=clavesecretanueva;
        insertador.ParamByName('NOMBRE').AsString:=nombrepropio;
        insertador.ParamByName('APELLIDOPATERNO').AsString:=apellidopaterno;
        insertador.ParamByName('apellidomaterno').ASSTRING:=APELLIDOMATERNO;
        insertador.EXECUTE;
        transacci�n.Commit;
        Result.Mensaje:='Usuario validado';
        tbUsuarios.Refresh;
        Result.esvalidado:=True;
        Result.c�digodeerror:=0;
    except
        On e:EFDDBEngineException do
        begin
          Resultado.Mensaje:=e.Message;
          Resultado.c�digodeerror:=e.ErrorCode;
          Resultado.esvalidado:=False;
        end;
        else
        begin
          Resultado.Mensaje:='Error no determinado';
          Resultado.c�digodeerror:=-5000;
          Resultado.esvalidado:=False;
        end;
        transacci�n.Rollback;
    END;
    finally
        insertador.Free;
        transacci�n.Free;
        Result:=resultado;

    end;
end;
function TDatoscentrales.insertalafoto(imageninsertada: TBitmap;
  latitudinsertada, longitudinsertada, usuarioenviadorinsertado: string;
  conceptodelproyectoinsertado, proyectoinsertado: Integer;
  comentariosinsertado: STRING): registroderespuesta;
VAR
    INSERTADOR:TFDCommand;
    TRANSACCI�N:TFDTransaction;
    FLUJOPARAINSERTAR:TStream;
    RESULTADO:registroderespuesta;
begin
    RESULTADO.c�digodeerror:=0;
    RESULTADO.Mensaje:='Empezando la operaci�n';
    RESULTADO.esvalidado:=False;
    TRANSACCI�N:=TFDTransaction.Create(SELF);
    TRANSACCI�N.Connection:=Conexi�n;
    TRANSACCI�N.Options.AutoStart:=FALSE;
    TRANSACCI�N.Options.AutoCommit:=False;
    INSERTADOR:=TFDCommand.Create(SELF);
    INSERTADOR.Connection:=Conexi�n;
    INSERTADOR.Transaction:=TRANSACCI�N;
    INSERTADOR.CommandKind:=skInsert;
    INSERTADOR.CommandText.Text:=
    '''
        INSERT INTO FOTOS (IMAGEN,LATITUD,LONGITUD,USUARIOENVIADO,
            CONCEPTODELPROYECTO,PROYECTO,COMENTARIOS)
        VALUES
            (:IMAGENINSERTADA,:LATITUDINSERTADA, :LONGITUDINSERTADA,
            :USUARIOENVIADORINSERTADO,:CONCEPTODELPROYECTOINSERTADO,
            :PROYECTOINSERTADO,:COMENTARIOINSERTADO)
    ''';
    FLUJOPARAINSERTAR:=TStream.Create;
    TRANSACCI�N.StartTransaction;
    TRY
        try
            imageninsertada.SaveToStream(FLUJOPARAINSERTAR);
            FLUJOPARAINSERTAR.Position:=0;
            INSERTADOR.ParamByName('IMAGENINSERTADA').AsStream:=
                FLUJOPARAINSERTAR;
            INSERTADOR.ParamByName('LATITUDINSERTADA').AsString:=
                latitudinsertada;
            INSERTADOR.ParamByName('LONGITUDINSERTADA').AsString:=
                longitudinsertada;
            INSERTADOR.ParamByName('USUARIOENVIADORINSERTADO').AsString:=
                usuarioenviadorinsertado;
            INSERTADOR.ParamByName('CONCEPTODELPROYECTOINSERTADO').AsInteger:=
                conceptodelproyectoinsertado;
            INSERTADOR.ParamByName('PROYECTOINSERTADO').AsInteger:=
                proyectoinsertado;
            INSERTADOR.ParamByName('COMENTARIOINSERTADO').AsString:=
                comentariosinsertado;
            INSERTADOR.Execute;
            TRANSACCI�N.Commit;
            RESULTADO.Mensaje:='Validado';
            RESULTADO.esvalidado:=True;

        EXCEPT
            On e:
            EFDDBEngineException do
            begin
                RESULTADO.Mensaje:='Hay un error de base de datos: '+Chr(13)+
                    e.Message;
                RESULTADO.c�digodeerror:=e.ErrorCode;
            end;
            else
            begin
                RESULTADO.Mensaje:='Error de proceso ';
            end;
        end;
    FINALLY
        Result:=RESULTADO;
        INSERTADOR.Free;
        TRANSACCI�N.Free;
    END;
end;

function TDatosCentrales.insertausuario(usuarionuevo,clavesecretanueva,
    nombrepropio,apellidopaterno,apellidomaterno:string): registroderespuesta;
var
    objetojson:TJSONObject;
    respuestajson :TJSONValue;
    transacci�n:TFDTransaction;
    insertador:TFDCommand;
    resultado:registroderespuesta;
    errorlocal,errorremoto:Integer;
begin
    errorlocal:=0;
    errorremoto:=0;
    //inserto local
      transacci�n:=TFDTransaction.Create(self);
      transacci�n.Connection:=Conexi�n;
      transacci�n.Options.AutoStart:=false;
      transacci�n.Options.AutoCommit:=False;
      insertador:=TFDCommand.Create(self);
      insertador.Connection:=Conexi�n;
      insertador.Transaction:=transacci�n;
      insertador.CommandKind:=skInsert;
      insertador.CommandText.Text
       :=
          '''
              insert into usuarios (usuario,clavesecreta,nombre,
                  apellidopaterno,apellidomaterno)
              values (:usuario,:clavesecreta,:nombre,:apellidopaterno,
                  :apellidomaterno);
          ''';
      insertador.ParamByName('usuario').AsString:=usuarionuevo;
      insertador.ParamByName('clavesecreta').AsString:=clavesecretanueva;
      insertador.ParamByName('nombre').AsString:=nombrepropio;
      insertador.ParamByName('apellidopaterno').AsString:=apellidopaterno;
      insertador.ParamByName('apellidomaterno').AsString:=apellidomaterno;
      transacci�n.StartTransaction;
      try
        try
          //ejecuta la inserci�n local
          insertador.Execute;
          //ejecuta la solicitud local
          objetojson:=TJSONObject.Create(TJSONPair.Create('usuarionuevo',
            TJSONString.Create(usuarionuevo)));
          objetojson.AddPair(TJSONPair.Create('clavesecretanueva',
            TJSONString.Create(clavesecretanueva)));
          objetojson.AddPair(TJSONPair.Create('Nombrepropio',
            TJSONString.Create(nombrepropio)));
          objetojson.AddPair(TJSONPAIR.Create('ApellidoPaterno',
              TJSONString.Create(apellidopaterno)));
          objetojson.AddPair(TJSONPair.Create('ApellidoMaterno',
              TJSONString.Create(apellidomaterno)));
          restrequest1.Method:=rmput;
          restrequest1.Resource:='usuario';
          restrequest1.Params.Clear;
          restrequest1.Params.AddItem;
          restrequest1.Params.Items[0].Value:=objetojson.ToString;
          restrequest1.Params.Items[0].Name:='Entrada';
          restrequest1.Params.Items[0].Kind   :=pkREQUESTBODY;
          restrequest1.Params.Items[0].ContentType:=ctapplication_json;
          restrequest1.Execute;
          transacci�n.Commit;

        except
            On E:EFDDBEngineException do
            begin
                transacci�n.Rollback;
                resultado.Mensaje:= E.Message;
                errorremoto :=E.ErrorCode;
            end;
        end;

      finally
            respuestajson:=RESTResponse1.JSONValue;
            if errorremoto<>0 then
                Resultado.Mensaje:=respuestajson.GetValue<string>('Resultado');
            Resultado.esvalidado:=respuestajson.GetValue<boolean>('Validado');
      end;





end;

function tdatoscentrales.actualizalastablaslocales(usuario,clavesecreta:string)
:registroderespuesta;
var
  jsonparam:tjsonvalue;
  objetojson:TJSONObject;
begin
    Result.esvalidado:=False;
    Result.Mensaje:='Iniciando';
    objetojson:=TJSONObject.Create;
    restrequest1.Params.Clear;
    restrequest1.Method:=rmpost;
    objetojson:=TJSONObject.Create;
    objetojson.AddPair(TJSONPair.Create('NombreDeUsuario',
    TJSONString.Create(usuario)));
    objetojson.AddPair(TJSONPair.Create('ClavedeUsuario',
    TJSONString.Create(clavesecreta)));
    restrequest1.Resource:='datossincronizados';
    restrequest1.Params.AddItem;
    restrequest1.Params.Items[0].Value:=objetojson.ToString;
    restrequest1.Params.Items[0].Name:='Usuario';
    restrequest1.Params.Items[0].Kind
       :=pkrequestbody;
    restrequest1.Params.Items[0].ContentType
    :=ctapplication_json;
    restrequest1.Execute;
  jsonparam:=restresponse1.jsonvalue;
  Result.Mensaje:='Respuesta obtenida';
  Result:=actualizalosdatos(jsonparam);
end;

FUNCTION TDAtosCentrales.actualizalosdatos(objetojson: tjsonvalue):
    registroderespuesta;
var
  arreglo,campos,tipos,arreglodevalores:tjsonarray;
  elemento,registro:tjsONValue;
  nombredelatabla:string;
  textodelupdate,textodelosvalores,textoejecutable:string;
  RESULTADO:registroderespuesta;
  comandolocalsql:TFDCommand;
  transacci�n:TFDTransaction;
begin
    //Iniciando el comando y la transacci�n
    comandolocalsql:=TFDCommand.Create(self);
    transacci�n:=TFDTransaction.Create(self);
    comandolocalsql.Connection:=Conexi�n;
    transacci�n.Connection:=Conexi�n;
    transacci�n.Options.AutoStart:=False;
    transacci�n.Options.AutoCommit:=False;
    comandolocalsql.Transaction:=transacci�n;
    //Inicio la transacci�n
    transacci�n.StartTransaction;
    RESULTADO.esvalidado:=False;
    RESULTADO.Mensaje:='Iniciando';
    arreglo:=objetojson.GetValue<tjsonarray>('Tablas');
    try
    try
      for elemento in arreglo do
      begin
           nombredelatabla:=elemento.GetValue<string>('Tabla');
           campos:=elemento.GetValue<TJSONArray>('Nombres');
           //Aqu� se crea la base del update
           textodelupdate:=creaelupdate(nombredelatabla,campos);
           tipos:=elemento.GetValue<tjsonarray>('Tipos');
           arreglodevalores:=elemento.GetValue<tjsonarray>('Datos');
           for registro In arreglodevalores do
           begin
                textodelosvalores:=
                Generaeltextodelosvalores(tipos,registro.GetValue<TJSONArray>);
                textoejecutable:=textodelupdate+textodelosvalores;
                Comandolocalsql.CommandText.Clear;
                RESULTADO.mensaje:=RESULTADO.Mensaje+Chr(13)+textoejecutable;
                Comandolocalsql.Execute(textoejecutable);

           end;
      end;
      transacci�n.Commit;
      RESULTADO.esvalidado:=True;
      RESULTADO.Mensaje:='Terminado';
    except
        On e:EFDDBEngineException do
        begin
          RESULTADO.esvalidado:=False;
          RESULTADO.Mensaje:=e.Message+' '+RESULTADO.Mensaje;
          RESULTADO.c�digodeerror:=e.ErrorCode;
        end;
    end;
    finally
        comandolocalsql.Free;
        transacci�n.Free;
        Result:=RESULTADO;
    end;
end;

function TDAtosCentrales.creaelupdate(nombredelatabla:string;nombresdeloscampos:
    tjsonarray):string;
var
   textodelsql,textodeloscampos:string;
   elemento:TJSONValue;
function textodeloscamposmodificado(textoanalizado:string):string;
var
   textodesalida:string;
begin
     textodesalida:=textoanalizado;
   if textodesalida<>' (' then
      textodesalida:=textodesalida+', ';
   Result:=textodesalida;
end;
begin
     textodelsql:='insert or ignore into '+nombredelatabla;
     textodeloscampos:=' (';
     for elemento In nombresdeloscampos do
     begin
          textodeloscampos:= textodeloscamposmodificado(textodeloscampos)+
                             elemento.value;
     end;
     result:=textodelsql+textodeloscampos+')';
end;

function TDAtosCentrales.generaeltextodelosvalores(tipos, valores: TJSONArray)
    : string;
var
   contador,m�ximo:Integer;
   tipo,textodelosvalores:string;
function textodelosvaloresmodificado(textoanalizado:string):string;
var
textodesalida:string;
begin
     textodesalida:=textoanalizado;
   if textodesalida<>' (' then
      textodesalida:=textodesalida+', ';
   Result:=textodesalida;
end;

begin
     m�ximo:=tipos.Count-1;
     textodelosvalores:=' (';
     for contador := 0 to m�ximo do
     begin
          tipo:=tipos.Items[contador].Value;
          textodelosvalores:= textodelosvaloresmodificado(textodelosvalores)+
            obtieneeltextodelvalor(tipo,valores.Items[contador]);
     end;
     textodelosvalores:=textodelosvalores+')';
     Result:=' values'+textodelosvalores;
end;

function TDAtosCentrales.obtieneeltextodelvalor(tipo:string;valor:tjsonvalue)
    :string;
const
    comilla='''';
var
   textodelvalor:string;
begin
     textodelvalor:=valor.Value;
     if matchtext(tipo,['STRING','WIDESTRING']) then
     textodelvalor:=comilla+textodelvalor+comilla;
     Result:=textodelvalor;
end;


end.








































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































