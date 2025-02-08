package funkin.menus;

import haxe.Json;
import funkin.backend.FunkinText;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import lime.app.Application;

class OpeningJingleState extends MusicBeatState
{
	var shortLogo:FlxSprite;
	var openSnd:FlxSound;

	override function create()
	{
		shortLogo = new FlxSprite(0).loadAnimatedGraphic(Paths.image('menus/opening'));
		add(shortLogo);
		shortLogo.alpha = 1;
		shortLogo.scale.set(1.25, 1.25);
		shortLogo.screenCenter();
		openSnd = FlxG.sound.load("assets/sounds/menu/open.ogg");
		openSnd.play();
		
	}

	override function update(elapsed:Float)
	{
		if (shortLogo.alpha <= 1)
		{
			shortLogo.alpha -= 0.0025;
		}
		if (shortLogo.alpha <= 0)
		{
			FlxG.switchState(new MainMenuState());
		}
	}
}