//
//  MidiRecorderKernel.h
//  MIDI Tape Recorder Plugin
//
//  Created by Geert Bevin on 11/27/21.
//  MIDI Tape Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#pragma once

#include "NoteState.h"

#import "AudioUnitIOState.h"
#import "DSPKernel.h"
#import "MidiRecorderState.h"

class MidiRecorderKernel : public DSPKernel {
public:
    MidiRecorderKernel();
    
    void cleanup();

    bool isBypassed();
    void setBypass(bool shouldBypass);
    
    void setParameter(AUParameterAddress address, AUValue value);
    AUValue getParameter(AUParameterAddress address);

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList);
    
    void handleBufferStart() override;
    void handleScheduledTransitions() override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
    void handleParameterEvent(AUParameterEvent const& parameterEvent) override;
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    void processOutput() override;

    MidiRecorderState _state;
    AudioUnitIOState _ioState;

private:
    bool isRecording();
    void queueBufferPingIfNeeded();

    void sendRpnMessage(uint8_t cable, uint8_t channel, uint16_t number, uint16_t value);
    void sendMCM(int track);

    void rewind();
    void play();
    void stop();
    void endRecording(int track);

    void passThroughMIDIEvent(AUMIDIEvent const& midiEvent, int cable);
    void queueMIDIEvent(AUMIDIEvent const& midiEvent);
    void turnOffAllNotes();
    void turnOffAllNotesForTrack(int track);
    void outputMidiMessages(double beatRrangeBegin, double beatRangeEnd);

    bool _bypassed          { false };
    bool _isPlaying         { false };
    bool _isWaitingForBeat  { false };
    bool _sentBufferPing    { false };

    NoteState _noteStates[MIDI_TRACKS];

    AudioBufferList* _inBufferList  { nullptr };
    AudioBufferList* _outBufferList { nullptr };
};
