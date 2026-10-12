// ignore_for_file: non_constant_identifier_names

library SalidaInventario;

import 'dart:convert';

class SalidaInventario {
  String DocDate = "";
  String TaxDate = "";
  String Series = "";
  String Reference2 = "";
  String Comments = "";
  String OrdenProduccion = "";
  String FolioSalida = "";

  List<LineaSalidaInventario> Lineas = <LineaSalidaInventario>[];

  toJSON() {
    Map pMap = {};
    pMap["DocDate"] = DocDate;
    pMap["TaxDate"] = TaxDate;
    pMap["Series"] = Series;
    pMap["Reference2"] = Reference2;
    pMap["Comments"] = Comments;
    pMap["OrdenProduccion"] = OrdenProduccion;
    pMap["FolioSalida"] = FolioSalida;
    pMap["Lineas"] = <Map>[];

    for (LineaSalidaInventario item in Lineas) {
      Map pMapaLinea = {};

      pMapaLinea["ItemCode"] = item.ItemCode;
      pMapaLinea["Quantity"] = item.Quantity.toDouble();
      pMapaLinea["WarehouseCode"] = item.WarehouseCode;
      pMapaLinea["AccountCode"] = item.AccountCode;
      pMapaLinea["CostingCode"] = item.CostingCode;
      pMapaLinea["LineTotal"] = item.LineTotal;

      pMap["Lineas"].add(pMapaLinea);
    }

    return jsonEncode(pMap);
  }
}

class LineaSalidaInventario {
  String ItemCode = "";
  double Quantity = 0.0;
  String WarehouseCode = "";
  String AccountCode = "";
  String CostingCode = "";
  double LineTotal = 0.0;
}
