import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:resource/resource.dart' show Resource;

typedef void onEditRowEvent(Empresa AEmpresa, TableRowElement ATr);
typedef bool onEliminarRowEvent(Empresa AEmpresa);

var myResource = new Resource('/componentes/tabla_empresas.html');
var _pTemplate = "";

Future loadResources() async {
    _pTemplate = await myResource.readAsString();
}

TableElement _tableTemplate = new Element.html(_pTemplate);

class Empresa{

    int Id;
    String _Nombre;
    String Tipo;

    onEditRowEvent _onEditRowEvent = null;
    onEliminarRowEvent _onEliminarRowEvent = null;

    void set Nombre(String AValue){
        if (AValue.length == 0){
            throw new Exception("El valor no puede ser vacío");
        }
        this._Nombre = AValue;
    }

    String get Nombre{
        return this._Nombre;
    }

    void set onEditRow(onEditRowEvent event){
        _onEditRowEvent = event;
    }

    void set onElimarRow(onEliminarRowEvent event){
        _onEliminarRowEvent = event;
    }

    Empresa(this.Id, this._Nombre, this.Tipo);

    factory Empresa.fromMap(Map AItem) => new Empresa(AItem["id"], AItem["nombre"], AItem["tipo"]);

    toJSON() => JSON.encode({"id" : this.Id, "nombre" : this.Nombre, "tipo" : this.Tipo});

    toString() => "Id: ${this.Id}, Nombre: ${this.Nombre}, Tipo: ${this.Tipo}";

    _clone() => new Empresa(this.Id, this.Nombre, this.Tipo);

    toTableRow(){

        TableRowElement tr = _tableTemplate.querySelector("#trDetalle").clone(true);
        tr.id = "tr${this.Id}";

        tr.querySelector("#tdId")..text     = this.Id.toString();
        tr.querySelector("#tdNombre")..text = this.Nombre;
        tr.querySelector("#tdTipo")..text   = this.Tipo;

        tr.querySelector("#btnModificar")..onClick.listen((_) {
            var trTmp = this.toEditRow();
            tr.replaceWith(trTmp);
            trTmp.querySelector("#inpNombre").focus();
        });

        tr.querySelector("#btnEliminar")..onClick.listen((_) async{
            bool pEliminar = await _onEliminarRowEvent(this);

            if (pEliminar) {
                tr.remove();
            }
        });

        return tr;

    }

    TableRowElement toEditRow(){

        TableRowElement tr = _tableTemplate.querySelector("#trDetalleEdit").clone(true);
        tr.id = "tr${this.Id}";

        InputElement inpId = tr.querySelector("#inpId");
        inpId.value   = this.Id.toString();
        inpId.onChange.listen((_) => this.Id = int.parse(inpId.value));

        InputElement inpNombre = tr.querySelector("#inpNombre");
        inpNombre.value   = this.Nombre;
        inpNombre.onBlur.listen((_) {
            try {
                this.Nombre = inpNombre.value;
            }
            catch(_){
                window.alert(_.message);
                inpNombre.focus();
                return;
            }
        });

        SelectElement inpTipo = tr.querySelector("#inpTipo");
        inpTipo.value    = this.Tipo;
        inpTipo.onChange.listen((_) => this.Tipo = inpTipo.value);

        tr.querySelector("#btnEditar")..onClick.listen((_){
            var trTmp = this.toTableRow();
            tr.replaceWith(trTmp);
            if (this._onEditRowEvent != null){
                this._onEditRowEvent(this, trTmp);
            }
        });

        var pCloned = this._clone();

        tr.querySelector("#btnCancelar")..onClick.listen((_) async{
            if (this.Id == 0){
                tr.remove();
            }
            else {
                tr.replaceWith(pCloned.toTableRow());
            }
        });

        return tr;

    }

}