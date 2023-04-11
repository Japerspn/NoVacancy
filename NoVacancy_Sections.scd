~letterAFunc = {
	"***Letter A***".postln;
	{~currentLetter.string_("A")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[0], \loop, 0]);
	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0, \outBus, ~wetBus], ~sources);
	});
};
//~letterAFunc.value

~letterBFunc = {
	"***Letter B***".postln;
	{~currentLetter.string_("B")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[1], \loop, 0]);
	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0.2, \outBus, ~wetBus], ~sources);
	});
};

(
~grains = Array(10);
~trig = 0;
~recTask = Task({
	while({~trig != 3}, {
		"Task has begun".postln;
		~trig.postln;
		5.wait;
		"recording".postln;
		~trig.postln;
		~record = Synth(\record, [\bufnum, ~buffers[~trig]]);
		~recordingText.visible_(true);
		10.wait;
		"recording stopped".postln;
		~recordingText.visible_(false);
		~trig.postln;
		5.wait;
		Synth(\Grain, [\grBuf, ~buffers[~trig], \grHz, 7, \amp, 0.5, \grLen, 0.4, \type, 0, \playrate, -0.3, \outBus, ~wetBus], ~sources);
		"grainy playback begins".postln;
		~trig.postln;
		2.wait;
		~trig = ~trig + 1;
		~trig.postln;
})});
);

~letterCFunc = {
	"***Letter C***".postln;
	{~currentLetter.string_("C")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[2], \loop, 0]);
	~trig = 0;
	~recTask.play(AppClock);

};
/*

~trig = 0; ~recTask.play(AppClock);
~trig = 0; ~recTask.play;

~recTask.isPlaying
~trig
~recTask.reset;
~trig = 3;
~stopTask.play
~recTask.stop;~recTask.reset;
*/