package com.view
{
	import com.adobe.freeswitchInit.FreeSwitchInit;
	
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Timer;
	
	import mx.containers.ViewStack;
	import mx.core.FlexGlobals;
	import mx.utils.StringUtil;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.TextInput;

	public class SoftPhone extends NavigatorContent
	{
		[Embed(source="assets/images/gray.png")]
		public const gray:Class;
		
		[Embed(source="assets/images/green.png")]
		public const green:Class;
		
		[Embed(source="assets/images/red.png")]
		public const red:Class;
		
		[Embed(source="assets/images/mail_16x16.png")]
		public const mail:Class;
		
		/**variables de los sonidos por cada tecla **/
		[Embed(source="assets/dtmf/0.mp3")]
		public const dtmf0:Class;
		
		[Embed(source="assets/dtmf/1.mp3")]
		public const dtmf1:Class;
		
		[Embed(source="assets/dtmf/2.mp3")]
		public const dtmf2:Class;
		
		[Embed(source="assets/dtmf/3.mp3")]
		public const dtmf3:Class;
		
		[Embed(source="assets/dtmf/4.mp3")]
		public const dtmf4:Class;
		
		[Embed(source="assets/dtmf/5.mp3")]
		public const dtmf5:Class;
		
		[Embed(source="assets/dtmf/6.mp3")]
		public const dtmf6:Class;
		
		[Embed(source="assets/dtmf/7.mp3")]
		public const dtmf7:Class;
		
		[Embed(source="assets/dtmf/8.mp3")]
		public const dtmf8:Class;
		
		[Embed(source="assets/dtmf/9.mp3")]
		public const dtmf9:Class;
		
		/**Tonos de marcación y de llamada entrante **/
		[Embed(source="assets/dtmf/hash.mp3")]
		public const dtmfHash:Class;
		
		[Embed(source="assets/dtmf/star.mp3")]
		public const dtmfStar:Class;
		
		[Bindable]public var inCall:Boolean = false;
		
		private var _txtRegister:Label;
		private var _txtStatus:Label;
		private var _dialnumTxt:Label;
		private var _txtTime:Label;
		
		private var _txtUser:TextInput;
		private var _txtPass:TextInput;
		private var _btnAnswer:Button;
		private var _btnCancel:Button;
		private var _volumeLevel:HSlider;
		
		private var _sliderVolume:HGroup;
		private var _vwsPhone:ViewStack;
		
		private var _volumeIcon:Image;
		private var _indicatorIcon:Image;
		
		
		public var libFreeSwitch:FreeSwitchInit;
		
		private var timer:Timer;
		private var elapsed:uint;
		private var lastTime:uint;
		private var ringSound:Sound 			= null;
		private var dialSound:Sound 			= null;

		public var uuidIncoming:String			= "";
		public var account:String				= "";
		[Bindable]public var ext:String			= "";

		public function init():void
		{
			timer =  new Timer(1000, 0);
			timer.addEventListener(TimerEvent.TIMER , timerHandler);
		}
		
		/**
		 *  METODO PARA HACER LA LLAMADA O CONTESTAR UNA ENTRANTE
		 * */
		public function doCall():void
		{
			if( inCall )
				libFreeSwitch.answer( uuidIncoming );
			else if( dialnumTxt.text != "" )
			{
				showButtons( true );
				libFreeSwitch.makeCall( dialnumTxt.text, FlexGlobals.topLevelApplication.sessionid, "" );
			}
		}
		
		/**
		 *  METODO PARA AUTENTIFICARSE A FREESWITCH
		 * */
		public function logIn():void
		{
			libFreeSwitch.clickLogin( StringUtil.trim( txtUser.text ),StringUtil.trim( txtPass.text ) );
		}
		
		/**
		 *  METODO MOSTRAR EL SLIDER DEL VOLUMEN
		 * */
		public function showVolumen():void
		{
			if( sliderVolume.visible )
				sliderVolume.visible = false;
			else
				sliderVolume.visible = true;
		}
		
		/** CAMPO DEL NUMERO A MARCAR MEDIANTE EL MOUSE*/
		public function doCallChar(chr:String):void 
		{
			dialnumTxt.text += chr;
			txtStatus.text	= "";
		}
		
		/** CAMPO DEL NUMERO A MARCAR MEDIANTE EL TECLADO*/
		public function addChr(chr:String):void 
		{
			dialnumTxt.text += chr;
		}
		
		/**ELIMINA DIGITO POR DIGITO MEDIANTE EL TECLADO*/
		public function removeChr():void {
			var i:int = dialnumTxt.text.length;
			if(i > 0) {
				dialnumTxt.text = dialnumTxt.text.substr(0, (i-1));
			}			
		}
		
		/** CAMBIO DE TECLAS PARA CONTESTAR Y COLGAR ALGUNA LLAMADA */
		public function changeButtonsCall():void
		{
			btnAnswer.includeInLayout 	= true;
			btnAnswer.visible 			= true;
			btnAnswer.width				= 82;
			btnAnswer.label				= "Contestar";
			
			btnCancel.visible 			= true;
			btnCancel.includeInLayout	= true;
			btnCancel.width				= 82;
			
			inCall 						= true;
		}
		
		/** METODO PARA COLGAR LA LLAMADA */
		public function hangUp():void
		{
			libFreeSwitch.clickhangup();
		}
		
		/** METODO QUE SE EJECUTA AL CAMBIAR EL ESTADO DE LA LLAMADA EN HANGUP */
		public function onHangUp():void
		{
			txtStatus.text 			= "Llamada Finalizada";
			dialnumTxt.text			= "";
			txtRegister.text		= "";
			stopTimer();
			showButtons( false );
			volumeIcon.enabled 		= false;
			indicatorIcon.source 	= gray;
		}
		
		/** HACE EL CAMBIO DE TAMAÑO DE LOS BOTONES DE CONTESTAR Y COLGAR */
		public function showButtons( value:Boolean ):void
		{
			btnAnswer.includeInLayout 	= !value;
			btnAnswer.visible 			= !value;
			btnAnswer.width				= 165
			
			btnCancel.visible			= value;
			btnCancel.includeInLayout	= value;
			btnCancel.width				= 165
			
			if( !value )
			{
				inCall = false;
				btnAnswer.label = "Llamar";
			}
		}
		
		/** METODO QUE SE EJECUTA CUANDO SE ESTABLECE LA LLAMADA  */
		public function onActiveCall():void
		{
			showButtons( true );
			startTimer();
			volumeIcon.enabled = true;
			indicatorIcon.source = green;
		}
		
		/** METODO PARA SUBIR EL VOLUMEN */
		public function setVolume():void
		{
			libFreeSwitch.setVolume( volumeLevel.value );
		}
		
		/** START DEL CRONOMETRO */
		public function startTimer():void 
		{
			lastTime = (new Date()).time;
			timer.start();
			elapsed = 0;
		}
		
		/** STOP Y LIMPIEZA DEL CRONOMETRO  **/
		public function stopTimer():void {
			if( timer.running )
				timer.stop();
			txtTime.text = "";
			dialnumTxt.text = "";
		}
		
		public function timerHandler(event:TimerEvent):void {
			var tmp:uint = lastTime;
			lastTime = (new Date()).time;
			elapsed += lastTime - tmp;
			
			var ms:uint = elapsed;	
			var div:uint = 1000 * 60 * 60;
			var hour:uint = ms / div;
			ms -= hour * div;
			div /= 60;
			var min:uint = ms / div;
			ms -= min * div;
			div /= 60;
			var sec:uint = ms / div;
			ms -= sec * div;
			
			var tx:String = hour.toString() + ":"
			if (min < 10) tx += "0";
			tx += min.toString() + ":";
			if (sec < 10) tx += "0";
			tx += sec.toString() ;
			
			txtTime.text = tx;
		}
		
		/** SALIR DE LA APLICACION Y DARSE DE BAJA DE FREESWITCH **/
		public function logout():void
		{
			libFreeSwitch.logout( FlexGlobals.topLevelApplication.sessionid );
		}
		
		/** LIMPIA EL SOFTPHONE **/
		public function resetPhone():void
		{
			logout();
			stopTimer();
			volumeLevel.value 	= 40;
			dialnumTxt.text 	= "";
			txtRegister.text 	= "";
			txtStatus.text 		= "";
			txtUser.text		= "";
			txtPass.text		= "";
			sliderVolume.visible = false;
			volumeIcon.enabled	= false;
			vwsPhone.selectedIndex	= 0;
			indicatorIcon.source = gray;
		}
		
		/** SETTERS & GETTERS **/
		public function get dialnumTxt():Label{return _dialnumTxt;}
		public function set dialnumTxt(value:Label):void{_dialnumTxt = value;}
		
		public function get txtPass():TextInput{return _txtPass;}
		public function set txtPass(value:TextInput):void{_txtPass = value;}
		
		public function get txtUser():TextInput{return _txtUser;}
		public function set txtUser(value:TextInput):void{_txtUser = value;}
		
		public function get sliderVolume():HGroup{return _sliderVolume;}
		public function set sliderVolume(value:HGroup):void{_sliderVolume = value;}
		
		public function get vwsPhone():ViewStack{return _vwsPhone;}
		public function set vwsPhone(value:ViewStack):void{_vwsPhone = value;}

		public function get txtRegister():Label{return _txtRegister;}
		public function set txtRegister(value:Label):void{_txtRegister = value;}
		
		public function get txtStatus():Label{return _txtStatus;}
		public function set txtStatus(value:Label):void{_txtStatus = value;}
		
		public function get btnCancel():Button{return _btnCancel;}
		public function set btnCancel(value:Button):void{_btnCancel = value;}
		
		public function get btnAnswer():Button{return _btnAnswer;}
		public function set btnAnswer(value:Button):void{_btnAnswer = value;}
		
		public function get txtTime():Label{return _txtTime;}
		public function set txtTime(value:Label):void{_txtTime = value;}
		
		public function get volumeLevel():HSlider{return _volumeLevel;}
		public function set volumeLevel(value:HSlider):void{_volumeLevel = value;}
		
		public function get volumeIcon():Image{return _volumeIcon;}
		public function set volumeIcon(value:Image):void{_volumeIcon = value;}
		
		public function get indicatorIcon():Image{return _indicatorIcon;}
		public function set indicatorIcon(value:Image):void{_indicatorIcon = value;}
		
		public function SoftPhone()
		{
			super();
		}
	}
}