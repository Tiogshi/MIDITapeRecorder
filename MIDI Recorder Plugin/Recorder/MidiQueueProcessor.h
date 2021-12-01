//
//  MidiQueueProcessor.h
//  MIDI Recorder Plugin
//
//  Created by Geert Bevin on 11/28/21.
//

#import <Foundation/Foundation.h>

#import "AudioUnitGUIState.h"
#import "MidiQueueProcessorDelegate.h"

@interface MidiQueueProcessor : NSObject

@property id<MidiQueueProcessorDelegate> delegate;

@property(nonatomic) BOOL play;
@property(nonatomic) BOOL record;

- (void)processMidiQueue:(TPCircularBuffer*)queue;

- (void)ping;

- (double_t)recordedTime;
- (uint32_t)recordedCount;


@end
