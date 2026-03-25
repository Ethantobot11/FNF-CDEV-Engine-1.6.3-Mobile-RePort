package meta.states;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import game.cdev.CDevMods.ModFile;
import flixel.util.FlxColor;
#if DISCORD_RPC
import game.cdev.engineutils.Discord.DiscordClient;
#end
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData.TransitionTileData;
import flixel.graphics.FlxGraphic;
import game.cdev.engineutils.Highscore;
import game.cdev.engineutils.PlayerSettings;
import game.cdev.log.GameLog;
import flixel.FlxG;
import sys.FileSystem;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;

class InitState extends MusicBeatState {
	public static var status = {
		loadedSaves: false,
		transitionLoaded: false,
		loadedMod: false
	};

	public static var nextState:MusicBeatState = new TitleState();
	public static var modsFolder:String;

	override function create() {
		FlxG.save.bind('cdev_engine', 'EngineData'); //init this thing first
		doInit();

		// when crash handler is missing
		#if desktop
		if (!FileSystem.exists("./cdev-crash_handler.exe"))
			Application.current.window.alert("CDEV Engine Crash Handler is missing, some stuff might break without it.", "Warning");
		#end

		trace('called!');

		#if mobile
		//Copy CDev-mods folder automatically, so you don't need to see annoying CopyState screen when you changed storage type
		var modsPath:String = #if mobile StorageUtil.getExternalStorageDirectory() #else Sys.getCwd() #end;
		if (!StorageUtil.areAssetsCopied("cdev-mods/", modsPath))
			StorageUtil.copyAssetsFromAPK("cdev-mods/", modsPath);
		#end

		modsFolder = #if mobile StorageUtil.getExternalStorageDirectory() + #elseif mobile Sys.getCwd() + #end 'cdev-mods';

		#if mobile 
		if (CopyState.checkExistingFiles())
			FlxG.switchState(new TitleState());
		else
			FlxG.switchState(new CopyState());
		#else
		FlxG.switchState(new TitleState());
		#end
		super.create();
	}

	function doInit(){
		if (!status.loadedSaves)
			CDevConfig.initSaves();

		PlayerSettings.init();
		init_flixel();
		Highscore.load();
		init_transition();
		init_windowTitle();
		#if DISCORD_RPC
		if (!CDevConfig.saveData.discordRpc)
			DiscordClient.shutdown();
		else
			DiscordClient.initialize();
		#end
	}

	function init_flixel() {
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		
		FlxG.fixedTimestep = false;

		if (FlxG.save.data.lastVolume != null){
			FlxG.sound.volume = FlxG.save.data.lastVolume;
			trace("updated default volume: "+FlxG.sound.volume);
		} else{
			FlxG.save.data.lastVolume = FlxG.sound.volume;
			trace("created new save for volume");
		}
	}

	function init_transition(){
		if (!status.transitionLoaded)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			var transData:TransitionTileData = {
				asset: diamond,
				width: 32,
				height: 32
			}

			var newTD:TransitionData = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), transData,
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			newTD.cameraMode = TransitionCameraMode.NEW;
			FlxTransitionableState.defaultTransIn = newTD;

			newTD.direction = new FlxPoint(0, 1);
			FlxTransitionableState.defaultTransOut = newTD;

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}
	}

	function init_windowTitle(){
		#if desktop
		if (Paths.curModDir.length == 1)
		{
			if (!status.loadedMod)
			{
				Paths.currentMod = Paths.curModDir[0];
				status.loadedMod = true;
			} else{
				CDevConfig.setWindowProperty(true, "", "");
			}
		}
		else
		{
			CDevConfig.setWindowProperty(true, "", "");
		}

		if (status.loadedMod)
		{
			var d:ModFile = Paths.modData();
			CDevConfig.setWindowProperty(false, Reflect.getProperty(d, "window_title"), Paths.modFolders("winicon.png"));
		}
		#end
	}
}