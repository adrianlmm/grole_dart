import 'dart:convert';

class Empresa{

    int Id;
    String Nombre;

    Empresa(this.Id, this.Nombre);

    factory Empresa.fromMap(Map AItem) => new Empresa(AItem["id"], AItem["nombre"]);

    toString() => "Id: ${this.Id}, Nombre: ${this.Nombre}";

}