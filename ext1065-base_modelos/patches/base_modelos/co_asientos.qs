
/** @class_declaration modelos */
/////////////////////////////////////////////////////////////////
//// MODELOS FISCALES ///////////////////////////////////////////
class modelos extends oficial {
    function modelos( context ) { oficial ( context ); }
	function init() {
		return this.ctx.modelos_init();
	}
	function habilitarPestanaModelos() {
		return this.ctx.modelos_habilitarPestanaModelos();
	}
}
//// MODELOS FISCALES ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition modelos */
/////////////////////////////////////////////////////////////////
//// MODELOS FISCALES ///////////////////////////////////////////
function modelos_init()
{
	this.iface.__init();
	this.iface.habilitarPestanaModelos();
}

function modelos_habilitarPestanaModelos()
{
	this.child("tbwAsiento").setTabEnabled("modelos", false);
}
//// MODELOS FISCALES ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////
