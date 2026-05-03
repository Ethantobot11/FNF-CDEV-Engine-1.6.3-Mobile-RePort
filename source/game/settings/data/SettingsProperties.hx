package game.settings.data;

import openfl.system.System;
import openfl.utils.Assets;
import meta.substates.RatingPosition;
import meta.states.TitleState;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxG;

class SettingsType
{
	public static var BOOL:Int = 0; // ENTER
	public static var INT:Int = 1; // LEFT RIGHT
	public static var FLOAT:Int = 2; // LEFT RIGHT
	public static var FUNCTION:Int = 3; // ENTER
	public static var MIXED:Int = 4; // SELF DEFINED
}

// Modable settings wip
class SettingsProperties
{
	public static var currentClass:SettingsSubState = null;
	public static var CURRENT_SETTINGS:Array<SettingsCategory> = [];
	public static var holdTime:Float = 0;
	public static var holdStep:Float = 0;
	public static var ON_PAUSE:Bool = false;

	#if android
	static var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	static var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	static var customPaths:Array<String> = StorageUtil.getCustomStorageDirectories(false);
	#end

	public static function checkClick():Bool {
		if (FlxG.keys.justPressed.ENTER) return true;
		#if mobile
		if (currentClass != null && Reflect.getProperty(currentClass, "pressedWithMouse") == true) return true;
		#end
		return false;
	}

	public static function checkMobileSwipe(expectedDir:String, checkHold:Bool = false):Bool {
		#if mobile
		if (!checkHold) {
			// For single swipes
			for (swipe in FlxG.swipes) {
				if (currentClass != null) {
					var grpOptions:Dynamic = Reflect.getProperty(currentClass, "grpOptions");
					var curSelected:Dynamic = Reflect.getProperty(currentClass, "curSelected");
					
					if (grpOptions != null && curSelected != null) {
						var text:Dynamic = grpOptions.members[curSelected];
						if (text != null && swipe.startPosition.y >= text.y && swipe.startPosition.y <= text.y + text.height) {
							if (swipe.distance > 30) { 
								var isLeft = (swipe.angle > 135 || swipe.angle < -135);
								var isRight = (swipe.angle > -45 && swipe.angle < 45);
								
								if (expectedDir == "LEFT" && isLeft) return true;
								if (expectedDir == "RIGHT" && isRight) return true;
							}
						}
					}
				}
			}
		} else {
			for (touch in FlxG.touches.list) {
				if (touch.pressed) {
					if (currentClass != null) {
						var grpOptions:Dynamic = Reflect.getProperty(currentClass, "grpOptions");
						var curSelected:Dynamic = Reflect.getProperty(currentClass, "curSelected");
						
						if (grpOptions != null && curSelected != null) {
							var text:Dynamic = grpOptions.members[curSelected];
							if (text != null && touch.justPressedPosition.y >= text.y && touch.justPressedPosition.y <= text.y + text.height) {
								var diffX = touch.x - touch.justPressedPosition.x;
								var diffY = Math.abs(touch.y - touch.justPressedPosition.y);

								if (Math.abs(diffX) > 30 && diffY < Math.abs(diffX)) {
									if (expectedDir == "LEFT" && diffX < -30) return true;
									if (expectedDir == "RIGHT" && diffX > 30) return true;
								}
							}
						}
					}
				}
			}
		}
		#end
		return false;
	}

	public static function getLeftJustPressed():Bool {
		if (FlxG.keys.justPressed.LEFT) return true;
		if (checkMobileSwipe("LEFT", false)) return true;
		return false;
	}

	public static function getRightJustPressed():Bool {
		if (FlxG.keys.justPressed.RIGHT) return true;
		if (checkMobileSwipe("RIGHT", false)) return true;
		return false;
	}

	public static function getLeftPressed():Bool {
		if (FlxG.keys.pressed.LEFT) return true;
		if (checkMobileSwipe("LEFT", true)) return true; // Now supports mobile hold!
		return false;
	}

	public static function getRightPressed():Bool {
		if (FlxG.keys.pressed.RIGHT) return true;
		if (checkMobileSwipe("RIGHT", true)) return true; // Now supports mobile hold!
		return false;
	}

	public static function setCurrentClass(curClass:Dynamic)
	{
		currentClass = cast curClass;
	}

	public static function reset():Void
	{
		currentClass = null;
		CURRENT_SETTINGS = [];
		holdTime = 0;
		holdStep = 0;
	}

	public static function load_default():Void
	{
		#if android
		storageTypes = storageTypes.concat(customPaths); //Get Custom Paths From File
		storageTypes = storageTypes.concat(externalPaths); //Get SD Card Path
		#end

		/* CONTROLS */
		create_category("Controls", [],function()
		{
			//currentClass.openSubState(new keybinds.RebindControls(false));
		});

		/* GAMEPLAY */
		create_category("Gameplay", [
			new BaseSettings("Scroll Direction", ["Up", "Down"], "Set the notes Scroll Direction.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "downscroll", false),
			new BaseSettings("Middlescroll", ["Disabled", "Enabled"], "Whether to position your Note Strums in center of your screen.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "middlescroll", false),
			new BaseSettings("Ghost Tapping", ["Disabled", "Enabled"], "If enabled, you won't get any misses when there's no notes hit.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "ghost"),
			new BaseSettings("Note Hit Timing", ["Hide", "Show"], "Whether to show your note timing in miliseconds.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "showDelay"),
			new BaseSettings("Stacking Rating Sprite", ["Disabled", "Enabled"], "Whether to show or hide the \"Sick!!\" sprite stacking each other.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "multiRateSprite"),
			new BaseSettings("Hit Sound", ["Disabled", "Enabled"], "If enabled, it'll play a clicking sound when you press your note keybinds.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "hitsound"),
			new BaseSettings("Reset Button", ["Disabled", "Enabled"], "If disabled, you won't get instant killed if you press the \"R\" key.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "resetButton"),
			new BaseSettings("Botplay", ["OFF", "ON"], "If enabled, a bot will play the game for you.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "botplay"),
			new BaseSettings("Health Percentage", ["Hide", "Show"], "Whether to show or hide the Health percentage in Score Text.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "healthCounter"),
			new BaseSettings("Note Hit Effect", ["Hide", "Show"], "Whether to show or hide the hit effect when you hit a note.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "noteImpact"),	
			new BaseSettings("Time Bar", ["Hide", "Show"], "If enabled, it will show current playing song time as a bar.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "songtime"),
			new BaseSettings("Flashing Lights", ["Disabled", "Enabled"], "Enable / Disable Flashing Lights.\n(Disable this if you're sensitive to flashing lights!)", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "flashing"),	
			new BaseSettings("Camera Beat Zoom", ["OFF", "ON"], "If enabled, the camera will zoom on every 4th beat.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "camZoom"),
			new BaseSettings("Camera Movement", ["OFF", "ON"], "If disabled, the camera won't move based on the current character sing animation", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "camMovement"),
			new BaseSettings("Note Offset", ["", ""], "If you think that your audio was late / early, try to change this setting!", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick())
				{
					FlxG.switchState(new meta.states.OffsetTest());
				}

				var lJust = getLeftJustPressed();
				var rJust = getRightJustPressed();
				var lPress = getLeftPressed();
				var rPress = getRightPressed();

				var daValueToAdd:Int = (rJust || rPress) ? 1 : -1;
				if (lPress || rPress)
					holdTime += elapsed;
				else
					holdTime = 0;
	
				if (lJust || rJust || (holdTime <= 0 && (lPress || rPress)))
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
				if (holdTime > 0.5 || lJust || rJust)
				{
					CDevConfig.setData("offset", CDevConfig.getData("offset")+daValueToAdd);
	
					if (CDevConfig.getData("offset") <= -90000) 
						CDevConfig.setData("offset",-90000);

					if (CDevConfig.getData("offset") > 90000) 
						CDevConfig.setData("offset",90000);
				}
				bs.value_name[0] = CDevConfig.getData("offset") + "ms";
			}, function(){}, "", false),
			new BaseSettings("Detailed Score Text", ["OFF", "ON"], "If enabled, the game will show your misses and accuracy in the score text.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "fullinfo")
		], null);

		create_category("Graphics", [
			new BaseSettings("Shaders", ["Disabled", "Enabled"], "Whether to enable / disable shaders in the engine.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "shaders", false),
			new BaseSettings("FPS Cap", ["", ""], "Choose how many frames per second that this game should run at.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				var lJust = getLeftJustPressed();
				var rJust = getRightJustPressed();
				var lPress = getLeftPressed();
				var rPress = getRightPressed();

				var daValueToAdd:Int = (rJust || rPress) ? 1 : -1;
				if (lPress || rPress)
					holdTime += elapsed;
				else
					holdTime = 0;
		
				if (lJust || rJust || (holdTime <= 0 && (lPress || rPress)))
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
				if (holdTime > 0.5 || lJust || rJust)
				{
					CDevConfig.setData("fpscap", CDevConfig.getData("fpscap")+daValueToAdd);
		
					if (CDevConfig.getData("fpscap") <= 50)
						CDevConfig.setData("fpscap", 50);

					if (CDevConfig.getData("fpscap") > 300)
						CDevConfig.setData("fpscap", 300);

					CDevConfig.setFPS(CDevConfig.getData("fpscap"));
				}
				bs.value_name[0] = CDevConfig.getData("fpscap") + " FPS";
			}, function(){}, ""),	
			new BaseSettings("Antialiasing", ["OFF", "ON"], "If disabled, your game will run as smooth but at cost of graphics.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "antialiasing", false),
			new BaseSettings("Auto Pause", ["Disabled", "Enabled"], "If disabled, the game will no longer pauses whenever the game window is unfocused.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick()){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.autoPause = !CDevConfig.saveData.autoPause;
					FlxG.autoPause = CDevConfig.saveData.autoPause;
	
					bs.value_name[0] = (CDevConfig.saveData.autoPause ? "Enabled":"Disabled");
				}
			}, function(){}, ""),
			new BaseSettings("Bitmaps on GPU", ["Disabled", "Enabled"], "Whether to store all bitmaps to your GPU, and not storing bitmaps to your RAM.\n(Warning: This option is still experimental.)", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "gpuBitmap", false),
			new BaseSettings("Clear Game Cache", ["", ""], "Press ENTER to clear memory cache.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				var usedMem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
				if (usedMem > 1024){
					bs.description = "You might need this option.\nPress ENTER to clear memory cache.";
					if (usedMem > 2048){
						bs.description = "You DEFINITELY need this option.\nPress ENTER to clear memory cache.";
					}
				} else{
					bs.description = "Press ENTER to clear memory cache.";
				}
				
				if (checkClick()){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					openfl.utils.Assets.cache.clear();
					Paths.destroyLoadedImages();
				}
			}, function(){}, "", false),
		], null);

		// APPEARANCE //
		create_category("Appearance", [
			new BaseSettings("Engine Watermark", ["Hide", "Show"], "Whether to show CDEV Engine's watermark in the game.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "engineWM"),	
			new BaseSettings("Opponent Notes in Midscroll", ["Hide", "Show"], "If enabled, opponent notes will be slightly visible.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "bgNote"),
			new BaseSettings("Strum Lane", ["Hide", "Show"], "If enabled, your strum notes playfield will have a black background.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "bgLane"),
			#if DISCORD_RPC new BaseSettings("Discord Rich Presence", ["", ""], "If enabled, your current game information will be shared to Discord RPC.\n(Changing this option will restart the game!)", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick()){
					CDevConfig.saveData.discordRpc = !CDevConfig.saveData.discordRpc;
					Main.discordRPC = CDevConfig.saveData.discordRpc;
					CDevConfig.utils.restartGame();
				}
				bs.value_name[0] = (CDevConfig.saveData.discordRpc ? "ON":"OFF");
			}, function(){}, "", false),#end
			new BaseSettings("Hit Effect Style", ["Splash", "Ripple"], "Choose your preferred Hit Effect Style.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "noteRipples", false),
			new BaseSettings("Set Rating Sprite Position", ["Press ENTER",""], "Set your preferred Rating sprite position.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick()){
					currentClass.hideAllOptions();
					var newState:RatingPosition = new RatingPosition(ON_PAUSE);
					currentClass.openSubState(newState);

					if (newState.leftState){
						currentClass.changeSelection();
						newState.leftState = false;
					}
				}
			}, function(){}, ""),
		], null);

		create_category("Misc", [
			new BaseSettings("Resources Info Mode", ["", ""], "Choose your preferred Resources Text Info Mode.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick())
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					var things:Array<String> = ["fps", "fps-mem", "mem", "hide"];
					var curIndex:Int = 0;

					for (i in things){
						if (CDevConfig.saveData.performTxt == i){
							curIndex = things.indexOf(i);
							break;
						}
					}

					curIndex += 1;
					if (curIndex >= things.length)
						curIndex = 0;
					CDevConfig.saveData.performTxt = things[curIndex];
					Main.fpsCounter.visible = (CDevConfig.saveData.performTxt=="hide" ? false : true);
				}

				bs.value_name[0] = CDevConfig.saveData.performTxt;
			}, function(){}, ""),
			new BaseSettings("Game Log Window", ["", ""], "Whether to show / hide TGame Log Window.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick()){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.showTraceLogAt += 1;
					if (CDevConfig.saveData.showTraceLogAt < 0)
						CDevConfig.saveData.showTraceLogAt = 2;
					if (CDevConfig.saveData.showTraceLogAt >= 2)
						CDevConfig.saveData.showTraceLogAt = 0;
				}
				if (CDevConfig.saveData.showTraceLogAt==0)
					bs.value_name[0] = "Hide";
				else if (CDevConfig.saveData.showTraceLogAt==1)
					bs.value_name[0] = "Show";
				else
					bs.value_name[0] = "Undefined";
			}, function(){}, "", false),
			new BaseSettings("Game Log Main Message", ["Hide", "Show"], "Whether to show the tips text in the Game Log Window.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "traceLogMessage", false),	
			new BaseSettings("Check For Updates", ["Disable", "Enabled"], "If enabled, the game will check for updates.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "checkNewVersion", false),
			new BaseSettings("Autosave Chart File", ["", ""], "If enabled, the game will autosave the chart as a file. (Press SHIFT for more options)", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (checkClick()){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.autosaveChart = !CDevConfig.saveData.autosaveChart;
					if (CDevConfig.saveData.autosaveChart){
						bs.description = "If enabled, the game will autosave the chart as a file. (Press SHIFT for more options)";
					} else{
						bs.description = "If enabled, the game will autosave the chart as a file.";
					}
				}
				if (FlxG.keys.justPressed.SHIFT){
					currentClass.openSubState(new game.settings.misc.AutosaveSettings());
				}
				bs.value_name[0] = (CDevConfig.saveData.autosaveChart?"Enabled":"Disabled");
				
			}, function(){},"", false),
		], null);

		create_category("Mobile", [
			#if MOBILE_CONTROLS_ALLOWED
			new BaseSettings("MobilePad Opacity", ["", ""], "Selects the opacity for the mobile buttons (careful not to put it at 0 and lose track of your buttons).",
				SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings) {
				create_number('percent', "mobilePadAlpha", "", 0.1, 0, 1, elapsed, bs);
			}),
			new BaseSettings("Extra Controls", ["", ""], "Allow Extra Controls.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				create_number('int', "mobileExtraKeys", "", 1, 0, 4, elapsed, bs);
			}),
			new BaseSettings("Extra Control Location", ['', ''], "Choose Extra Control Location.",
				SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings) {
					create_string('hitboxLocation', ['Bottom', 'Top', 'Middle'], elapsed, bs);
			}),
			new BaseSettings("Hitbox Design", ['', ''], "Choose how your hitbox should look like.",
				SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings) {
					create_string('hitboxType', ['Gradient', 'No Gradient' , 'No Gradient (Old)'], elapsed, bs);
			}),
			new BaseSettings("Hitbox Hint", ["Disabled", "Enabled"], "Hitbox Hint", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings) {}, "hitboxHint"),
			new BaseSettings("Hitbox Opacity", ["", ""], "Selects the opacity for the hitbox buttons.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				create_number('percent', "hitboxAlpha", " Opacity", 0.1, 0, 1, elapsed, bs);
			}),
			#end
			#if android
			new BaseSettings("Storage Type", ['', ''], "Which folder CDev Engine should use?", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings) {
				create_string('storageType', storageTypes, elapsed, bs);
			}),
			#end
		], null);
	}

	public static function create_string(variable:String, arrayThing:Array<String>, elapsed:Float, bs:BaseSettings) {
		if (getLeftJustPressed() || getRightJustPressed())
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			var things:Array<String> = arrayThing;
			var curIndex:Int = 0;

			for (i in things){
				if (CDevConfig.getData(variable) == i) {
					curIndex = things.indexOf(i);
					break;
				}
			}

			if (getLeftJustPressed()) {
				curIndex -= 1;
				if (curIndex < 0) curIndex = things.length - 1;
			} else {
				curIndex += 1;
				if (curIndex >= things.length) curIndex = 0;
			}
			
			CDevConfig.setData(variable, things[curIndex]);
		}

		bs.value_name[0] = CDevConfig.getData(variable);
	}

	public static function create_number(type:String = "int", variable:String, postfix:String, changeValue:Dynamic, minNum:Dynamic, maxNum:Dynamic, elapsed:Float, bs:BaseSettings) {
        var lJust = getLeftJustPressed();
        var rJust = getRightJustPressed();
        var lPress = getLeftPressed();
        var rPress = getRightPressed();

        var daValueToAdd:Dynamic = (rJust || rPress) ? changeValue : (lJust || lPress) ? -changeValue : 0;

        var shouldChange:Bool = false;

        if (lJust || rJust) {
            shouldChange = true;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if (lPress || rPress) {
            holdTime += elapsed;

            if (holdTime > 0.5) {
                holdStep += elapsed;

                if (holdStep >= 0.05) { 
                    shouldChange = true;
                    holdStep = 0;
                }
            }
        } else {
            holdTime = 0;
            holdStep = 0;
        }
        
        if (shouldChange)
        {
            CDevConfig.setData(variable, CDevConfig.getData(variable) + daValueToAdd);
        
            if (CDevConfig.getData(variable) <= minNum)
                CDevConfig.setData(variable, minNum);

            if (CDevConfig.getData(variable) >= maxNum)
                CDevConfig.setData(variable, maxNum);
        }

        if (type.toUpperCase() == 'PERCENT')
            bs.value_name[0] = Math.round(CDevConfig.getData(variable) * 100) + "%" + postfix;
        else
            bs.value_name[0] = CDevConfig.getData(variable) + postfix;
    }

	public static function create_category(name:String, child:Array<BaseSettings>, ?onPress:Dynamic):Void
	{
		for (cat in CURRENT_SETTINGS)
		{
			if (cat.name == name)
			{
				trace("Settings category \"" + name + "\" already exists.");
				return;
			}
		}
		CURRENT_SETTINGS.push(new SettingsCategory(name, child, onPress));
	}

	public static function add_setting(catName:String, setName:String, setType:Int):Void
	{
		// Case-sensitive
		for (cat in CURRENT_SETTINGS)
		{
			if (cat.name == catName)
			{
				//var newSet:BaseSettings = new BaseSettings(setName, setType);
				//cat.settings.push(newSet);
				return;
			}
		}

		trace("Can't find settings category \"" + catName + "\".");
	}
}

class SettingsCategory
{
	public var settings:Array<BaseSettings> = [];
	public var name:String = "";
	public var onPress:Dynamic = null;

	public function new(name:String, sets:Array<BaseSettings>, ?onPress:Dynamic=null)
	{
		this.name = name;
		this.settings = sets;
		this.onPress = onPress;
	}
}

class BaseSettings
{
	public var name:String = "New Setting";
	public var value_name:Array<String> = ["Disabled", "Enabled"]; // false, true values.
	public var description:String = "No description was set.";
	public var type:Int = -1;
	public var savedata_field:String = "";

	public var selectedSetting:Bool = false;
	public var pausable:Bool = false;
	public var onUpdate:(Float, BaseSettings)->Void;
	public var updateDisplay:Void->Void;

	public function new(n:String, v:Array<String>, d:String, t:Int, oc:(Float, BaseSettings)->Void, ?ud:Void->Void = null, ?sdf:String="", ?canPause:Bool=true)
	{
		if (ud == null)
			ud = function(){};

		name = n;
		value_name = v;
		description = d;
		type = t;
		savedata_field = sdf;

		pausable = canPause;

		onUpdate = oc;
		updateDisplay = ud;
	}

	public function onUpdateHit(updateElapsed){
		onUpdate(updateElapsed,this);
	}

	public function updateThisDisplay(){
		updateDisplay();
	}
}
