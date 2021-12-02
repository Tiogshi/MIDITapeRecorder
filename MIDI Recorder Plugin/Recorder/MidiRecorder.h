//
//  MidiRecorder.h
//  MIDI Recorder Plugin
//
//  Created by Geert Bevin on 12/1/21.
//  MIDI Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#import <Foundation/Foundation.h>

#include "QueuedMidiMessage.h"

#import "MidiRecorderDelegate.h"

class MidiRecorderState;

@interface MidiRecorder : NSObject

@property(readonly) int ordinal;
@property(nonatomic) BOOL record;

@property id<MidiRecorderDelegate> delegate;

- (instancetype)init  __attribute__((unavailable("init not available")));
- (instancetype)initWithOrdinal:(int)ordinal;

- (void)setState:(MidiRecorderState*)state;
- (void)recordMidiMessage:(QueuedMidiMessage&)message;

- (void)ping;

- (double_t)duration;
- (NSData*)preview;

@end
