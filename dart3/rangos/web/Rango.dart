import 'dart:html';
import 'dart:convert';

typedef void onEditRowEvent(Rango ARango);

class Rango{

    int Clave;
    double RangoInicial;
    double RangoFinal;
    double PrecioInterno;
    double PrecioExterno;

    Rango(){

    }

    onEditRowEvent _onEditRowEvent = null;

    void set onEditRow(onEditRowEvent event){
        _onEditRowEvent = event;
    }


    factory Rango.fromMap(Map AItem){

        Rango pRango = new Rango();

        pRango.Clave         = AItem["clave"];
        pRango.RangoInicial  = AItem["rangoinicial"];
        pRango.RangoFinal    = AItem["rangofinal"];
        pRango.PrecioInterno = AItem["precio_interno"];
        pRango.PrecioExterno = AItem["precio_externo"];

        return pRango;
    }

    String toJSON(){

        Map pMap = new Map();
        pMap["clave"]          = this.Clave;
        pMap["rangoinicial"]   = this.RangoInicial;
        pMap["rangofinal"]     = this.RangoFinal;
        pMap["precio_interno"] = this.PrecioInterno;
        pMap["precio_externo"] = this.PrecioExterno;

        return JSON.encode(pMap);
    }

    toString(){
        return "Clave: ${this.Clave}, RangoInicial: ${this.RangoInicial}, "
            "RangoFinal: ${this.RangoFinal}, PrecioInterno: ${PrecioInterno}, "
            "PrecioExterno: ${PrecioExterno}";
    }

    Rango _clone(){

        Rango pRango         = new Rango();
        pRango.Clave         = this.Clave;
        pRango.RangoInicial  = this.RangoInicial;
        pRango.RangoFinal    = this.RangoFinal;
        pRango.PrecioInterno = this.PrecioInterno;
        pRango.PrecioExterno = this.PrecioExterno;
        pRango._onEditRowEvent = this._onEditRowEvent;

        return pRango;

    }

    toTableRow({Rango ARango = null}){

        if (ARango == null){
            ARango = this;
        }

        TableRowElement tr = new TableRowElement()..id = "tr${ARango.Clave}";

        TableCellElement td = new TableCellElement();
        td.text = ARango.RangoInicial.toStringAsFixed(2);
        td.style.textAlign = "right";
        tr.children.add(td);

        td = new TableCellElement();
        td.text = ARango.RangoFinal.toStringAsFixed(2);
        td.style.textAlign = "right";
        tr.children.add(td);

        td = new TableCellElement();
        td.text = ARango.PrecioInterno.toStringAsFixed(2);
        td.style.textAlign = "right";
        tr.children.add(td);

        td = new TableCellElement();
        td.text = ARango.PrecioExterno.toStringAsFixed(2);
        td.style.textAlign = "right";
        tr.children.add(td);

        ButtonElement btnModificar = new ButtonElement();
        btnModificar.text = "M";
        btnModificar.onClick.listen((_){
           tr.replaceWith(ARango._toEditRow());
        });

        tr.children.add(btnModificar);

        return tr;
    }

    _toEditRow(){
        TableRowElement tr = new TableRowElement()..id = "tr${this.Clave}";

        TableCellElement td              = new TableCellElement();
        TextInputElement inpRangoInicial = new TextInputElement();
        inpRangoInicial.value            = this.RangoInicial.toStringAsFixed(2);
        inpRangoInicial.style.textAlign  = "right";
        inpRangoInicial.onChange.listen((_) => this.RangoInicial = double.parse(inpRangoInicial.value));
        td.children.add(inpRangoInicial);
        td.style.textAlign = "right";
        tr.children.add(td);

        td                               = new TableCellElement();
        TextInputElement inpRangoFinal   = new TextInputElement();
        inpRangoFinal.value            = this.RangoFinal.toStringAsFixed(2);
        inpRangoFinal.style.textAlign  = "right";
        inpRangoFinal.onChange.listen((_) => this.RangoFinal = double.parse(inpRangoFinal.value));
        td.children.add(inpRangoFinal);
        td.style.textAlign = "right";
        tr.children.add(td);

        td                                 = new TableCellElement();
        TextInputElement inpPrecioInterno  = new TextInputElement();
        inpPrecioInterno.value             = this.PrecioInterno.toStringAsFixed(2);
        inpPrecioInterno.style.textAlign   = "right";
        inpPrecioInterno.onChange.listen((_) => this.PrecioInterno = double.parse(inpPrecioInterno.value));
        td.children.add(inpPrecioInterno);
        td.style.textAlign = "right";
        tr.children.add(td);

        td                                = new TableCellElement();
        TextInputElement inpPrecioExterno = new TextInputElement();
        inpPrecioExterno.onChange.listen((_) => this.PrecioExterno = double.parse(inpPrecioExterno.value));
        inpPrecioExterno.value             = this.PrecioExterno.toStringAsFixed(2);
        inpPrecioExterno.style.textAlign   = "right";
        td.children.add(inpPrecioExterno);
        td.style.textAlign = "right";
        tr.children.add(td);

        ButtonElement btnEditar = new ButtonElement();
        btnEditar.text = "G";
        btnEditar.onClick.listen((_){
            tr.replaceWith(this.toTableRow());
            if (this._onEditRowEvent != null){
                this._onEditRowEvent(this);
            }
        });

        tr.children.add(btnEditar);

        ButtonElement btnCancelar = new ButtonElement();
        btnCancelar.text = "X";
        btnCancelar.onClick.listen((_){
            var pCloned = this._clone();
            tr.replaceWith(pCloned.toTableRow());
        });

        tr.children.add(btnCancelar);

        return tr;

    }

}