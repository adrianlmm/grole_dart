function llena_lista_canales(a_select) {

    $.ajax({
        url: "/Granjas/GetGranjas",
        dataType: 'json',
        success: function (data) {
            var a = a_select;
            $.each(data, function () {
                var option = document.createElement("option");
                option.value = this.clave;
                option.text = this.nombre;
                try {
                    a.add(option);
                }
                catch (e) {
                    a.add(option);
                }
            });
        },
        error: function (xhr, errorType, exception) {
                        var errorMessage = exception ? exception : xhr.statusText;

                        alert(errorMessage);
                    }
    });

}

var Grole = function(){
	this.cambiarEstado = function (a_id, callback){
		$(document.body).remove("#consulta_modal");
		$(document.body).append('<div id="consulta_modal" title="Estado Matería Prima" style="display:none"/>');
		
		$("#consulta_modal").empty();
		$("#consulta_modal").append('<h2>Estado de Reporte de Materia Prima</h2> ' +
									'<input type="hidden" id="idLinea" value="<%=@id%>"> ' +
									'<div style="float: left; margin-top: 5px; margin-right: 5px;"> ' +
									'	Subtipo: ' +
									'</div>	' +
									'<div class="editor"> ' +
								    '   <select style="width: 200px;" id="estado"> ' +
									'		<option value="Abierto">Abierto</option> ' +
									'		<option value="Cerrado">Cerrado</option> ' +
									'	</select> ' +
									'</div> ' +
									'<div style="clear:both; margin-top: 5px; margin-left: 190px;"> ' +
									'	<button id="btn1">Aceptar</button> ' +
									'</div>');
									
		document.getElementById('btn1').onclick = function(){
			callback.apply(this, [a_id, document.getElementById('estado').value]);
			$(".ui-dialog-titlebar-close").trigger('click');
		}

		$(function () {
            $("#dialog:ui-dialog").dialog("destroy");
            $("#consulta_modal").dialog({
                height: 500,
                width: 800,
                modal: true,
            });
        });
	};
	
	this.cambiarSubtipo = function (a_id, a_destino, callback){
		$(document.body).remove("#consulta_modal");
		$(document.body).append('<div id="consulta_modal" title="Estado Matería Prima" style="display:none"/>');
		
		$("#consulta_modal").empty();
		$("#consulta_modal").append('<h2>Subtipo de producción</h2>' +
									'<input type="hidden" id="idLinea" value="<%=@id%>"> ' +
									'<div style="float: left; margin-top: 5px; margin-right: 5px;"> ' +
									'	Subtipo: ' +
									'</div>	' +
									'<div class="editor"> ' +
								    '   <select style="width: 200px;" id="subtipo"> ' +
									'		<option value="Produccion">Producción</option> ' +
									'		<option value="Regreso">Regreso</option> ' +
									'	</select> ' +
									'</div> ' +
									'<div style="clear:both; margin-top: 5px; margin-left: 190px;"> ' +
									'	<button id="btn1">Aceptar</button> ' +
									'</div>');
									
		document.getElementById('btn1').onclick = function(){
			callback.apply(this, [a_id, document.getElementById('subtipo').value]);
			$(".ui-dialog-titlebar-close").trigger('click');
		}

		$(function () {
            $("#dialog:ui-dialog").dialog("destroy");
            $("#consulta_modal").dialog({
                height: 500,
                width: 800,
                modal: true,
            });
        });
	};
	
	this.agregarMateriaPrima = function(a_id, a_destino, a_fecha, a_tipo, a_callback){
	
		$(document.body).remove("#consulta_modal");
		$(document.body).append('<div id="consulta_modal" title="Estado Matería Prima" style="display:none"/>');
		
		$("#consulta_modal").empty();	
		
		$("#consulta_modal").append('<table class="consulta"> '+
							'<tr>'+
							'	<td>Fecha:</td>'+
							'	<td><input type="text" id="FechaSalida" value="' + a_fecha + '"></input></td>'+
							'	<td><input type="button" id="btnConsultaSalida" value="Consultar" onclick="consultar_salida();"</input></td>'+
							'</tr>'+
							'</table>'+
							'<br/>'+
							'<br/>'+
							'<div id="TablaSalidaEmbarquesDetalle">'+
							''+
							'</div>'+
							''+
							'<script type="text/javascript">'+
							'	$.datepicker.setDefaults($.datepicker.regional["es"]);'+
							'	$("#FechaSalida").datepicker({ changeMonth: true, changeYear: true, showOn: "button", buttonImage: "/calendar.gif", buttonImageOnly: true});'+
							'	document.getElementById("FechaSalida").focus();'+
							''+
							'	var pUrlConsultaDestino = "/embarques/salidas_por_destino?fecha=" + document.getElementById("FechaSalida").value + "&destino='+ a_destino.toString() + '&tipo='+ a_tipo + "&id=" + a_id +'"; ' +                  
							'	console.log("UrlDestino:" + pUrlConsultaDestino);'+
							'	$("#TablaSalidaEmbarquesDetalle").load(pUrlConsultaDestino);'+
	                        ''+
							'	function consultar_salida(){'+
							'		pUrlConsultaDestino = "/embarques/salidas_por_destino?fecha=" + document.getElementById("FechaSalida").value + "&destino='+ a_destino.toString() + '&tipo=' + a_tipo + "&id=" + a_id +'"; ' +                  
							'		console.log("UrlDestino:" + pUrlConsultaDestino);'+
							'		$("#TablaSalidaEmbarquesDetalle").load(pUrlConsultaDestino);'+
							'	}'+
							'</script>');
							
							
		$(function () {
            $("#dialog:ui-dialog").dialog("destroy");
            $("#consulta_modal").dialog({
                height: 500,
                width: 800,
                modal: true,
            });
        });
	}
	
	this.quitarMateriaPrima = function(a_id, a_producto, a_tipo){
	
		$(document.body).remove("#consulta_modal");
		$(document.body).append('<div id="consulta_modal" title="Estado Matería Prima" style="display:none"/>');
		
		$("#consulta_modal").empty();	
		
		$("#consulta_modal").append('<div id="TablaSalidaEmbarquesDetalle">'+
							'</div>'+
							'<script type="text/javascript">'+
							'	var pUrlConsultaDestino = "/embarques/detalle_mat_prima?&tipo='+ a_tipo + "&id=" + a_id + "&producto=" + a_producto + '"; ' +                  
							'	console.log("UrlDestino:" + pUrlConsultaDestino);'+
							'	$("#TablaSalidaEmbarquesDetalle").load(pUrlConsultaDestino);'+
							'</script>');
		$(function () {
            $("#dialog:ui-dialog").dialog("destroy");
            $("#consulta_modal").dialog({
                height: 500,
                width: 800,
                modal: true,
            });
        });
	}
}
