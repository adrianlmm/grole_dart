import 'dart:html';
import 'dart:convert';
import 'granjas.dart';
import 'Empresa.dart';

typedef void onEditRowEvent(Granja AGranja, TableRowElement ATr);
typedef bool onEliminarRowEvent(Granja AGranja);

class Granja{
    int Clave;
    String Nombre;
    int Empresa;
    String NombreEmpresa;

    onEditRowEvent _onEditRowEvent = null;
    onEliminarRowEvent _onEliminarRowEvent = null;

    void set onEditRow(onEditRowEvent event){
        _onEditRowEvent = event;
    }

    void set onElimarRow(onEliminarRowEvent event){
        _onEliminarRowEvent = event;
    }

    Granja(){
        this.Clave   = 0;
        this.Nombre  = "";
        this.Empresa = lista_empresas[0].Id;
        this.NombreEmpresa = lista_empresas[0].Nombre;
    }

    factory Granja.fromMap(Map AMap){

        Granja pGranja = new Granja();
        pGranja.Clave         = AMap["clave"];
        pGranja.Nombre        = AMap["nombre"];
        pGranja.Empresa       = AMap["empresa"];
        pGranja.NombreEmpresa = AMap["nombre_empresa"];

        return pGranja;

    }

    String toString(){
        return "Clave: ${this.Clave}, Nombre: ${this.Nombre}, Empresa: ${this.Empresa}, NombreEmpresa: ${this.NombreEmpresa}";
    }

    String toJSON(){
        Map pMap = new Map();
        pMap["clave"]   = this.Clave;
        pMap["nombre"]  = this.Nombre;
        pMap["empresa"] = this.Empresa;
        pMap["nombre_empresa"] = this.NombreEmpresa;

        return JSON.encode(pMap);
    }

    Granja _clone(){

        Granja pGranja  = new Granja();
        pGranja.Clave   = this.Clave;
        pGranja.Nombre  = this.Nombre;
        pGranja.Empresa = this.Empresa;
        pGranja.NombreEmpresa = this.NombreEmpresa;
        pGranja._onEditRowEvent = this._onEditRowEvent;
        pGranja._onEliminarRowEvent = this._onEliminarRowEvent;

        return pGranja;
    }

    TableRowElement toTableRow(){

        TableRowElement tr = new TableRowElement()..id = "tr${this.Clave}";

        TableCellElement td = new TableCellElement();
        td.text = this.Clave.toString();
        tr.children.add(td);

        td = new TableCellElement();
        td.text = this.Nombre;
        tr.children.add(td);

        td = new TableCellElement();
        td.text = this.NombreEmpresa;
        td.dataset = {"IdEmpresa" : this.Empresa};
        tr.children.add(td);

        td = new TableCellElement();
        ButtonElement btnModificar = new ButtonElement();
        btnModificar.text = "M";
        btnModificar.onClick.listen((_){
            tr.replaceWith(this.toEditRow());
        });

        td.children.add(btnModificar);

        ButtonElement btnEliminar = new ButtonElement();
        btnEliminar.text = "E";
        btnEliminar.onClick.listen((_) async {

            bool pEliminar = await _onEliminarRowEvent(this);

            if (pEliminar) {
                tr.remove();
            }
        });

        td.children.add(btnEliminar);
        tr.children.add(td);

        return tr;
    }

    TableRowElement toEditRow(){

        TableRowElement tr = new TableRowElement()..id = "tr${this.Clave}";

        TableCellElement td = new TableCellElement();
        TextInputElement inpClave = new TextInputElement();
        inpClave.value = this.Clave.toString();
        inpClave.disabled = true;
        inpClave.onChange.listen((_) => this.Clave = int.parse(inpClave.value));
        td.children.add(inpClave);
        tr.children.add(td);

        td = new TableCellElement();
        TextInputElement inpNombre = new TextInputElement();
        inpNombre.value    = this.Nombre;
        inpNombre.onChange.listen((_) => this.Nombre = inpNombre.value);
        td.children.add(inpNombre);
        tr.children.add(td);

        td = new TableCellElement();
        SelectElement inpEmpresa = new SelectElement();
        inpEmpresa.value = this.Empresa.toString();

        lista_empresas.forEach((empresa){

            OptionElement pOptionElement = new OptionElement()
            ..value = empresa.Id.toString()
            ..text = empresa.Nombre;

            if (this.Empresa == empresa.Id){
                pOptionElement.selected = true;
            }

            inpEmpresa.children.add(pOptionElement);
        });

        inpEmpresa.onChange.listen((_) {
            this.Empresa       = int.parse(inpEmpresa.options[inpEmpresa.selectedIndex].value);
            this.NombreEmpresa = inpEmpresa.options[inpEmpresa.selectedIndex].text;
        });

        td.children.add(inpEmpresa);
        tr.children.add(td);

        ButtonElement btnEditar = new ButtonElement();
        btnEditar.text = "G";
        btnEditar.onClick.listen((_){
            var trTmp = this.toTableRow();
            tr.replaceWith(trTmp);
            if (this._onEditRowEvent != null){
                this._onEditRowEvent(this, trTmp);
            }
        });

        tr.children.add(btnEditar);

        ButtonElement btnCancelar = new ButtonElement();
        btnCancelar.text = "X";
        var pCloned = this._clone();
        btnCancelar.onClick.listen((_){
            if (this.Clave == 0){
                tr.remove();
            }
            else {
                tr.replaceWith(pCloned.toTableRow());
            }
        });

        tr.children.add(btnCancelar);

        return tr;
    }
}