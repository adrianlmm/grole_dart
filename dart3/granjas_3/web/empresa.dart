// ignore_for_file: non_constant_identifier_names

class Empresa {
  int Id;
  String Nombre;

  Empresa(this.Id, this.Nombre);

  factory Empresa.fromMap(Map AItem) => Empresa(AItem["id"], AItem["nombre"]);

  @override
  toString() => "Id: $Id, Nombre: $Nombre";
}
