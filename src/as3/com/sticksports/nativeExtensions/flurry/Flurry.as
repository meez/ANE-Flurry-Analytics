package com.sticksports.nativeExtensions.flurry
{
	import flash.external.ExtensionContext;
    import flash.system.Capabilities;

	public class Flurry
	{
        // Definitions
        
        /** Gender */
		public static const GENDER_MALE:String="m";
		public static const GENDER_FEMALE:String="f";
		
        // Static vars
        
        /** Extension Context */
		private static var extensionContext:ExtensionContext=null;
        
        /** Session is started */
        private static var _sessionStarted:Boolean;
        
        /** Session continue seconds */
		private static var _sessionContinueSeconds:int=10;
        
        /** Event logging enabled */
		private static var _eventLoggingEnabled:Boolean=true;
        
        // Public static methods
		
		/** Is the extension supported */
		public static function get isSupported():Boolean
		{
			return isAndroid() || isIos();
		}
		
		/** Override the app version. Should be called before start session. */
		public static function setAppVersion(version:String):void
		{
			if(!_sessionStarted)
			{
				initExtension();
				extensionContext.call(NativeMethods.setAppVersion, version);
			}
		}
		
		/** The Flurry Agent version number. Should be called before start session. */
		public static function get flurryAgentVersion():String
		{
			initExtension();
			var version:String=String(extensionContext.call(NativeMethods.getFlurryAgentVersion));
			return version;
		}
		
		/** Get the session continue seconds */
		public static function get sessionContinueSeconds():int
		{
			return _sessionContinueSeconds;
		}
        
        /** Set the session continue seconds. Must be called before starting session. Default is 10 */
		public static function set sessionContinueSeconds(seconds:int ):void
		{
			if( !_sessionStarted )
			{
				initExtension();
				extensionContext.call( NativeMethods.setSessionContinueSeconds, seconds );
				_sessionContinueSeconds = seconds;
			}
		}
        
        /**Init the Flurry Analytics agent. This should be called before any other methods, including startSession.
         * It is safe to call this multiple time as long as the same id is passed each time.
         * This is Android call only
         * @param id Flurry API Key
         */
        public static function init(id:String):void
        {
            if (!isAndroid())
            {
                trace("[FlurryAnalytics.ane] Ignoring init() call for non-Android device");
                return;
            }
            
            initExtension();           
            extensionContext.call(NativeMethods.init, id);
        }
		
		/** Start session, attempt to send saved sessions to the server. */
		public static function startSession(id:String):void
		{
			initExtension();
			extensionContext.call(NativeMethods.startSession, id);
			_sessionStarted = true;
		}
		
		/** End session */
		public static function endSession():void
		{
			initExtension();
			extensionContext.call(NativeMethods.endSession);
			_sessionStarted = false;
		}
		
		/** Log events. */
		public static function logEvent(eventName:String, parameters:Object=null):void
		{
            initExtension();
			if(parameters)
			{
				var array:Array = [];
				for(var key:String in parameters )
				{
					array.push(key);
					array.push(String(parameters[key]));
				}
				extensionContext.call(NativeMethods.logEvent, eventName, array);
			}
			else
			{
				extensionContext.call(NativeMethods.logEvent, eventName);
			}
		}
		
		/** Log errors. */
		public static function logError(errorId:String, message:String):void
		{
			initExtension();
			extensionContext.call(NativeMethods.logError, errorId, message);
		}
		
		/** Log timed events. */
		public static function startTimedEvent(eventName:String, parameters:Object=null):void
		{
            initExtension();
			if( parameters )
			{
				var array:Array = [];
				for(var key:String in parameters )
				{
					array.push(key);
					array.push(String(parameters[key]));
				}
				extensionContext.call(NativeMethods.startTimedEvent, eventName, array);
			}
			else
			{
				extensionContext.call(NativeMethods.startTimedEvent, eventName);
			}
		}
		
		/** Log timed events. Non-null parameters will updater the event parameters. */
		public static function endTimedEvent(eventName:String, parameters:Object=null):void
		{
            initExtension();
			if(parameters)
			{
				var array:Array = [];
				for(var key:String in parameters)
				{
					array.push(key);
					array.push(String( parameters[key]));
				}
				extensionContext.call(NativeMethods.endTimedEvent, eventName, array);
			}
			else
			{
				extensionContext.call(NativeMethods.endTimedEvent, eventName);
			}
		}
		
		/** Set user's id in your system. */
		public static function setUserId(id:String):void
		{
			initExtension();
			extensionContext.call(NativeMethods.setUserId, id);
		}
		
		/** Set user's age in years */
		public static function setUserAge(age:int ):void
		{
			initExtension();
			extensionContext.call(NativeMethods.setUserAge, age);
		}
		
		/** Set user's gender ("m" or "f") */
		public static function setUserGender(gender:String):void
		{
            if ([GENDER_FEMALE, GENDER_MALE].indexOf(gender) < 0)
            {
                trace("[FlurryAnalytics.ane] Could not set gender (" + gender + ")");
                return;
            }
                
            initExtension();
            extensionContext.call(NativeMethods.setUserGender, gender);
		}
		
		/** Set location information - iOS only */
		public static function setLocation(latitude:Number, longitude:Number, horizontalAccuracy:Number, verticalAccuracy:Number):void
		{
			initExtension();
			extensionContext.call(NativeMethods.setLocation, latitude, longitude, horizontalAccuracy, verticalAccuracy);
		}
		
		/** Get event logging setting */
		public static function get eventLoggingEnabled():Boolean
		{
			return _eventLoggingEnabled;
		}
        
        /** Set event logging (default is true) */
		public static function set eventLoggingEnabled(value:Boolean ):void
		{
			initExtension();
			extensionContext.call(NativeMethods.setEventLoggingEnabled, value);
			_eventLoggingEnabled = value;
		}
		
		/** Clean up the extension - only if you no longer need it or want to free memory. */
		public static function dispose():void
		{
			if(extensionContext)
			{
				extensionContext.dispose();
				extensionContext = null;
			}
		}
        
        // Implementation
        
        /** Init the extension */
		private static function initExtension():void
		{            
			if (!extensionContext)
			{
                try
                {
				    extensionContext = ExtensionContext.createExtensionContext("com.sticksports.nativeExtensions.Flurry", null);
                }
                catch (e:Error)
                {
                    extensionContext = null;
                    trace("[FlurryAnalytics.ane] Could not create extension (" + e.toString() + ")");
                }
			}
		}
        
        // Helpers
        
        /** Is iOS Device */
        private static function isIos():Boolean
		{
			return Capabilities.manufacturer.indexOf('iOS') > -1;
		}
		
        /** Is Android Device */
		private static function isAndroid():Boolean
		{
			return Capabilities.manufacturer.indexOf('Android') > -1;
		}
	}
}

