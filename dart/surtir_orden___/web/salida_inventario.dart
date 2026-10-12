library SalidaInventario;

import 'dart:convert';

class SalidaInventario
{
    String DocDate;
    String TaxDate;
    String Series;
    String Reference2;
    String Comments;
    String OrdenProduccion;
    String FolioSalida;

    List<LineaSalidaInventario> Lineas;

    SalidaInventario()
    {
        this.Lineas = new List<LineaSalidaInventario>();
    }
    
    toJSON(){
        Map pMap = new Map();
        pMap["DocDate"]         = this.DocDate;
        pMap["TaxDate"]         = this.TaxDate;
        pMap["Series"]          = this.Series;
        pMap["Reference2"]      = this.Reference2;
        pMap["Comments"]        = this.Comments;
        pMap["OrdenProduccion"] = this.OrdenProduccion;
        pMap["FolioSalida"]     = this.FolioSalida;
        pMap["Lineas"]          = new List<Map>();
        
        for (LineaSalidaInventario item in this.Lineas){
            Map pMapaLinea = new Map();
            
            pMapaLinea["ItemCode"]      = item.ItemCode;
            pMapaLinea["Quantity"]      = item.Quantity.toDouble();
            pMapaLinea["WarehouseCode"] = item.WarehouseCode;
            pMapaLinea["AccountCode"]   = item.AccountCode;
            pMapaLinea["CostingCode"]   = item.CostingCode;
            
            pMap["Lineas"].add(pMapaLinea);
        }
        
        return JSON.encode(pMap);
    }
    
}

class LineaSalidaInventario
{
    String ItemCode;
    double Quantity;
    String WarehouseCode;
    String AccountCode;
    String CostingCode;
}