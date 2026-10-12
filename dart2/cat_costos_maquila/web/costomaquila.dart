library CostoMaquilaEntidad;

import 'dart:json' as json;

class CostoMaquila{

	int Id;
	DateTime Fecha;
	String Descripcion;
	String Activo;
	bool Dirty;

	CostoMaquila(this.Id, this.Fecha, this.Descripcion, this.Activo, this.Dirty);
	CostoMaquila.fromMap(Map AMap){

		this.Id = AMap['id'];
		this.Fecha = AMap['fecha'];
		this.Descripcion = AMap['descripcion'];
		this.Activo = AMap['activo'];

	}

	String toJSON(){
		Map pMapa = new Map();
		pMapa['id'] = this.Id;
		pMapa['fecha'] = this.Fecha;
		pMapa['descripcion'] = this.Descripcion;
		pMapa['activo'] = this.Activo;

		return json.stringify(pMapa);
	}
}