library Clases;

class Clase{
    int Id;
    String Nombre;
    String Activo;
    
    Clase(this.Id, this.Nombre, this.Activo);
    
    Clase.fromMap(Map AMap){
        this.Id     = AMap['id'];
        this.Nombre = AMap['clase'];
        this.Activo = AMap['activo'];
    }
}