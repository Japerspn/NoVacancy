/*
NO VACANCY, OR, NEON LIGHT ELECTRIC THROUGH 7 MOMENTS OF MINDNIGHT
*/
/*
To - Do

GUI for Anita to practice with
Whisper Delay
- Input Aplitude triggered Line that controls delay amplitude?
- how to change frequency naturally
- Transition to harmonic trem
Boomtown Delay
- implement
Random Buffer Record
- implement
Pitch Shift Chorale

*/

s.boot
(
ServerTree.removeAll;
s.options.memSize_(2.pow(20)).numOutputBusChannels_(2);

~makeNodes = {//a function that will be added to ServerTree, which will evalute it every time the tree gets rebuilt, for example, on cmd + .
	s.bind({//binds these all into a single osc message so they are guaranteed to happen in this order
		~sources = Group.new;
		~outputs = Group.tail;
		'***rebuilt***'.postln;
	})
};

//////////////// BUSES
s.newBusAllocators;
~bufBus = Bus.audio(s, 2);
~dryBus = Bus.audio(s, 2);
~wetBus = Bus.audio(s, 2);

s.waitForBoot({
	//////////////// BUFFERS
	Buffer.freeAll;
	~bansuri = Array.new;
	~folder = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "bansuri/");
	~folder.entries.do({ |path| ~bansuri = ~bansuri.add(Buffer.readChannel(s, path.fullPath, channels: 1)) });

	~numbers = Array.new;
	~folder = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "numbers/");
	~folder.entries.do({ |path| ~numbers = ~numbers.add(Buffer.readChannel(s, path.fullPath, channels: 0)) });

	~buffers = Array.fill(10, {Buffer.alloc(s, 10*s.sampleRate)});

	s.sync;
	"samples loaded".postln;
	//////////////// SYNTHS
	//////////////// SYNTHS
	//////////////// SYNTHS

	SynthDef(\record, {
		arg bufnum = 0, gain = 1, run = 1;
		var sig;
		sig = SoundIn.ar(0);
		RecordBuf.ar(sig, bufnum, recLevel: gain, run: run, loop: 0, doneAction: 2);
	}).add;

	SynthDef(\recordBuf, {// records into specified buffer
		arg bufnum = 0, loop = 1, inbus = 0, outbus = 0, gate = 1, rel = 10, atk = 5;
		var sig, env;

		env = EnvGen.kr(Env.adsr(atk, 1, 1, rel), gate: gate, doneAction: 2);

		sig = RecordBuf.ar(SoundIn.ar(inbus), bufnum, loop: loop, doneAction: 2);// if loop = 0, buffer does not repeat.
		sig = sig * env;
		//Out.ar(outbus, sig)
	}).add;

	SynthDef(\playbuf, {
		arg amp = 1, outBus = 0, gate = 1, bufnum = 0, rate = 1, loop = 1, mix = 0.33, room = 0.5, damp = 0.5;
		var sig, env;

		env = EnvGen.kr(Env.asr, gate, doneAction: 2);

		sig = PlayBuf.ar(1, bufnum, rate, loop: loop, doneAction: 2);
		sig = FreeVerb.ar(sig, mix, room, damp);
		Out.ar(outBus, sig * amp * env);
	}).add;

	SynthDef(\Grain, {
		arg amp = 0.25, grBuf = 0, grHz = 10, grLen = 0.1, pShift = 0, type = 0, playrate = 1, rndoff = 0, outBus = 0;

		var sig, trig, pan, phase, pos, offset, shift = 2**(pShift/12), bufsize = BufFrames.kr(grBuf);

		trig = Select.ar(type, [Impulse.ar(grHz), Dust.ar(grHz)]);
		//impulse is regular pulses, dust is irregular
		pan = TRand.ar(-1.0,1.0,trig);
		//everytime the value becomes non-0, a value between -1 and 1 is selected
		offset = TRand.ar(rndoff.neg,rndoff,trig);

		phase = Phasor.ar(rate: playrate, end: bufsize);
		pos = (phase*bufsize.reciprocal/* + offset*/).wrap(0,1);
		sig = GrainBuf.ar(2, trig, grLen + offset, grBuf, shift, pos, pan: pan);
		sig = FreeVerb.ar(sig, 1, 1, 0);
		Out.ar(outBus ,sig*amp);
	}).add;

	SynthDef(\whisperDelay, {
		arg amp = 1, delT = 0.1, freq = 440, rq = 1, thresh = 0.2, pan = 0, outBus = 0;
		var sig, env = 1, sigAmp;

		sig = SoundIn.ar(0); //live input
		//sig = PlayBuf.ar(1, ~bansuri[4], loop: 1);
		sigAmp = Amplitude.kr(sig)-thresh;
		//sigAmp.poll;
		env = EnvGen.ar(Env.adsr(0.1), sigAmp);
		sig = DelayL.ar(sig, 3.2, delT);
		sig = FreeVerb.ar(sig, 1, 1, 0);
		sig = BPF.ar(sig, freq, rq);
		sig = Pan2.ar(sig, pan);
		Out.ar(outBus, sig * amp * env * LFNoise1.kr(LFNoise0.kr(1, 6, 6), 0.4, 0.4));
	}).add;

	SynthDef(\delay, {
		arg amp = 1, delT = 0.5, decT = 1, outBus = 0, gate = 1, mix = 0.33, room = 0.5, damp = 0.5;
		var sig, env;

		env = EnvGen.kr(Env.asr, gate, doneAction: 2);
		sig = SoundIn.ar(0);
		decT = LFNoise2.kr(0.25, 5, 5).poll;
		sig = CombL.ar(sig, 1, delT, decT);
		sig = Pan2.ar(sig, LFNoise2.kr(1/5));
		sig = FreeVerb.ar(sig, decT/8+0.1, room, damp);
		Out.ar(0, sig * env * amp);
	}).add;

	SynthDef(\pitchShift, {
		arg amp = 1, outBus = 0, gate = 1, bufnum = 0, rate = 1, loop = 1, ratio = 0, mix = 0.33, room = 0.5, damp = 0.5, pan = 0, delT = 0.5, decT = 5;
		var sig, env, dustEnv;

		env = EnvGen.kr(Env.asr, gate, doneAction: 2);
		dustEnv = EnvGen.kr(Env([1,0,1], [0.01, 2]), gate = Dust.kr(1));
		//sig = PlayBuf.ar(1, bufnum, rate, loop: loop, doneAction: 2);
		sig = SoundIn.ar(0);
		sig = PitchShift.ar(sig, 0.2, ratio.lag(0.2));
		sig = Pan2.ar(sig * dustEnv, LFNoise2.kr(1/5));
		//sig = LPF.ar(sig, 500);
		sig = FreeVerb.ar(sig, mix, room, damp);
		Out.ar(outBus, sig * amp * env);
	}).add;

	SynthDef(\playbackBuf, {// plays specified buffer w/ reverb
		arg bufnum = 0, rate = 1, outbus = 0, loop = 1, mix = 0.33, room = 0.5, gate = 1, atk = 5, rel = 10;
		var sig, env;

		env = EnvGen.kr(Env.adsr(atk, 1, 1, rel), gate: gate, doneAction: 2);


		sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, loop: loop, doneAction: 2);
		sig = PitchShift.ar(sig, pitchRatio: rate.reciprocal);
		sig = LPF.ar(sig, 3000);
		sig = HPF.ar(sig, 300);
		sig = FreeVerb.ar(sig, mix, room);
		sig = sig * env;

		Out.ar(~wetBus, sig * 2);
	}).add;

	SynthDef(\outSynth, {
		arg amp = 1, inbus = 0, otherOut = 0;
		var sig;
		sig = In.ar(inbus);
		sig = sig * amp;
		Out.ar([0, otherOut], sig);
	}).add;

	SynthDef(\dryOutSynth, {
		arg amp = 1, inbus = 0, otherOut = 0, gate = 1;
		var sig, env;

		env = EnvGen.kr(Env.asr, gate, doneAction: 2);

		sig = SoundIn.ar(inbus);
		sig = sig * amp * env;
		Out.ar([0, otherOut], sig!2);
	}).add;

	s.freeAll;

	s.sync;
	"synths loaded".postln;
	//////////////// FUNCTIONS
	//////////////// FUNCTIONS
	//////////////// FUNCTIONS
	File(thisProcess.nowExecutingPath.dirname +/+ "NoVacancy_Sections.scd", "r").readAllString.interpret;

	s.sync;
	"functions loaded".postln;
	//////////////// ARRAYS
	//////////////// ARRAYS
	//////////////// ARRAYS

	~whisperFreqs = Array.fill(11, {|i| i * 300});
	~whisperTs = Array.fill(11, {|i| i**2 / 32});
	~int= [1, 17/16, 9/8, 19/16, 5/4, 11/8, 23/16, 3/2, 13/8, 27/16, 29/16, 15/8, 2];

	s.sync;
	"arrays loaded".postln;
	//////////////// PATTERNS
	//////////////// PATTERNS
	//////////////// PATTERNS

	s.sync;
	"patterns loaded".postln;

	ServerTree.add(~makeNodes);
	ServerTree.run;

	s.sync;

	Window.closeAll;
	s.meter;
	s.plotTree;

	//////////////// GUI
	//////////////// GUI
	//////////////// GUI
	File(thisProcess.nowExecutingPath.dirname +/+ "NoVacancy_GUI.scd", "r").readAllString.interpret;
	"GUI loaded".postln;

});
)

x = Synth(\input, [\outBus: 0, \amp: 0.1])
x.set(\gate, 0)
s.reboot;

{SinOsc.ar}.play

(
~trig = 1;
Routine({
	while({~trig == 1}, {
		"1".postln;
		1.wait;
		"2".postln;
		1.wait;

})}).play(AppClock);
)


t.start


(
SynthDef(\whisperDelay, {
	arg amp = 1, delT = 0.1, freq = 440, rq = 1, thresh = 0.2, pan = 0, outBus = 0;
	var sig, env = 1, sigAmp;

	//sig = SoundIn.ar(0); //live input
	sig = PlayBuf.ar(1, ~bansuri[4], loop: 1);
	sigAmp = Amplitude.kr(sig)-thresh;
	//sigAmp.poll;
	env = EnvGen.ar(Env.adsr(0.1), sigAmp);
	sig = DelayL.ar(sig, 3.2, delT);
	sig = FreeVerb.ar(sig, 1, 1, 0);
	sig = BPF.ar(sig, freq, rq);
	sig = Pan2.ar(sig, pan);
	Out.ar(outBus, sig * amp * env * LFNoise1.kr(LFNoise0.kr(1, 6, 6), 0.4, 0.4));
}).add;
)

x = Synth(\whisperDelay, [\freq, 300, \rq, 0.01, \amp, 4, \mix, 1, \room, 1, \damp, 0, \thresh, 0.1])
x = Synth(\whisperDelay, [\freq, 300, \rq, 0.01, \amp, 4, \mix, 1, \room, 1, \damp, 0, \thresh, 0])

x.set(\freq, 300)
x.set(\rq, 1)
x.set(\amp, 1)
x.set(\mix, 0)
x.set(\room, 0.5)
x.set(\damp, 0)
(
~whipserDelays = 10.collect({
	arg i;
	Synth(\whisperDelay, [\freq, ~whisperFreqs[i+1], \rq, 0.01, \delT, ~whisperTs[i + 1], \amp, 4, \thresh, 0, \outBus, ~wetBus]);
});
);

~whipserDelays.do(_.set(\amp, 4))

~whisperTs[1]

x = Synth(\Grain, [\grBuf, ~buffers[0], \grHz, 7, \amp, 0.5, \grLen, 0.4, \type, 0, \playrate, -0.3])
x.set(\grHz, 7, \amp, 0.5, \grLen, 0.4, \type, 0, \playrate, -0.3)//cool effect
x.set(\pShift, 0);//pitch shift
x.set(\grHz, 5);//grains per second
x.set(\amp, 0.5);//volume
x.set(\grLen, 0.1);//how long each grain is
x.set(\type, 1); //randomly spaced grains
x.set(\type, 0); //evenly spaced grains
x.set(\playrate, -0.1); //rate of grains
x.set(\rndoff, 0.2);
x.free;
y.set(\gate, 0)

~bansuri[4].play
Buffer
~record = Synth(\record, [\bufnum, ~buffers[0]]);
~buffers[0].play
~play = Synth(\playbuf, [\bufnum, ~bansuri[5], \mix, 0.66])
~play.set(\mix, 0.66)
~play.set(\gate, 0)

s.plotTree;

(
SynthDef(\delay, {
	arg amp = 1, delT = 0.5, decT = 1, outBus = 0, gate = 1, mix = 0.33, room = 0.5, damp = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.asr, gate, doneAction: 2);
	sig = SoundIn.ar(0);
	decT = LFNoise2.kr(0.25, 5, 5).poll;
	sig = CombL.ar(sig, 1, delT, decT);
	sig = Pan2.ar(sig, LFNoise2.kr(1/5));
	sig = FreeVerb.ar(sig, decT/8+0.1, room, damp);
	Out.ar(0, sig * env * amp);
}).add;
);

x = Synth(\delay, [\delT, 0.5, \decT, 10, \mix, 0.25], ~sources);
x.set(\delT, 0);
x.set(\decT, 0);
x.set(\gate, 0)

(
SynthDef(\pitchShift, {
	arg amp = 1, outBus = 0, gate = 1, bufnum = 0, rate = 1, loop = 1, ratio = 0, mix = 0.33, room = 0.5, damp = 0.5, pan = 0, delT = 0.5, decT = 5;
	var sig, env, dustEnv;

	env = EnvGen.kr(Env.asr, gate, doneAction: 2);
	dustEnv = EnvGen.kr(Env([1,0,1], [0.01, 2]), gate = Dust.kr(1));
	//sig = PlayBuf.ar(1, bufnum, rate, loop: loop, doneAction: 2);
	sig = SoundIn.ar(0);
	sig = PitchShift.ar(sig, 0.2, ratio.lag(0.2));
	sig = Pan2.ar(sig * dustEnv, LFNoise2.kr(1/5));
	//sig = LPF.ar(sig, 500);
	sig = FreeVerb.ar(sig, mix, room, damp);
	Out.ar(outBus, sig * amp * env);
}).add;
)
~int= [1, 17/16, 9/8, 19/16, 5/4, 11/8, 23/16, 3/2, 13/8, 27/16, 29/16, 15/8, 2];

~bansuri.size




~chorale.do(_.set(\gate, 0));
~mult = 1
(
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

~choraleTask.play
s.record





(
p = Pdef(\pat,Pbind(
	\instrument, \pitchShift,
	\bufnum, ~bansuri[7],
	\ratio, ~intervals[4],
	\dur, Prand(Array.fill(10, {0.2.rand+0.9}), inf),
	\legato, 3,
	\amp, 1

));
p.play;
);

