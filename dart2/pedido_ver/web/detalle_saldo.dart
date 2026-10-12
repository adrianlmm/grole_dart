library DetalleSaldo;

class DetalleSaldo{
    String Documento;
    String DocumentoCargo;
    DateTime Fecha;
    DateTime FechaVence;
    String Concepto;
    double SaldoInicial;
    double Cargos;
    double Abonos;
    double SaldoFinal;
    
    DetalleSaldo.fromMap(AMap){
        
        this.Documento      = AMap['Documento'];
        this.DocumentoCargo = AMap['DocumentoCargo'];
        
        String pFecha       = AMap['Fecha'];
        pFecha              = pFecha.substring(6, 19);
        this.Fecha          = new DateTime.fromMillisecondsSinceEpoch(int.parse(pFecha));
        pFecha              = AMap['FechaVence'];
        pFecha              = pFecha.substring(6, 19);
        this.FechaVence     = new DateTime.fromMillisecondsSinceEpoch(int.parse(pFecha));
        this.Concepto       = AMap['Concepto'];
        this.SaldoInicial   = AMap['SaldoInicial'];
        this.Cargos         = AMap['Cargos'];
        this.Abonos         = AMap['Abonos'];
        this.SaldoFinal     = AMap['SaldoFinal'];
      
    }
}