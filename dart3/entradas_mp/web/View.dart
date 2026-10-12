import 'dart:html';

class View{

    final ButtonElement _btnDatosAduana = querySelector("#btnDatosAduana");
    final DialogElement _dlgDatosAduana  = querySelector("#dlgDatosAduana");
    final ButtonElement _btnAceptarDlgDatosAduanales = querySelector("#btnAceptarDlgDatosAduanales");

    View(){
        _init();
    }

    _init(){

        print("Inicializando...");
        _btnDatosAduana.onClick.listen((_){
             _dlgDatosAduana.showModal();
        });

        _btnAceptarDlgDatosAduanales.onClick.listen((_){
            _dlgDatosAduana.close("OK");
        });
    }
}