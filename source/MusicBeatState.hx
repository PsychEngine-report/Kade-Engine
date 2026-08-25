package;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.FlxBasic;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.input.actions.FlxActionInput;
import flixel.FlxSubState;
import flixel.util.FlxDestroyUtil;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var initSave:Bool = false;

	private var assets:Array<FlxBasic> = [];

	override function destroy()
	{
		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		#if TOUCH_CONTROLS
		if (trackedinputsNOTES.length > 0)
			controls.removeVirtualControlsInput(trackedinputsNOTES);

		if (trackedinputsUI.length > 0)
			controls.removeVirtualControlsInput(trackedinputsUI);

		super.destroy();

		if (mobilePad != null)
			mobilePad = FlxDestroyUtil.destroy(mobilePad);

		if (mobilec != null)
			mobilec = FlxDestroyUtil.destroy(mobilec);
		#end
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (FlxG.save.data.optimize)
			assets.push(Object);
		var result = super.add(Object);
		return result;
	}

	public function clean()
	{
		if (FlxG.save.data.optimize)
		{
			for (i in assets)
			{
				remove(i);
			}
		}
	}

	#if TOUCH_CONTROLS
	public static var checkHitbox:Bool = false;

	public var mobilePad:MobilePad;

	public static var mobilec:MobileControls;

	var trackedinputsUI:Array<FlxActionInput> = [];
	var trackedinputsNOTES:Array<FlxActionInput> = [];

	public function addMobilePad(?DPad:String, ?Action:String)
	{
		if (mobilePad != null)
			removeMobilePad();

		mobilePad = new MobilePad(DPad, Action);
		add(mobilePad);

		controls.setMobilePadUI(mobilePad, DPad, Action);
		trackedinputsUI = controls.trackedInputsUI;
		controls.trackedInputsUI = [];
		mobilePad.alpha = KadeEngineData.mobilePadAlpha;
	}

	public function removeMobilePad()
	{
		if (trackedinputsUI.length > 0)
			controls.removeVirtualControlsInput(trackedinputsUI);

		if (mobilePad != null)
			remove(mobilePad);
	}

	/*
		public function addVirtualPad(?DPad:String, ?Action:String)
			return addMobilePad(DPad, Action);

		public function removeVirtualPad()
			return removeMobilePad();
	 */
	public function removeMobileControls()
	{
		if (trackedinputsNOTES.length > 0)
			controls.removeVirtualControlsInput(trackedinputsNOTES);

		if (mobilec != null)
			remove(mobilec);
	}

	public function addMobileControls(?customControllerValue:Int, ?mode:String, ?action:String)
	{
		mobilec = new MobileControls(customControllerValue, mode, action);

		switch (MobileControls.mode)
		{
			case MOBILEPAD_RIGHT | MOBILEPAD_LEFT | MOBILEPAD_CUSTOM:
				controls.setMobilePadNOTES(mobilec.vpad, "FULL", "NONE");
				MusicBeatState.checkHitbox = false;
			case DUO:
				controls.setMobilePadNOTES(mobilec.vpad, "DUO", "NONE");
				MusicBeatState.checkHitbox = false;
			case HITBOX:
				controls.setHitBox(mobilec.newhbox, mobilec.hbox);
				MusicBeatState.checkHitbox = true;
			default:
		}

		trackedinputsNOTES = controls.trackedInputsNOTES.copy();

		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol, false);
		camcontrol.bgColor.alpha = 0;
		mobilec.cameras = [camcontrol];

		add(mobilec);
	}

	public function addMobilePadCamera()
	{
		var camcontrol = new flixel.FlxCamera();
		camcontrol.bgColor.alpha = 0;
		FlxG.cameras.add(camcontrol, false);
		mobilePad.cameras = [camcontrol];
	}

	/*
		public function addVirtualPadCamera()
			return addMobilePadCamera();
	 */
	#end

	override function create()
	{
		if (initSave)
		{
			if (FlxG.save.data.laneTransparency < 0)
				FlxG.save.data.laneTransparency = 0;

			if (FlxG.save.data.laneTransparency > 1)
				FlxG.save.data.laneTransparency = 1;
		}

		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		TimingStruct.clearTimings();

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		/*var nextStep:Int = updateCurStep();

			if (nextStep >= 0)
			{
				if (nextStep > curStep)
				{
					for (i in curStep...nextStep)
					{
						curStep++;
						updateBeat();
						stepHit();
					}
				}
				else if (nextStep < curStep)
				{
					//Song reset?
					curStep = nextStep;
					updateBeat();
					stepHit();
				}
		}*/

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((Conductor.songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition) - startInMS) / step);
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (ste < curStep)
					{
						trace("reset steps for some reason?? at " + Conductor.songPosition);
						// Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
					}
				}
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor((Conductor.songPosition) / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (nextStep < curStep)
					{
						// Song reset?
						trace("(no bpm change) reset steps for some reason?? at " + Conductor.songPosition);
						curStep = nextStep;
						updateBeat();
						stepHit();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	function onWindowFocusOut():Void
	{
		if (PlayState.inDaPlay)
		{
			if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
			{
				Debug.logTrace("Lost Focus");
				PlayState.instance.openSubState(new PauseSubState());
				PlayState.boyfriend.stunned = true;

				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;

				PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
			}
		}
	}

	function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}
