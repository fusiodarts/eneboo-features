
/** @class_declaration envioMail */
/////////////////////////////////////////////////////////////////
//// ENVIO_MAIL ////////////////////////////////////////////////
class envioMail extends oficial /** %from: oficial */ {
    function envioMail( context ) { oficial ( context ); }
	function init() {
		return this.ctx.envioMail_init();
	}
	function enviarDocumento(codPedido:String, codCliente:String) {
		return this.ctx.envioMail_enviarDocumento(codPedido, codCliente);
	}
	function imprimir(codPedido:String) {
		return this.ctx.envioMail_imprimir(codPedido);
	}
}

//// ENVIO_MAIL ////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration pubEnvioMail */
/////////////////////////////////////////////////////////////////
//// PUB_ENVIO_MAIL /////////////////////////////////////////////
class pubEnvioMail extends ifaceCtx /** %from: ifaceCtx */ {
    function pubEnvioMail( context ) { ifaceCtx( context ); }
	function pub_enviarDocumento(codPedido:String, codCliente:String) {
		return this.enviarDocumento(codPedido, codCliente);
	}
}

//// PUB_ENVIO_MAIL /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition envioMail */
/////////////////////////////////////////////////////////////////
//// ENVIO_MAIL /////////////////////////////////////////////////
function envioMail_init()
{
	this.iface.__init();
	//this.child("tbnEnviarMail").close();
	connect(this.child("tbnEnviarMail"), "clicked()", this, "iface.enviarDocumento()");
}

function envioMail_enviarDocumento(codPedido:String, codCliente:String)
{
	var cursor:FLSqlCursor = this.cursor();
	var util:FLUtil = new FLUtil();

	if (!codPedido) {
		codPedido = cursor.valueBuffer("codigo");
	}

	if (!codCliente) {
		codCliente = cursor.valueBuffer("codcliente");
	}
	var tabla:String = "clientes";
	var emailCliente:String = flfactppal.iface.pub_componerListaDestinatarios(codCliente, tabla);
	if (!emailCliente) {
		return;
	}

	var rutaIntermedia:String = util.readSettingEntry("scripts/flfactinfo/dirCorreo");
	if (!rutaIntermedia.endsWith("/")) {
		rutaIntermedia += "/";
	}

	var cuerpo:String = "";
	var asunto:String = util.translate("scripts", "Pedido %1").arg(codPedido);
	var rutaDocumento:String = rutaIntermedia + "P_" + codPedido + ".pdf";

	var codigo:String;
	if (codPedido) {
		codigo = codPedido;
	} else {
		if (!cursor.isValid()) {
			return;
		}
		codigo = cursor.valueBuffer("codigo");
	}

	var numCopias:Number = util.sqlSelect("pedidoscli p INNER JOIN clientes c ON c.codcliente = p.codcliente", "c.copiasfactura", "p.codigo = '" + codigo + "'", "pedidoscli,clientes");
	if (!numCopias) {
		numCopias = 1;
	}

	var curImprimir:FLSqlCursor = new FLSqlCursor("i_pedidoscli");
	curImprimir.setModeAccess(curImprimir.Insert);
	curImprimir.refreshBuffer();
	curImprimir.setValueBuffer("descripcion", "temp");
	curImprimir.setValueBuffer("d_pedidoscli_codigo", codigo);
	curImprimir.setValueBuffer("h_pedidoscli_codigo", codigo);
	var whereFijo:String = "PARAM_titulo\nPedido\nPARAM_tabla\npedidoscli\nPARAM_subtabla\npedido\nPARAM_orderdef\npedidoscli.codigo\nPARAM_tablareldoc\npresupuestoscli\nPARAM_reldoc\npresupuesto\n";
	flfactinfo.iface.pub_lanzarInforme(curImprimir, "i_pedidoscli", "", "", false, false, whereFijo, "i_pedidoscli", numCopias, rutaDocumento, true);

	var arrayDest:Array = [];
	arrayDest[0] = [];
	arrayDest[0]["tipo"] = "to";
	arrayDest[0]["direccion"] = emailCliente;

	var arrayAttach:Array = [];
	arrayAttach[0] = rutaDocumento;

	flfactppal.iface.pub_enviarCorreo(cuerpo, asunto, arrayDest, arrayAttach);
}

function envioMail_imprimir(codPedido:String)
{
	var util:FLUtil = new FLUtil;

	var datosEMail:Array = [];
	datosEMail["tipoInforme"] = "pedidoscli";
	var codCliente:String;
	if (codPedido && codPedido != "") {
		datosEMail["codDestino"] = util.sqlSelect("pedidoscli", "codcliente", "codigo = '" + codPedido + "'");
		datosEMail["codDocumento"] = codPedido;
	} else {
		var cursor:FLSqlCursor = this.cursor();
		datosEMail["codDestino"] = cursor.valueBuffer("codcliente");
		datosEMail["codDocumento"] = cursor.valueBuffer("codigo");
	}
	flfactinfo.iface.datosEMail = datosEMail;
	this.iface.__imprimir(codPedido);
}

//// ENVIO_MAIL /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

