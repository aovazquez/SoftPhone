import com.adobe.freeswitchInit.FreeSwitchInit;
import com.adobe.model.HovaModel;

import flash.events.KeyboardEvent;

import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public var sessionid:String 	= "";
public var uuidIncoming:String  = "";
private var libFreesWitch:FreeSwitchInit;

/** INICIALIZACIÓN DE LA LIBRERIA PARA 
 * LA CONEXIÓN CON FREESWITCH,
 * URL DEL SERVIDOR FREESWITCH 
 * Y EVENTOS DEL TECLADO
 * */

protected function configFileService_resultHandler(event:ResultEvent):void
{
	var xmlResult:XML = new XML(event.result);
	HovaModel.getInstance().serverPhone_url = xmlResult.urls.serverPhone_url;
}

protected function configFileService_faultHandler(event:FaultEvent):void
{
	trace( "Fault: " + event );
}

public function presetup():void 
{
	configFileService.send();
}


/** PASE DE LA INSTANCIA DE LA LIBRERIA AL SOFTPHONE
 * */
private function init():void 
{
	this.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
	libFreesWitch = new FreeSwitchInit();
	libFreesWitch.presetup();
	softPhone.libFreeSwitch = libFreesWitch;
	libFreesWitch.init();
}

/** 
 * METODO EJECUTADO DESDE LA LIBRERIA, 
 * EN RESPUESTA SI ES CORRCTO EL USUARIO Y CONTRASEÑA
 * */
public function onLogin( session:String, ext:String = "" ):void
{
	if( session != "")
	{
		sessionid 						= session;
		softPhone.vwsPhone.selectedIndex = 1;
		softPhone.ext					= ext;
	}
	else
		Alert.show("Usuario ó Contraseña incorrecta", "Alerta" );
}

/** 
 * METODO EJECUTADO DESDE LA LIBRERIA, 
 * SI ESTA ENTRANDO UNA LLAMADA
 * */
public function onIncomingCall( callingUser:String ):void
{
	softPhone.txtRegister.text 			= callingUser;
	softPhone.txtStatus.text 			= "Llamada entrante";
	softPhone.changeButtonsCall();
	softPhone.uuidIncoming				= uuidIncoming;
}

/** 
 * METODO EJECUTADO DESDE LA LIBRERIA, 
 * CUANDO SE FINALIZA LA LLAMADA
 * */
public function onHangUp():void
{
	softPhone.onHangUp();
}

/** 
 * METODO EJECUTADO DESDE LA LIBRERIA, 
 * CUANDO ESTA EN LLAMANDO
 * */
public function onActive():void
{
	softPhone.onActiveCall();
}

private function keyHandler(event:KeyboardEvent):void 
{
	if( softPhone.vwsPhone.selectedIndex == 0 )
		return
	switch(event.charCode) {
		case 48:
			softPhone.addChr("0");
			softPhone.dtmfZero.play();
			break;
		case 49:
			softPhone.addChr("1");
			softPhone.dtmfOne.play();
			break;
		case 50:
			softPhone.addChr("2");
			softPhone.dtmfTwo.play();
			break;
		case 51:
			softPhone.addChr("3");
			softPhone.dtmfThree.play();
			break;
		case 52:
			softPhone.addChr("4");
			softPhone.dtmfFour.play();
			break;
		case 53:
			softPhone.addChr("5");
			softPhone.dtmfFive.play();
			break;
		case 54:
			softPhone.addChr("6");
			softPhone.dtmfSix.play();
			break;
		case 55:
			softPhone.addChr("7");
			softPhone.dtmfSeven.play();
			break;
		case 56:
			softPhone.addChr("8");
			softPhone.dtmfEight.play();
			break;
		case 57:
			softPhone.addChr("9");
			softPhone.dtmfNine.play();
			break;
		case 8:
			softPhone.removeChr();
			break;
		case 127:
			
			break;
		case 35:
			softPhone.addChr("#");
			softPhone.dtmfHashEffect.play();
			break;
		case 42:
			softPhone.addChr("*");
			softPhone.dtmfStarEffect.play();
			break;
		default:
	}
}