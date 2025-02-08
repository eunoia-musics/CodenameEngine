package funkin.menus;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import funkin.backend.FunkinText;

class BetaWarningState extends MusicBeatState {
	var titleAlphabet:Alphabet;
	var disclaimer:FunkinText;

	var transitioning:Bool = false;

	public override function create() {
		super.create();

		titleAlphabet = new Alphabet(0, 0, "ITS A CLOWN ATTACK BITCH", true);
		titleAlphabet.screenCenter(X);
		add(titleAlphabet);

		disclaimer = new FunkinText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, "", 32);
		disclaimer.alignment = CENTER;
		disclaimer.applyMarkup('This is a *DEV BUILD* for KirBF & Friends\nIt is very unfinished and does not include content\nfor many of the future episodes.\n\nPlease be aware that crashes are very possible.\n*DO NOT SHARE*',
			[
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF4444), "*")
			]
		);
		add(disclaimer);

		var off = Std.int((FlxG.height - (disclaimer.y + disclaimer.height)) / 2);
		disclaimer.y += off;
		titleAlphabet.y += off;

		DiscordUtil.call("onMenuLoaded", ["Beta Warning"]);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.ACCEPT && transitioning) {
			FlxG.camera.stopFX(); FlxG.camera.visible = false;
			goToOpening();
		}

		if (controls.ACCEPT && !transitioning) {
			transitioning = true;
			goToOpening();
		}
	}

	private function goToOpening() {
		MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
		FlxG.switchState(new OpeningJingleState());
	}
}