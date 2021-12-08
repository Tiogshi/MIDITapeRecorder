//
//  MidiTrackState.h
//  MIDI Tape Recorder
//
//  Created by Geert Bevin on 12/1/21.
//  MIDI Tape Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#pragma once

#include <atomic>
#include <vector>

#include "RecordedMidiMessage.h"

struct MidiTrackState {
    MidiTrackState() {};
    MidiTrackState(const MidiTrackState&) = delete;
    MidiTrackState& operator= (const MidiTrackState&) = delete;
    
    std::atomic<int32_t> sourceCable    { 0 };
    std::atomic<float>   activityInput  { 0.f };
    std::atomic<float>   activityOutput { 0.f };
    std::atomic<int32_t> recordEnabled  { false };
    std::atomic<int32_t> monitorEnabled { false };
    std::atomic<int32_t> muteEnabled    { false };
    std::atomic<int32_t> recording      { 0 };
    
    std::unique_ptr<std::vector<RecordedMidiMessage>>   recordedMessages    { nullptr };
    std::unique_ptr<std::vector<int>>                   recordedBeatToIndex { nullptr };
    
    std::atomic<uint64_t>   recordedLength      { 0 };
    std::atomic<double>     recordedDuration    { 0.0 };
};
