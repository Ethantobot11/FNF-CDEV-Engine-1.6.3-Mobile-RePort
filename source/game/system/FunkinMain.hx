package game.system;

//import game.system.util.FunkinInit;
import game.cdev.log.GameLog;

import haxe.io.Path;
#if CRASH_HANDLER
import sys.FileSystem;
import sys.io.File;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import openfl.events.UncaughtErrorEvent;
import sys.io.Process;
#end
import game.cdev.engineutils.CDevFPSMem;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
#if DISCORD_RPC
import game.cdev.engineutils.Discord.DiscordClient;
#end
import lime.app.Application;

using StringTools;

class FunkinMain extends Sprite
{
	/** CDEV Engine's Default Game Resolution, it's the best to keep the values the same as the one inside the `Project.xml`. 
	 *	(If you want to change the window size, go to `Project.xml` and edit the window properties there.) 
	 */
    static var DEFAULT_DIMENSION = {
        width: 1280,
        height: 720
    };

    var game = {
		gameWidth: DEFAULT_DIMENSION.width,
		gameHeight: DEFAULT_DIMENSION.height,
		initialState: meta.states.InitState,
        zoom: 1.0,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

	public static var fpsCounter:CDevFPSMem;
	public static var cdevLogs:GameLog;
	public static var instance:FunkinMain = null;

	public static var discordRPC:Bool = false;

	var playState:Bool = false;

	public static function initArgs() { //test
		var args:Array<String> = Sys.args();
		
		#if ios
		FlxG.stage.window.alert("test -1", 'ArkoseLabs wasnt her!e');
		#end
		
		if (args.contains("-testmode")){
			trace("test mode triggered");
		}
	}

	public static function main():Void
	{
		trace(FlxG.stage.application.window.width+"x"+FlxG.stage.application.window.height);
		initArgs();
		#if ios
		FlxG.stage.window.alert("test 1", 'InitArgs Worked :D!');
		#end
		Lib.current.addChild(new FunkinMain());
	}

	public function new()
	{
		super();
		instance = this;

		#if mobile
		#if android
		StorageUtil.initExternalStorageDirectory();
		StorageUtil.requestPermissions();
		StorageUtil.copySpesificFileFromAssets('mobile/storageModes.txt', StorageUtil.getCustomStoragePath());
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		CrashHandler.init();

		#if ios
		FlxG.stage.window.alert("test 1", 'Ok this s hit worked!');
		#end

		#if hxvlc
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);

		#if ios
		FlxG.stage.window.alert("test 2", 'Notice!');
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		#if ios
		FlxG.stage.window.alert("test 3", 'Even better isnt  it .!');
		#end

		setupGame();
	}

	private function setupGame():Void
	{
		#if ios
		FlxG.stage.window.alert("test 4", 'Notice!');
		#end

		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.gameWidth = Math.ceil(stageWidth / game.zoom);
			game.gameHeight = Math.ceil(stageHeight / game.zoom);
		}
		#else
		if (game.zoom == -1.0)
			game.zoom = 1.0;
		#end

		#if ios
		FlxG.stage.window.alert("test 5", 'Notice!');
		#end

		#if desktop
		Application.current.onExit.add(function(exitCode)
		{
			CDevConfig.onExitFunction();
			#if DISCORD_RPC DiscordClient.shutdown(); #end
			CDevConfig.storeSaveData();
		});
		#end

		//FunkinInit.start();

		trace("before funkingame");
		addChild(new FunkinGame(Std.int(game.gameWidth), Std.int(game.gameHeight), #if mobile (mobile.CopyState.checkExistingFiles() ? game.initialState : mobile.CopyState) #else game.initialState #end, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
		#if ios
		FlxG.stage.window.alert("test 6", 'Notice!');
		#end
		
		#if !mobile
		cdevLogs = new GameLog();
		GameLog.startInit();
		addChild(cdevLogs);
		#end

		fpsCounter = new CDevFPSMem(10, 10, 0xffffff, true);
		addChild(fpsCounter);

		FlxG.fixedTimestep = false;

		#if android 
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		trace("it runs");
	}

	public function setFpsVisibility(fpsEnabled:Bool):Void { fpsCounter.visible = fpsEnabled; }

	// i just looked into this file again and what the hell is this
	public function isPlayState():Bool { return playState; }

	public function setFPSCap(value:Float) { openfl.Lib.current.stage.frameRate = value; }

	public function getFPS():Float { return fpsCounter.times.length; }
}
