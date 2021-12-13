//
//  MidiTrackView.h
//  MIDI Tape Recorder Plugin
//
//  Created by Geert Bevin on 11/30/21.
//  MIDI Tape Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#import <UIKit/UIKit.h>

#include <memory>

#include "MidiRecordedPreview.h"

@interface MidiTrackView : UIView

@property(weak, nonatomic) UIScrollView* tracks;

- (void)setPreview:(std::shared_ptr<MidiRecordedPreview>)preview;

@end
