~letterAFunc = {//Whisper Delay //NOT THAT COOL
	"***Letter A***".postln;
	{~currentLetter.string_("A")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[0], \loop, 0]);
	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0, \outBus, ~wetBus], ~sources);
	});
};
//~letterAFunc.value

~letterBFunc = {//Whisper Delay with Amplitude Threshhold //LAME
	"***Letter B***".postln;
	{~currentLetter.string_("B")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[1], \loop, 0]);
	~whipserDelays = 10.collect({
		arg i;
		Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0.2, \outBus, ~wetBus], ~sources);
	});
};

(
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

~letterCFunc = {//Buffer record w/ grainy playback
	"***Letter C***".postln;
	{~currentLetter.string_("C")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[2], \loop, 0]);
	~trig = 0;
	~recTask.play(AppClock);

};

(
~pbs = Array(3);
~trig = 0;
~recTask2 = Task({
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
		"normal playback begins".postln;
		~pbs = ~pbs.add(Synth(\playbuf, [\bufnum, ~buffers[~trig], \mix, 0.66, \outBus, ~wetBus], ~sources));
		~trig.postln;
		2.wait;
		~trig = ~trig + 1;
		~trig.postln;
})});
);

//3.do({|i| ~pbs[i].set(\gate, 0)});// freeing all the synths made with the task above. Free one at a time with ~pbs[#].set(\gate, 0)

~letterDFunc = {//buffer record w/ normal playback
	"***Letter D***".postln;
	{~currentLetter.string_("D")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[3], \loop, 0]);

	~trig = 0;
	~recTask2.play(AppClock);
};

~letterEFunc = {//Boomtown Delay
	"***Letter E***".postln;
	{~currentLetter.string_("E")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[4], \loop, 0]);

	t = Task({
		~recSynth = Synth(\recordBuf, [\bufnum: ~buffers[0]]);

		0.1.wait;

		~pbSynth1 = Synth(\playbackBuf, [
			\bufnum: ~buffers[0],
			\rate: 0.97,
			\mix: 0.5,
			\room: 0.85,
			\outbus: ~wetBus]);
		~pbSynth2 = Synth(\playbackBuf, [
			\bufnum: ~buffers[0],
			\rate: 0.98,
			\mix: 0.5,
			\room: 0.7,
			\outbus: ~wetBus]);
		~pbSynth3 = Synth(\playbackBuf, [
			\bufnum: ~buffers[0],
			\rate: 0.99,
			\mix: 0.45,
			\room: 0.6,
			\outbus: ~wetBus]);
	}).play;
};

~letterFFunc = {//Tap Delay
	"***Letter F***".postln;
	{~currentLetter.string_("F")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[5], \loop, 0]);

	~tapDelay = Synth(\delay, [\delT, 0.5, \decT, 10, \mix, 0.25], ~sources);

};

(
~mult = 1;
~choraleTask = Task({
	~chorale = [~int[0], ~int[0], ~int[7]].collect({|i| Synth(\pitchShift, [\bufnum: ~bansuri[15], \ratio: i, \room, 0.8, \mix, 0.55, \damp, 0.5], ~sources)});
	(5 * ~mult).wait;
	"starting".postln;
	[~int[0], ~int[2], ~int[7]].do({|i,j|~chorale[j].set(\ratio, i)});
	(1 * ~mult).wait;
	[~int[0], ~int[4], ~int[7]].do({|i,j|~chorale[j].set(\ratio, i)});
	(1 * ~mult).wait;
	[~int[0], ~int[5], ~int[7]].do({|i,j|~chorale[j].set(\ratio, i)});
	(2 * ~mult).wait;
	[~int[0], ~int[3], ~int[9]].do({|i,j|~chorale[j].set(\ratio, i)});
	(4 * ~mult).wait;
	[~int[0], ~int[2], ~int[9]].do({|i,j|~chorale[j].set(\ratio, i)});
	(4 * ~mult).wait;

	[~int[0], ~int[11]/2, ~int[5]].do({|i,j|~chorale[j].set(\ratio, i)});
	(4 * ~mult).wait;
	[~int[0], ~int[10]/2, ~int[0]].do({|i,j|~chorale[j].set(\ratio, i)});
	(4 * ~mult).wait;
	[~int[0], ~int[9]/2, ~int[0]].do({|i,j|~chorale[j].set(\ratio, i)});
	(4 * ~mult).wait;

	[~int[0], ~int[9]/2, ~int[2]].do({|i,j|~chorale[j].set(\ratio, i)});
	(6 * ~mult).wait;
	[~int[0], ~int[8]/2, ~int[2]].do({|i,j|~chorale[j].set(\ratio, i)});
	(6 * ~mult).wait;
	[~int[0], ~int[8]/2, ~int[3]].do({|i,j|~chorale[j].set(\ratio, i)});
	(6 * ~mult).wait;
	[~int[0], ~int[7]/2, ~int[3]].do({|i,j|~chorale[j].set(\ratio, i)});
	(6 * ~mult).wait;

	[~int[0], ~int[5]/2, ~int[5]].do({|i,j|~chorale[j].set(\ratio, i)});
	"done".postln;
});
);

~letterGFunc = {//Chorale
	"***Letter G***".postln;
	{~currentLetter.string_("G")}.defer;
	Synth(\playbuf, [\bufnum, ~numbers[6], \loop, 0]);

	~choraleTask.play;
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