package funkin.menus;

import haxe.Json;
import funkin.backend.FunkinText;
import funkin.menus.credits.CreditsMain;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import funkin.backend.scripting.events.*;

import funkin.options.OptionsMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = CoolUtil.coolTextFile(Paths.txt("config/menuItems"));

	var camFollow:FlxObject;
	var versionText:FunkinText;

	var back:FlxSprite;
	var front:FlxSprite;
	var logo:FlxSprite;
	var selector:FlxSprite = new FlxSprite(30);
	var bush:FlxSprite = new FlxSprite(750, 300);
	var selectRow:Int = 0;
	var lerpSel:Float = 235;
	var itsTime:Bool = false;

	public var canAccessDebugMenus:Bool = true;

	override function create()
	{
		super.create();

		DiscordUtil.call("onMenuLoaded", ["Main Menu"]);

		CoolUtil.playMenuSong();

		back = new FlxSprite(0).loadAnimatedGraphic(Paths.image('menus/mainmenu/the_back'));
		add(back);
		back.scrollFactor.set(0,0);
		back.scale.set(1.15, 1.15);
		back.screenCenter();

		var sea:FlxSprite = new FlxSprite(0,0);
		sea.frames = Paths.getFrames('menus/mainmenu/the_c');
		sea.animation.addByPrefix('idle', "sea", 24);
		sea.animation.play('idle');
		add(sea);
		sea.scrollFactor.set(0,0);
		sea.scale.set(1.15, 1.15);
		sea.screenCenter();
		sea.y -= 50;

		front = new FlxSprite(0,0).loadAnimatedGraphic(Paths.image('menus/mainmenu/the_front'));
		add(front);
		front.scrollFactor.set(0,0);
		front.scale.set(1.15, 1.15);
		front.screenCenter();

		logo = new FlxSprite(180,30).loadAnimatedGraphic(Paths.image('menus/mainmenu/logo'));
		add(logo);
		logo.scrollFactor.set(0,0);
		logo.scale.set(1.15, 1.15);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i=>option in optionShit)
		{
			var menuItem:FlxSprite = new FlxSprite(150, 250 + (i * 100));
			menuItem.frames = Paths.getFrames('menus/mainmenu/${option}');
			menuItem.animation.addByPrefix('idle', option + " basic", 24);
			menuItem.animation.addByPrefix('selected', option + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scale.set(0.75, 0.75);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		changeItem();

		selector.frames = Paths.getFrames('menus/mainmenu/select');
		selector.animation.addByPrefix('idle', "select", 24);
		selector.animation.play('idle');
		add(selector);
		selector.scrollFactor.set(0, 0);
		selector.scale.set(1, 1);
		selector.updateHitbox();
		selector.antialiasing = true;

		bush.frames = Paths.getFrames('menus/mainmenu/the_bush');
		bush.animation.addByPrefix('idle', "idle", 24);
		bush.animation.addByPrefix('blink', "blink", 24);
		bush.animation.addByPrefix('bump', "bump", 24);
		bush.animation.addByPrefix('wave', "wave", 24);
		bush.animation.play('idle');
		add(bush);
		bush.scrollFactor.set(0, 0);
	}

	var selectedSomethin:Bool = false;
	var forceCenterX:Bool = true;

	override function update(elapsed:Float)
	{
		switch (selectRow) {

			case 0: selector.y = 240;
			case 1: selector.y = 340;
			case 2: selector.y = 440;
			case 3: selector.y = 540;

		}
		if (selectRow > 3)
			selectRow = 0;
		if (selectRow < 0)
			selectRow = 3;

		lerpSel = CoolUtil.fpsLerp(lerpSel, selector.y, 0.15);
		selector.y = lerpSel;
		
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!selectedSomethin)
		{
			if (canAccessDebugMenus) {
				if (FlxG.keys.justPressed.SEVEN) {
					persistentUpdate = false;
					persistentDraw = true;
					openSubState(new funkin.editors.EditorPicker());
				}
				/*
				if (FlxG.keys.justPressed.SEVEN)
					FlxG.switchState(new funkin.desktop.DesktopMain());
				if (FlxG.keys.justPressed.EIGHT) {
					CoolUtil.safeSaveFile("chart.json", Json.stringify(funkin.backend.chart.Chart.parse("dadbattle", "hard")));
				}
				*/
			}

			var upP = controls.UP_P;
			var downP = controls.DOWN_P;
			var scroll = FlxG.mouse.wheel;

			if (upP || downP || scroll != 0) {
				changeItem((upP ? -1 : 0) + (downP ? 1 : 0) - scroll);
			}	

			if (upP)
				selectRow -= 1;
			if (downP)
				selectRow += 1;

			if (controls.BACK)
				FlxG.switchState(new BetaWarningState());

			#if MOD_SUPPORT
			if (controls.SWITCHMOD) {
				openSubState(new ModSwitchMenu());
				persistentUpdate = false;
				persistentDraw = true;
			}
			#end

			if (controls.ACCEPT)
				selectItem();
		}

		super.update(elapsed);

		if (forceCenterX)
		menuItems.forEach(function(spr:FlxSprite)
		{

		});
	}

	public override function switchTo(nextState:FlxState):Bool {
		try {
			menuItems.forEach(function(spr:FlxSprite) {
				FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.quintOut});
			});
		}
		return super.switchTo(nextState);
	}

	function selectItem() {
		selectedSomethin = true;
		CoolUtil.playMenuSFX(CONFIRM);

		FlxFlicker.flicker(menuItems.members[curSelected], 1, Options.flashingMenu ? 0.06 : 0.15, false, false, function(flick:FlxFlicker)
		{
			var daChoice:String = optionShit[curSelected];

			var event = event("onSelectItem", EventManager.get(NameEvent).recycle(daChoice));
			if (event.cancelled) return;
			switch (event.name)
			{
				case 'story mode': FlxG.switchState(new StoryMenuState());
				case 'freeplay': FlxG.switchState(new FreeplayState());
				case 'options': FlxG.switchState(new OptionsMenu());
				case 'extras': FlxG.switchState(new CreditsMain());
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		var event = event("onChangeItem", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + huh, 0, menuItems.length-1), huh, huh != 0));
		if (event.cancelled) return;

		curSelected = event.value;

		if (event.playMenuSFX)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		menuItems.forEach(function(spr:FlxSprite)
		{

			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var mid = spr.getGraphicMidpoint();
				camFollow.setPosition(mid.x, mid.y);
				mid.put();
			}

			spr.updateHitbox();
			spr.centerOffsets();
		});
	}
}
