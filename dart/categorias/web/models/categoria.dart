library Categoria_Entidad;
import '../views/categoria_/lista.dart';
import 'dart:html';
import 'dart:json' as json;

class Categoria_{

  int Id;
  String Categoria;
  String Activo;
  bool Dirty;

  Categoria_(this.Id, this.Categoria, this.Activo, this.Dirty);
  Categoria_.fromMap(Map AMap){

    this.Id = AMap['id'];
    this.Categoria = AMap['categoria'];
    this.Activo = AMap['activo'];

  }

  String toJSON(){
    Map pMapa = new Map();
    pMapa['id'] = this.Id;
    pMapa['categoria'] = this.Categoria;
    pMapa['activo'] = this.Activo;

    return json.stringify(pMapa);
  }
}

class ListaCategoria_{
  List<Categoria_> _ListaCategoria_;
  ViewListaCategoria_ _ViewCategoria_;

  ListaCategoria_(ViewListaCategoria_ AVistaCategoria_){
    this._ListaCategoria_ = new List<Categoria_>();
    this._ViewCategoria_ = AVistaCategoria_;
    this._ViewCategoria_.setListaCategoria_(this);
  }

  add(Categoria_ ACategoria_){
    this._ListaCategoria_.add(ACategoria_);
    this._ViewCategoria_.addCategoria_(ACategoria_, 0);
  }

  void _onError(Object t){
    window.alert('Error al en la operación, verifíque su conexión');
  }

  insert(Categoria_ ACategoria_){
    var pUrl = 'http://localhost:8031/rest/categorias/insertar';
    String pData = ACategoria_.toJSON();

    Map pHeaders = new Map();
    pHeaders['content-type'] = 'application/json';

    HttpRequest.request(pUrl, method: 'POST', requestHeaders: pHeaders, sendData: pData).then((HttpRequest ARequest){

      Categoria_ pCategoria_ = new Categoria_.fromMap(json.parse(ARequest.responseText));

      this._ListaCategoria_.insert(0, pCategoria_);
      this._ViewCategoria_.addCategoria_(pCategoria_, 1);

    }, onError: this._onError);
  }

  remove(int AId){

    var  pUrl = 'http://localhost:8031/rest/categorias/eliminar/${AId}';

    HttpRequest.request(pUrl, method: 'DELETE').then((_) {
      this._ListaCategoria_.removeWhere((Categoria_ x) => (x.Id == AId));
      this._ViewCategoria_.remove(AId);
    }, onError: this._onError);

  }

  edit(Categoria_ ACategoria_){
    var pUrl = 'http://localhost:8031/rest/categorias/actualizar';
    Categoria_ pCategoria_ = this.get(ACategoria_.Id);

    pCategoria_.Id = ACategoria_.Id;
    pCategoria_.Categoria = ACategoria_.Categoria;
    pCategoria_.Activo = ACategoria_.Activo;
    String pData = pCategoria_.toJSON();

    Map pHeaders = new Map();
    pHeaders['content-type'] = 'application/json';
    HttpRequest.request(pUrl, method: 'POST', requestHeaders: pHeaders, sendData: pData).then((HttpRequest ARequest){
      this._ViewCategoria_.setCategoria_(new Categoria_.fromMap((json.parse(ARequest.responseText))));
    }, onError: this._onError);
  }

  Categoria_ get(int AId){
    return this._ListaCategoria_.where((Categoria_ e) => (e.Id == AId)).toList().first;
  }

  List<Categoria_> getDirties(){
    return this._ListaCategoria_.where((Categoria_ e) => (e.Dirty == true)).toList();
  }

}