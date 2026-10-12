import 'dart:html';
import 'dart:convert';
//import 'dart:math' as math;

InputElement inpOrden = querySelector('#inpOrden');
TableElement tablaUsoEmpaque = querySelector('#tablaUsoEmpaque');
ButtonElement btnConsultar = querySelector('#btnConsultar');

SpanElement spanTotalUsoEmpaque = querySelector('#spanTotalUsoEmpaque');
SpanElement spanTotalCantidadEntregada = querySelector('#spanTotalCantidadEntregada');
SpanElement spanTotalDiferencia = querySelector('#spanTotalDiferencia');
SpanElement spanTotalGeneral = querySelector('#spanTotalGeneral');
SpanElement spanTotalGeneral2 = querySelector('#spanTotalGeneral2');
SpanElement spanTotalDiferenciaM = querySelector('#spanTotalDiferenciaM');

var pTotalCantidadUsada = 0.0;
var pTotalCantidadEntregada = 0.0;
var pTotalDiferencia = 0.0;
var pTotalGeneral = 0.0;
var pTotalGeneral2 = 0.0;
var pTotalDiferenciaM = 0.0;

double agregarFila(Map AItem) {
  var pResult = 0.0;
  var tr = TableRowElement()..id = '${AItem['id']}';
  var td = TableCellElement()..text = AItem['id_orden'].toString();
  tr.children.add(td);
  td = TableCellElement()..text = AItem['codigosap'];
  tr.children.add(td);
  td = TableCellElement()..text = AItem['nombre'];
  tr.children.add(td);

  var pUsado = 0.0;

  try {
    pUsado = AItem['usado'].toDouble();
  } catch (_) {
    pUsado = 0.0;
  }

  tr.children.add(td);
  td = TableCellElement()
    ..text = pUsado.toDouble().toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);
  var pCantidadEntregada = 0.0;

  try {
    pCantidadEntregada = AItem['cantidad_entregada'].toDouble();
  } catch (_) {
    pCantidadEntregada = 0.0;
  }

  var pDiferencia = (pCantidadEntregada - pUsado.toDouble());

  td = TableCellElement()
    ..text = pCantidadEntregada.toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);
  td = TableCellElement()
    ..text = pDiferencia.toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);

  var pCosto = 0.0;

  try {
    pCosto = AItem['costo_empaque'].toDouble();
  } catch (_) {
    pCosto = 0.0;
  }

  td = TableCellElement()
    ..text = pCosto.toDouble().toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);

  td = TableCellElement()
    ..text = (pCosto.toDouble() * pUsado).toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);

  td = TableCellElement()
    ..text = (pCosto.toDouble() * pCantidadEntregada).toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);

  td = TableCellElement()
    ..text = (pCosto.toDouble() * pDiferencia).toStringAsFixed(2)
    ..style.textAlign = 'right';
  tr.children.add(td);

  pResult += (pCosto.toDouble() * pDiferencia);

  tablaUsoEmpaque.tBodies[0].children.add(tr);

  return pResult;
}

void consultar() {
  var pUrl = 'http://localhost:8031/rest/obtener_uso_empaque_orden?orden=${inpOrden.value}';

  btnConsultar.disabled = true;
  HttpRequest.getString(pUrl).then((String Data) {
    var pLista = jsonDecode(Data);

    pTotalCantidadUsada = 0.0;
    pTotalDiferencia = 0.0;
    pTotalGeneral = 0.0;
    pTotalGeneral2 = 0.0;
    pTotalCantidadEntregada = 0.0;
    pTotalDiferenciaM = 0.00;

    tablaUsoEmpaque.tBodies[0].children.clear();

    var pCSV = '';

    print(pLista);
    for (var item in pLista) {
      try {
        pTotalDiferenciaM += agregarFila(item);
      } catch (_) {
        pTotalDiferenciaM += 0;
      }

      try {
        pTotalCantidadUsada += item['usado'].toDouble();
      } catch (_) {
        item['usado'] = 0.0;
        pTotalCantidadUsada += 0;
      }

      try {
        pTotalCantidadEntregada += item['cantidad_entregada'];
      } catch (_) {
        pTotalCantidadEntregada += 0;
      }

      try {
        pTotalGeneral += ((item['usado']) * item['costo_empaque']);
      } catch (_) {
        pTotalGeneral += 0;
      }

      try {
        pTotalGeneral2 += ((item['cantidad_entregada']) * item['costo_empaque']);
      } catch (_) {
        pTotalGeneral2 += 0;
      }

      var pCantidadEntregada = 0.0;
      try {
        pCantidadEntregada = item['cantidad_entregada'].toDouble();
      } catch (_) {
        pCantidadEntregada = 0.0;
      }
      var pCosto = 0.0;
      try {
        pCosto = ((item['usado']) * item['costo_empaque']);
      } catch (_) {
        pCosto = 0.0;
      }
      var pCosto2 = 0.0;
      try {
        pCosto2 = ((item['usado']) * item['cantidad_entregada']);
      } catch (_) {
        pCosto2 = 0.0;
      }

      var pDiferenciaM = 0.0;
      /*try {
        //pDiferenciaM = item['costo_empaque'] * (item['cantidad_entregada'].toDouble() - item['usado']);
        pDiferenciaM = item['cantidad_entregada'].toDouble() - item['usado'];
      } catch (_) {
        pDiferenciaM = 0.0;
      }*/

      pTotalDiferenciaM += pDiferenciaM;
      print(pTotalDiferenciaM.toStringAsFixed(2));

      pCSV += inpOrden.value +
          ',' +
          item['codigosap'] +
          ',' +
          item['nombre'] +
          ',' +
          item['usado'].toString() +
          ',' +
          pCantidadEntregada.toString() +
          ',' +
          (pCantidadEntregada - item['usado']).toString() +
          ',' +
          item['costo_empaque'].toString() +
          ',' +
          pCosto.toString() +
          ',' +
          pCosto2.toString() +
          ',' +
          pDiferenciaM.toString() +
          '\n';
    }

    print(pTotalCantidadUsada.runtimeType);
    spanTotalUsoEmpaque.innerHtml = pTotalCantidadUsada.toStringAsFixed(2);
    spanTotalCantidadEntregada.innerHtml = pTotalCantidadEntregada.toStringAsFixed(2);
    spanTotalDiferencia.innerHtml = (pTotalCantidadEntregada - pTotalCantidadUsada).toStringAsFixed(2);
    spanTotalGeneral.innerHtml = pTotalGeneral.toStringAsFixed(2);
    spanTotalGeneral2.innerHtml = pTotalGeneral2.toStringAsFixed(2);
    spanTotalDiferenciaM.innerHtml = pTotalDiferenciaM.toStringAsFixed(2);

    AnchorElement pExcel = document.querySelector('#aExcel');
    pExcel.href = '/excel/uso_empaque_orden_${inpOrden.value}.xls';

    btnConsultar.disabled = false;
  });
}

void init() {
  btnConsultar.onClick.listen((_) {
    try {
      consultar();
    } finally {}
  });
}

void main() {
  init();
}
