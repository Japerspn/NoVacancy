~letterAFunc = {
	"***Letter A***".postln;
	{~currentLetter.string_("A")}.defer;

	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0, \outBus, ~wetBus], ~sources);
	});
};
//~letterAFunc.value

~letterBFunc = {
	"***Letter B***".postln;
	{~currentLetter.string_("B")}.defer;

	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0.2, \outBus, ~wetBus], ~sources);
	});
};

(
~grains = Array(10);
~trig = 0;
~recTask = Routine({
	while({~trig != 3}, {
		"Task has begun".postln;
		5.wait;
		"recording".postln;
		~record = Synth(\record, [\bufnum, ~buffers[~trig]]);
		10.wait;
		"recording stopped".postln;
		5.wait;
		Synth(\Grain, [\grBuf, ~buffers[~trig], \grHz, 7, \amp, 0.5, \grLen, 0.4, \type, 0, \playrate, -0.3]);
		"grainy playback begins".postln;

		2.wait;
		~trig = ~trig + 1;
		~trig.postln;
})});
);

~letterCFunc = {
	"***Letter C***".postln;
	{~currentLetter.string_("C")}.defer;
	~recTask.play(AppClock);

};

~letterCFunc.value;


