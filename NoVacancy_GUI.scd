(
~redGray = Color.fromHexString("#332E2F");
~red = Color.fromHexString("#A8291E");
~black = Color.fromHexString("#000000");
~blue = Color.fromHexString("#1C5266");

Window.closeAll;
w = Window("No Vacancy", Rect(
	left: Window.screenBounds.width/2-(640/2),
	top: Window.screenBounds.height/2-(400/2),
	width: 640,
	height: 500))
.front
.alwaysOnTop_(true)
.background_(~redGray)
.onClose_({
	s.freeAll;
});

///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS
///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS
///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS///START BUTTONS

~startButtonA = Button(w, Rect(10, 310, 80, 80))//Letter A
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
		~letterAFunc.value;
		~practiceText.visible_("true");
		"practice mode is checked".postln;
	},{
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
		~letterAFunc.value;
		"practice mode is NOT checked".postln;
	});

	if(~leadInCheckBox.value, {
		t = Task({
			~outSynthSetup.value;
			~startButtonGuiFunc.value;
			10.wait;
			~letterAFunc.value;
			"The piece is starting".postln;
		}).play;
	}, {
		"The piece is starting".postln;
	});
});

~startButtonB = Button(w, Rect(100, 310, 80, 80))//Letter B
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~letterBFunc.value;
		~startButtonGuiFunc.value;

	},{
		~outSynthSetup.value;
		~letterBFunc.value;
		~startButtonGuiFunc.value;
	});

});

~startButtonC = Button(w, Rect(190, 310, 80, 80))//Letter C
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~letterCFunc.value;
		~startButtonGuiFunc.value;
	},{
		~outSynthSetup.value;
		~letterCFunc.value;
		~startButtonGuiFunc.value;
	});
});

~startButtonD = Button(w, Rect(280, 310, 80, 80))//Letter D
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
	},{
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
	});
});

~startButtonE = Button(w, Rect(370, 310, 80, 80))//Letter E
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~startButtonGuiFunc.value;

	},{
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
	});
});

~startButtonF = Button(w, Rect(460, 310, 80, 80))//Letter A
.action_({
	if(~practiceModeCheckBox.value, {
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
	}, {
		~outSynthSetup.value;
		~startButtonGuiFunc.value;
	});
});

~startButtonG = Button(w, Rect(550, 310, 80, 80))//Letter G
.action_({
	~outSynthSetup.value;
	~startButtonGuiFunc.value;
});

///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///
///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///
///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///OTHER BUTTONS///

~practiceModeCheckBox = CheckBox.new(w, Rect(10, 400, 120, 20), "Practice Mode");

~leadInCheckBox = CheckBox.new(w, Rect(150, 400, 130, 20), "10 second lead in");

~multiRecordCheckBox = CheckBox.new(w, Rect(290, 400, 150, 20), "Multichannel Record?");


~stopButton = Button(w, Rect(210,110,100,100))//Stop Button
.visible_("false")
.action_({
	s.freeAll;
	if(~patternPlayer.isPlaying, {~patternPlayer.stop});
	if(~patternPlayer1.isPlaying, {~patternPlayer1.stop});
	if(~patternPlayer2.isPlaying, {~patternPlayer2.stop});
	if(t.isPlaying, {t.stop});

	~currentLetter.string_("");

	OSCdef(\aToB).disable;
	OSCdef(\bToC).disable;
	OSCdef(\cToD).disable;
	OSCdef(\dToE).disable;
	OSCdef(\eToF).disable;
	OSCdef(\fToG).disable;

	~stopButtonGuiFunc.value;
	~recordButton.value = 0;
	~patternPlayer2.stop;

});

~path = thisProcess.nowExecutingPath.dirname.dirname;

~recordButton = Button(w, Rect(180, 240, 160, 40))
.action_({|view|
	if(view.value == 1,
		{
			if(~multiRecordCheckBox.value, {
				s.record(~path +/+ "/Recordings/NoVacancy_" ++ Date.localtime.stamp ++ ".wav", numChannels: 8);
			}, {
				s.record(~path +/+ "/Recordings/NoVacancy_" ++ Date.localtime.stamp ++ ".wav", numChannels: 2);
			})
		}, {
			s.stopRecording;
		}
)});

~testButton = Button(w, Rect(10, 240, 160, 40))
.action_({|view|
	if(view.value == 1,
		{
			"output Synths are on".postln;
			~outSynthSetup.value;
			~startButtons.do({|button|
				button.visible_("false")
			});
			~staticStartButtons.do({|button|
				button.visible_("false")
			});
		}, {
			"output Synths are off".postln;
			~outSynthSetup.value;
			~startButtons.do({|button|
				button.visible_("true")
			});
			~staticStartButtons.do({|button|
				button.visible_("true")
			});
			~practiceText.visible_("false")
		}
)});
///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT
///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT
///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT///TEXT

10.do({ |index|
	var colors = [0.5, 0.4, 0.3, 0.2, 0.1, 0];
	StaticText(w, Rect(2 + (index), 2 + (index), 400, 40))
	.string_("N O V A C A N C Y")
	.stringColor_(Color.red(0 + (index / 13)))
	.font_(Font("Futura", 34, true));
});
~textColor = Color.white;
~currentLetterText = StaticText(w, Rect(10, 60, 170, 20))
.string_("Current Letter:")
.stringColor_(~textColor)
.font_(Font("Futura", 20, true));

~currentLetter = StaticText(w, Rect(40, 80, 120, 120))
.string_("")
.stringColor_(~textColor)
.font_(Font("Futura", 150, true));

~practiceText = StaticText(w, Rect(40, 440, 345, 40))
.string_("PRACTICE MODE")
.stringColor_(~textColor)
.visible_("false")
.font_(Font("Futura", 40, true));

~dryText = StaticText(w, Rect(353, 30, 40, 20))
.string_("Dry")
.stringColor_(~textColor);

~dryOutSlider = Slider(w, Rect(350, 50, 40, 230))
.value_(0.5)
.action_({
	arg obj;
	if(~dryOut.isRunning, {~dryOut.set(\amp, obj.value * 2)});
});

~wetText = StaticText(w, Rect(412, 30, 40, 20))
.string_("Wet")
.stringColor_(~textColor);

~wetOutSlider = Slider(w, Rect(410, 50, 40, 230))
.value_(0.5)
.action_({
	arg obj;
	if(~wetOut.isRunning, {~wetOut.set(\amp, obj.value * 2)});
});

~bufText = StaticText(w, Rect(469, 30, 60, 20))
.string_("Buffers")
.stringColor_(~textColor);

~bufOutSlider = Slider(w, Rect(470, 50, 40, 230))
.value_(0.5)
.action_({
	arg obj;
	if(~bufOut.isRunning, {~bufOut.set(\amp, obj.value * 2)});
});

~meters = ServerMeterView(s, w, 520@50, 1, 2);

///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS
///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS
///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS///DESIGN ELEMENTS

~sliderLabels = [~wetText, ~dryText, ~bufText];

~sliderLabels.do({|button, index|
	button.font_(Font("Futura", size:20));
});

~testButton.states_([["Test Levels", ~redGray, Color.black],["End Test", ~red, Color.black]])
.font_(Font("Futura", size:20));

~recordButton.states_([["RECORD", ~redGray, Color.black],["Stop Recording", ~red, Color.black]])
.font_(Font("Futura", size:20));


~startButtons = [
	~startButtonA,
	~startButtonB,
	~startButtonC,
	~startButtonD,
	~startButtonE,
	~startButtonF,
	~startButtonG,
];

~checkBoxes = [
	~leadInCheckBox,
	~practiceModeCheckBox,
	~multiRecordCheckBox

];

~strings = ["A", "B", "C", "D", "E", "F", "G"];


~startButtons.do({|button, index|
	button.font_(Font("Futura", size:20));
	button.states_([[~strings[index], ~textColor, Color.black]])
});

~stopButton.states_([["STOP", ~textColor, Color.black]])
.font_(Font("Futura", size:20));

~notStopButtons = ~startButtons ++ [~testButton, ~recordButton] ++ ~checkBoxes;

~startButtonGuiFunc = {
	~notStopButtons.do({|button| button.visible_("false") });
	~stopButton.visible_("true");
};

~stopButtonGuiFunc = {
	~notStopButtons.do({|button| button.visible_("true") });
	~stopButton.visible_("false");
	~practiceText.visible_("false");
};
////////
////////
////////
~outSynthSetup = {
	if(~dryOut.isPlaying.not, {
		~dryOut = Synth(\dryOutSynth, [
			\amp: ~dryOutSlider.value * 2,
			\inbus: 0,
			\otherOut: 2
		], ~outputs).register;
	}, {~dryOut.free});

	if(~wetOut.isPlaying.not, {
		~wetOut = Synth(\outSynth, [
			\amp: ~wetOutSlider.value * 2,
			\inbus: ~wetBus,
			\otherOut: 4
		], ~outputs).register;
	}, {~wetOut.free});

	if(~bufOut.isPlaying.not, {
		~bufOut = Synth(\outSynth, [
			\amp: ~bufOutSlider.value * 2,
			\inbus: ~bufBus,
			\otherOut: 6
		], ~outputs).register;
	}, {~bufOut.free});
}
);
s.plotTree;