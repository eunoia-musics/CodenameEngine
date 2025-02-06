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

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var versionText:FunkinText;

	var selector:FlxSprite;
	var selectRow:Int = 0;
	var lerpSel:Float = 235;
	var itsTime:Bool = false;

	public var canAccessDebugMenus:Bool = true;

	override function create()
	{
		super.create();

		DiscordUtil.call("onMenuLoaded", ["Main Menu"]);

		CoolUtil.playMenuSong();

		bg = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBG'));
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuDesat'));
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		for(bg in [bg, magenta]) {
			bg.scrollFactor.set(0, 0);
			bg.scale.set(1.15, 1.15);
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = true;
		}

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

		selector = new FlxSprite(20,235).loadAnimatedGraphic(Paths.image('menus/selector'));
		add(selector);
		selector.scrollFactor.set(0, 0);
		selector.scale.set(1, 1);
		selector.updateHitbox();
		selector.antialiasing = true;
	}

	var selectedSomethin:Bool = false;
	var forceCenterX:Bool = true;

	override function update(elapsed:Float)
	{

		switch (selectRow) {

			case 0: selector.y = 235;
			case 1: selector.y = 335;
			case 2: selector.y = 435;
			case 3: selector.y = 535;

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

		if (Options.flashingMenu) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

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
				case 'credits': FlxG.switchState(new CreditsMain());
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
