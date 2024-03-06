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
    códigodeerror:Integer;
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
    Conexión: TFDConnection;
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
    Imágenes: TImageList;
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
    procedure ConexiónBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ConexiónAfterConnect(Sender: TObject);
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

procedure TDatoscentrales.ConexiónAfterConnect(Sender: TObject);
begin
    IF scriptCarga.ExecuteAll then
    begin
      tbUsuarios.Open;
      tbProyectos.Open;
    end;
end;

procedure TDatoscentrales.ConexiónBeforeConnect(Sender: TObject);
VAR
    RUTA:string;
begin
  {$IF DEFINED(iOS) or DEFINED(ANDROID)}
//  {$IFDEF ANDROID}
  RUTA:=
    TPath.Combine(TPath.GetDocumentsPath,'SeguimientoDeObras.db');
  conexión.Params.Values['ColumnMetadataSupported'] := 'False' ;
  conexión.Params.Values['Database'] :=RUTA;
  {$ENDIF}
end;

procedure TDatoscentrales.DataModuleCreate(Sender: TObject);
begin
    if not Conexión.CONNECTED then
        Conexión.Connected:=True;
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
    transacción:TFDTransaction;
    resultado:registroderespuesta;
begin
    transacción:=TFDTransaction.Create(SELF);
    insertador:=TFDCommand.Create(SELF);
    transacción.Connection:=Conexión;
    insertador.Connection:=Conexión;
    transacción.Options.AutoStart:=False;
    transacción.Options.AutoCommit:=False;
    insertador.Transaction:=transacción;
    transacción.StartTransaction;
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
        transacción.Commit;
        Result.Mensaje:='Usuario validado';
        tbUsuarios.Refresh;
        Result.esvalidado:=True;
        Result.códigodeerror:=0;
    except
        On e:EFDDBEngineException do
        begin
          Resultado.Mensaje:=e.Message;
          Resultado.códigodeerror:=e.ErrorCode;
          Resultado.esvalidado:=False;
        end;
        else
        begin
          Resultado.Mensaje:='Error no determinado';
          Resultado.códigodeerror:=-5000;
          Resultado.esvalidado:=False;
        end;
        transacción.Rollback;
    END;
    finally
        insertador.Free;
        transacción.Free;
        Result:=resultado;

    end;
end;
function TDatoscentrales.insertalafoto(imageninsertada: TBitmap;
  latitudinsertada, longitudinsertada, usuarioenviadorinsertado: string;
  conceptodelproyectoinsertado, proyectoinsertado: Integer;
  comentariosinsertado: STRING): registroderespuesta;
VAR
    INSERTADOR:TFDCommand;
    TRANSACCIÓN:TFDTransaction;
    FLUJOPARAINSERTAR:TStream;
    RESULTADO:registroderespuesta;
begin
    RESULTADO.códigodeerror:=0;
    RESULTADO.Mensaje:='Empezando la operación';
    RESULTADO.esvalidado:=False;
    TRANSACCIÓN:=TFDTransaction.Create(SELF);
    TRANSACCIÓN.Connection:=Conexión;
    TRANSACCIÓN.Options.AutoStart:=FALSE;
    TRANSACCIÓN.Options.AutoCommit:=False;
    INSERTADOR:=TFDCommand.Create(SELF);
    INSERTADOR.Connection:=Conexión;
    INSERTADOR.Transaction:=TRANSACCIÓN;
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
    TRANSACCIÓN.StartTransaction;
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
            TRANSACCIÓN.Commit;
            RESULTADO.Mensaje:='Validado';
            RESULTADO.esvalidado:=True;

        EXCEPT
            On e:
            EFDDBEngineException do
            begin
                RESULTADO.Mensaje:='Hay un error de base de datos: '+Chr(13)+
                    e.Message;
                RESULTADO.códigodeerror:=e.ErrorCode;
            end;
            else
            begin
                RESULTADO.Mensaje:='Error de proceso ';
            end;
        end;
    FINALLY
        Result:=RESULTADO;
        INSERTADOR.Free;
        TRANSACCIÓN.Free;
    END;
end;

function TDatosCentrales.insertausuario(usuarionuevo,clavesecretanueva,
    nombrepropio,apellidopaterno,apellidomaterno:string): registroderespuesta;
var
    objetojson:TJSONObject;
    respuestajson :TJSONValue;
    transacción:TFDTransaction;
    insertador:TFDCommand;
    resultado:registroderespuesta;
    errorlocal,errorremoto:Integer;
begin
    errorlocal:=0;
    errorremoto:=0;
    //inserto local
      transacción:=TFDTransaction.Create(self);
      transacción.Connection:=Conexión;
      transacción.Options.AutoStart:=false;
      transacción.Options.AutoCommit:=False;
      insertador:=TFDCommand.Create(self);
      insertador.Connection:=Conexión;
      insertador.Transaction:=transacción;
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
      transacción.StartTransaction;
      try
        try
          //ejecuta la inserción local
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
          transacción.Commit;

        except
            On E:EFDDBEngineException do
            begin
                transacción.Rollback;
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
  transacción:TFDTransaction;
begin
    //Iniciando el comando y la transacción
    comandolocalsql:=TFDCommand.Create(self);
    transacción:=TFDTransaction.Create(self);
    comandolocalsql.Connection:=Conexión;
    transacción.Connection:=Conexión;
    transacción.Options.AutoStart:=False;
    transacción.Options.AutoCommit:=False;
    comandolocalsql.Transaction:=transacción;
    //Inicio la transacción
    transacción.StartTransaction;
    RESULTADO.esvalidado:=False;
    RESULTADO.Mensaje:='Iniciando';
    arreglo:=objetojson.GetValue<tjsonarray>('Tablas');
    try
    try
      for elemento in arreglo do
      begin
           nombredelatabla:=elemento.GetValue<string>('Tabla');
           campos:=elemento.GetValue<TJSONArray>('Nombres');
           //Aquí se crea la base del update
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
      transacción.Commit;
      RESULTADO.esvalidado:=True;
      RESULTADO.Mensaje:='Terminado';
    except
        On e:EFDDBEngineException do
        begin
          RESULTADO.esvalidado:=False;
          RESULTADO.Mensaje:=e.Message+' '+RESULTADO.Mensaje;
          RESULTADO.códigodeerror:=e.ErrorCode;
        end;
    end;
    finally
        comandolocalsql.Free;
        transacción.Free;
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
   contador,máximo:Integer;
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
     máximo:=tipos.Count-1;
     textodelosvalores:=' (';
     for contador := 0 to máximo do
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








































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































