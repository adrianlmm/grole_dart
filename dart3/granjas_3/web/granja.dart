// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:html';
import 'dart:convert';
import 'granjas.dart';

typedef onEditRowEvent = void Function(Granja AGranja, TableRowElement ATr);
typedef onEliminarRowEvent = bool Function(Granja AGranja);

class Granja {
  int Clave = 0;
  String Nombre = "";
  int Empresa = 0;
  String NombreEmpresa = "";

  onEditRowEvent? editRowEvent;
  onEliminarRowEvent? eliminarRowEvent;

  Granja() {
    Clave = 0;
    Nombre = "";
    Empresa = lista_empresas[0].Id;
    NombreEmpresa = lista_empresas[0].Nombre;
  }

  factory Granja.fromMap(dynamic AMap) {
    Granja pGranja = Granja();
    pGranja.Clave = AMap["clave"];
    pGranja.Nombre = AMap["nombre"];
    pGranja.Empresa = AMap["empresa"];
    pGranja.NombreEmpresa = AMap["nombre_empresa"];

    return pGranja;
  }

  @override
  String toString() {
    return "Clave: $Clave, Nombre: $Nombre, Empresa: $Empresa, NombreEmpresa: $NombreEmpresa";
  }

  String toJSON() {
    var pMap = {};
    pMap["clave"] = Clave;
    pMap["nombre"] = Nombre;
    pMap["empresa"] = Empresa;
    pMap["nombre_empresa"] = NombreEmpresa;

    return jsonEncode(pMap);
  }

  Granja _clone() {
    Granja pGranja = Granja();
    pGranja.Clave = Clave;
    pGranja.Nombre = Nombre;
    pGranja.Empresa = Empresa;
    pGranja.NombreEmpresa = NombreEmpresa;

    return pGranja;
  }

  TableRowElement toTableRow() {
    TableRowElement tr = TableRowElement()..id = "tr$Clave";

    TableCellElement td = TableCellElement();
    td.text = Clave.toString();
    tr.children.add(td);

    td = TableCellElement();
    td.text = Nombre;
    tr.children.add(td);

    td = TableCellElement();
    td.text = NombreEmpresa;
    td.dataset = {"IdEmpresa": Empresa.toString()};
    tr.children.add(td);

    td = TableCellElement();
    ButtonElement btnModificar = ButtonElement();
    btnModificar.text = "M";
    btnModificar.onClick.listen((_) {
      tr.replaceWith(toEditRow());
    });

    td.children.add(btnModificar);

    ButtonElement btnEliminar = ButtonElement();
    btnEliminar.text = "E";
    btnEliminar.onClick.listen((_) {
      bool pEliminar = eliminarRowEvent!(this);

      if (pEliminar) {
        tr.remove();
      }
    });

    td.children.add(btnEliminar);
    tr.children.add(td);

    return tr;
  }

  TableRowElement toEditRow() {
    TableRowElement tr = TableRowElement()..id = "tr$Clave";

    TableCellElement td = TableCellElement();
    TextInputElement inpClave = TextInputElement();
    inpClave.value = Clave.toString();
    inpClave.disabled = true;
    inpClave.onChange.listen((_) => Clave = int.parse(inpClave.value!));
    td.children.add(inpClave);
    tr.children.add(td);

    td = TableCellElement();
    TextInputElement inpNombre = TextInputElement();
    inpNombre.value = Nombre;
    inpNombre.onChange.listen((_) => Nombre = inpNombre.value!);
    td.children.add(inpNombre);
    tr.children.add(td);

    td = TableCellElement();
    SelectElement inpEmpresa = SelectElement();
    inpEmpresa.value = Empresa.toString();

    lista_empresas.forEach((empresa) {
      OptionElement pOptionElement = OptionElement()
        ..value = empresa.Id.toString()
        ..text = empresa.Nombre;

      if (Empresa == empresa.Id) {
        pOptionElement.selected = true;
      }

      inpEmpresa.children.add(pOptionElement);
    });

    inpEmpresa.onChange.listen((_) {
      Empresa = int.parse(inpEmpresa.options[inpEmpresa.selectedIndex!].value);
      NombreEmpresa = inpEmpresa.options[inpEmpresa.selectedIndex!].text!;
    });

    td.children.add(inpEmpresa);
    tr.children.add(td);

    ButtonElement btnEditar = ButtonElement();
    btnEditar.text = "G";
    btnEditar.onClick.listen((_) {
      var trTmp = toTableRow();
      tr.replaceWith(trTmp);
      if (editRowEvent != null) {
        editRowEvent!(this, trTmp);
      }
    });

    tr.children.add(btnEditar);

    ButtonElement btnCancelar = ButtonElement();
    btnCancelar.text = "X";
    var pCloned = _clone();
    btnCancelar.onClick.listen((_) {
      if (Clave == 0) {
        tr.remove();
      } else {
        tr.replaceWith(pCloned.toTableRow());
      }
    });

    tr.children.add(btnCancelar);

    return tr;
  }
}
