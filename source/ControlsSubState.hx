package;

import flixel.FlxSprite;
import flixel.FlxSubState;

class ControlsSubState extends FlxSubState
{
	public function new()
	{
		super();
		#if TOUCH_CONTROLS
		addMobilePad("FULL", "A_B");
		addMobilePadCamera();
		#end
	}
}
