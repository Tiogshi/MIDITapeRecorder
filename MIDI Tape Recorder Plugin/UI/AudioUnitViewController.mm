//
//  AudioUnitViewController.mm
//  MIDI Tape Recorder Plugin
//
//  Created by Geert Bevin on 11/27/21.
//  MIDI Tape Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#import "AudioUnitViewController.h"

#import <StoreKit/StoreKit.h>

#include "Constants.h"

#import "ActivityIndicatorView.h"
#import "AboutViewController.h"
#import "CropLeftView.h"
#import "CropRightView.h"
#import "MidiQueueProcessor.h"
#import "MidiRecorder.h"
#import "MidiRecorderAudioUnit.h"
#import "MidiTrackView.h"
#import "MPEButton.h"
#import "PopupView.h"
#import "SettingsViewController.h"
#import "TimelineView.h"

@interface AudioUnitViewController ()

@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityInput1;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityInput2;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityInput3;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityInput4;

@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityOutput1;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityOutput2;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityOutput3;
@property (weak, nonatomic) IBOutlet ActivityIndicatorView* midiActivityOutput4;

@property (weak, nonatomic) IBOutlet UIButton* routingButton;

@property (weak, nonatomic) IBOutlet UIButton* rewindButton;
@property (weak, nonatomic) IBOutlet UIButton* playButton;
@property (weak, nonatomic) IBOutlet UIButton* recordButton;
@property (weak, nonatomic) IBOutlet UIButton* repeatButton;
@property (weak, nonatomic) IBOutlet UIButton* settingsButton;
@property (weak, nonatomic) IBOutlet UIButton* aboutButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* timelineWidth;

@property (weak, nonatomic) IBOutlet UIButton* recordButton1;
@property (weak, nonatomic) IBOutlet UIButton* recordButton2;
@property (weak, nonatomic) IBOutlet UIButton* recordButton3;
@property (weak, nonatomic) IBOutlet UIButton* recordButton4;

@property (weak, nonatomic) IBOutlet UIButton* monitorButton1;
@property (weak, nonatomic) IBOutlet UIButton* monitorButton2;
@property (weak, nonatomic) IBOutlet UIButton* monitorButton3;
@property (weak, nonatomic) IBOutlet UIButton* monitorButton4;

@property (weak, nonatomic) IBOutlet MPEButton* mpeButton1;
@property (weak, nonatomic) IBOutlet MPEButton* mpeButton2;
@property (weak, nonatomic) IBOutlet MPEButton* mpeButton3;
@property (weak, nonatomic) IBOutlet MPEButton* mpeButton4;

@property (weak, nonatomic) IBOutlet UIButton* muteButton1;
@property (weak, nonatomic) IBOutlet UIButton* muteButton2;
@property (weak, nonatomic) IBOutlet UIButton* muteButton3;
@property (weak, nonatomic) IBOutlet UIButton* muteButton4;

@property (weak, nonatomic) IBOutlet UIButton* menuButton1;
@property (weak, nonatomic) IBOutlet UIButton* menuButton2;
@property (weak, nonatomic) IBOutlet UIButton* menuButton3;
@property (weak, nonatomic) IBOutlet UIButton* menuButton4;

@property (weak, nonatomic) IBOutlet PopupView* menuPopup1;
@property (weak, nonatomic) IBOutlet PopupView* menuPopup2;
@property (weak, nonatomic) IBOutlet PopupView* menuPopup3;
@property (weak, nonatomic) IBOutlet PopupView* menuPopup4;

@property (weak, nonatomic) IBOutlet UIButton* closeMenuButton1;
@property (weak, nonatomic) IBOutlet UIButton* closeMenuButton2;
@property (weak, nonatomic) IBOutlet UIButton* closeMenuButton3;
@property (weak, nonatomic) IBOutlet UIButton* closeMenuButton4;

@property (weak, nonatomic) IBOutlet UIButton* clearButton1;
@property (weak, nonatomic) IBOutlet UIButton* clearButton2;
@property (weak, nonatomic) IBOutlet UIButton* clearButton3;
@property (weak, nonatomic) IBOutlet UIButton* clearButton4;

@property (weak, nonatomic) IBOutlet UIButton* exportButton1;
@property (weak, nonatomic) IBOutlet UIButton* exportButton2;
@property (weak, nonatomic) IBOutlet UIButton* exportButton3;
@property (weak, nonatomic) IBOutlet UIButton* exportButton4;

@property (weak, nonatomic) IBOutlet UIButton* importButton1;
@property (weak, nonatomic) IBOutlet UIButton* importButton2;
@property (weak, nonatomic) IBOutlet UIButton* importButton3;
@property (weak, nonatomic) IBOutlet UIButton* importButton4;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* menuPopupWidth1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* menuPopupWidth2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* menuPopupWidth3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* menuPopupWidth4;

@property (weak, nonatomic) IBOutlet UIScrollView* tracks;

@property (weak, nonatomic) IBOutlet TimelineView* timeline;

@property (weak, nonatomic) IBOutlet UIView* playhead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* playheadLeading;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer* playheadPanGesture;

@property (weak, nonatomic) IBOutlet UIView* overlayLeft;
@property (weak, nonatomic) IBOutlet CropLeftView* cropLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* cropLeftLeading;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer* cropLeftPanGesture;

@property (weak, nonatomic) IBOutlet UIView* overlayRight;
@property (weak, nonatomic) IBOutlet CropRightView* cropRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* cropRightLeading;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer* cropRightPanGesture;

@property (weak, nonatomic) IBOutlet MidiTrackView* midiTrack1;
@property (weak, nonatomic) IBOutlet MidiTrackView* midiTrack2;
@property (weak, nonatomic) IBOutlet MidiTrackView* midiTrack3;
@property (weak, nonatomic) IBOutlet MidiTrackView* midiTrack4;

@property (weak, nonatomic) IBOutlet UIView* settingsView;
@property (weak, nonatomic) IBOutlet UIView* aboutView;

@property (weak, nonatomic) IBOutlet SettingsViewController* settingsViewController;
@property (weak, nonatomic) IBOutlet AboutViewController* aboutViewController;

@end

@interface ImportMidiDocumentPickerViewController : UIDocumentPickerViewController

- (instancetype)initWithDocumentTypes:(NSArray<NSString*>*)allowedUTIs inMode:(UIDocumentPickerMode)mode;
@property int track;
@end

@implementation ImportMidiDocumentPickerViewController
- (instancetype)initWithDocumentTypes:(NSArray<NSString*>*)allowedUTIs inMode:(UIDocumentPickerMode)mode {
    return [super initWithDocumentTypes:allowedUTIs inMode:mode];
}
@end

@implementation AudioUnitViewController {
    MidiRecorderAudioUnit* _audioUnit;
    MidiRecorderState* _state;
    CADisplayLink* _timer;

    MidiQueueProcessor* _midiQueueProcessor;
    
    BOOL _autoPlayFromRecord;
    
    CGFloat _extendedMenuPopupWidth;
    
    UIView* _activePannedMarker;
    CGPoint _autoPan;
}

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        _state = nil;
        _audioUnit = nil;
        _timer = nil;
        
        _midiQueueProcessor = [MidiQueueProcessor new];
        for (int t = 0; t < MIDI_TRACKS; ++t) {
            [_midiQueueProcessor recorder:t].delegate = self;
        }
        
        _autoPlayFromRecord = NO;
        _activePannedMarker = nil;
        _autoPan = CGPointZero;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tracks.delegate = self;
    
    _timeline.tracks = _tracks;
    
    MidiTrackView* midi_track[MIDI_TRACKS] = { _midiTrack1, _midiTrack2, _midiTrack3, _midiTrack4 };
    MPEButton* mpe_button[MIDI_TRACKS] = { _mpeButton1, _mpeButton2, _mpeButton3, _mpeButton4 };
    UIView* menu_popup[MIDI_TRACKS] = { _menuPopup1, _menuPopup2, _menuPopup3, _menuPopup4 };
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        midi_track[t].tracks = _tracks;
        menu_popup[t].hidden = YES;
        mpe_button[t].hidden = YES;
    }
    
    _extendedMenuPopupWidth = _menuPopupWidth1.constant;
    
    _timer = [[UIScreen mainScreen] displayLinkWithTarget:self
                                                 selector:@selector(renderloop)];
    _timer.preferredFramesPerSecond = 30;
    _timer.paused = NO;
    [_timer addToRunLoop:[NSRunLoop mainRunLoop]
                 forMode:NSDefaultRunLoopMode];
}

#pragma mark - Create AudioUnit

- (AUAudioUnit*)createAudioUnitWithComponentDescription:(AudioComponentDescription)desc error:(NSError **)error {
    _audioUnit = [[MidiRecorderAudioUnit alloc] initWithComponentDescription:desc error:error];
    [_audioUnit setVC:self];
    
    _state = _audioUnit.kernelAdapter.state;
    [_midiQueueProcessor setState:_state];
    
    AudioUnitViewController* __weak weak_self = self;
    // sync the settings UI with the default settings
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioUnitViewController* s = weak_self;
        if (!s) return;
        [s->_settingsViewController sync];
    });

    // get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    [_audioUnit.parameterTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AudioUnitViewController* s = weak_self;
            if (!s) return;
            switch (address) {
                case ID_RECORD_1:
                case ID_RECORD_2:
                case ID_RECORD_3:
                case ID_RECORD_4: {
                    UIButton* record_button[MIDI_TRACKS] = { s->_recordButton1, s->_recordButton2, s->_recordButton3, s->_recordButton4 };
                    for (int t = 0; t < MIDI_TRACKS; ++t) {
                        record_button[t].selected = s->_state->track[t].recordEnabled;
                    }

                    [s applyRecordEnableState];
                    break;
                }
                case ID_MONITOR_1:
                case ID_MONITOR_2:
                case ID_MONITOR_3:
                case ID_MONITOR_4: {
                    UIButton* monitor_button[MIDI_TRACKS] = { s->_monitorButton1, s->_monitorButton2, s->_monitorButton3, s->_monitorButton4 };
                    for (int t = 0; t < MIDI_TRACKS; ++t) {
                        monitor_button[t].selected = s->_state->track[t].monitorEnabled;
                    }
                    break;
                }
                case ID_MUTE_1:
                case ID_MUTE_2:
                case ID_MUTE_3:
                case ID_MUTE_4: {
                    UIButton* mute_button[MIDI_TRACKS] = { s->_muteButton1, s->_muteButton2, s->_muteButton3, s->_muteButton4 };
                    for (int t = 0; t < MIDI_TRACKS; ++t) {
                        mute_button[t].selected = s->_state->track[t].muteEnabled;
                    }
                    break;
                }
                case ID_REPEAT: {
                    s.repeatButton.selected = s->_state->repeat;
                    break;
                }
            }
        });
    }];

    return _audioUnit;
}

#pragma mark - IBActions

#pragma mark IBAction - Routing

- (IBAction)routingPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self updateRoutingState];
}

#pragma mark IBAction - Rewind

- (IBAction)rewindPressed:(UIButton*)sender {
    [self setRecord:NO];
    _state->scheduledRewind = true;
    [_tracks setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark IBAction - Play

- (IBAction)playPressed:(UIButton*)sender {
    _autoPlayFromRecord = NO;
    [self setPlay:!_playButton.selected];
}

- (void)setPlay:(BOOL)state {
    _playButton.selected = state;

    if (_playButton.selected) {
        if (_recordButton.selected) {
            [self startRecord];
        }
        else {
            _state->scheduledPlay = true;
        }
    }
    else {
        if (_recordButton.selected) {
            [self setRecord:NO];
            _state->scheduledRewind = true;
        }
        _state->scheduledStop = true;
    }
}

#pragma mark IBAction - Record

- (IBAction)recordPressed:(UIButton*)sender {
    BOOL selected = !_recordButton.selected;
    
    if (selected) {
        _autoPlayFromRecord = NO;
        
        if (_playButton.selected) {
            [self startRecord];
        }
        else {
            _state->transportStartSampleSeconds = 0.0;
        }
    }
    else {
        if (_autoPlayFromRecord) {
            _playButton.selected = NO;
            _state->scheduledStopAndRewind = true;
        }
    }
    
    [self setRecord:selected];
}

- (void)setRecord:(BOOL)state {
    _recordButton.selected = state;
    
    [self updateRecordEnableState];
    
    if (!state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self renderPreviews];
        });
    }
}

#pragma mark IBAction - Repeat

- (IBAction)repeatPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self updateRepeatState];
}

#pragma mark IBAction - Import All

- (IBAction)importAllPressed:(UIButton*)sender {
    [self hideMenuPopups];

    ImportMidiDocumentPickerViewController* import_midi = [[ImportMidiDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.midi-audio"] inMode:UIDocumentPickerModeImport];
    import_midi.track = -1;
    import_midi.title = @"Import all tracks";
    [import_midi setDelegate:self];
    [self presentViewController:import_midi animated:NO completion:nil];
}

#pragma mark IBAction - Export All

- (IBAction)exportAllPressed:(UIButton*)sender {
    [self hideMenuPopups];

    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* file_url = [[fm temporaryDirectory] URLByAppendingPathComponent:@"tracks.midi"];
    NSData* recorded = [_midiQueueProcessor recordedTracksAsMidiFile];
    [recorded writeToURL:file_url atomically:YES];
    
    UIDocumentPickerViewController* export_midi = [[UIDocumentPickerViewController alloc] initWithURL:file_url inMode:UIDocumentPickerModeExportToService];
    export_midi.title = @"Export all tracks";
    [export_midi setDelegate:self];
    [self presentViewController:export_midi animated:NO completion:nil];
}

#pragma mark IBAction - Clear All

- (void)clearAllMarkerPositions {
    _state->playPositionBeats = 0.0;
    _state->startPositionBeats = 0.0;
    _state->startPositionSet = false;
    _state->stopPositionSet = false;
    _state->stopPositionBeats = 0.0;
}

- (IBAction)clearAllPressed:(UIButton*)sender {
    [self hideMenuPopups];

    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self withMidiTrackViews:^(int t, MidiTrackView* view) {
            [[self->_midiQueueProcessor recorder:t] clear];
            [view setNeedsLayout];
        }];

        // since the recorder is fully empty, reset all markers
        [self clearAllMarkerPositions];
    }
}

#pragma mark IBAction - Settings

- (IBAction)settingsPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    _settingsView.alpha = 0.0;
    _settingsView.hidden = !sender.selected;
    
    if (_aboutView.hidden) {
        if (sender.selected) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^() {
                                 self->_settingsView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {}];
        }
    }
    else {
        self->_settingsView.alpha = 1.0;
        [self closeAboutView:nil];
    }
}

- (void)closeSettingsView {
    [self closeSettingsView:nil];
}

- (IBAction)closeSettingsView:(id)sender {
    _settingsButton.selected = NO;
    _settingsView.hidden = YES;
}

#pragma mark IBAction - About

- (IBAction)aboutPressed:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    
    _aboutView.alpha = 0.0;
    _aboutView.hidden = !sender.selected;
    
    if (_settingsView.hidden) {
        if (sender.selected) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^() {
                                 self->_aboutView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {}];
        }
    }
    else {
        self->_aboutView.alpha = 1.0;
        
        [self closeSettingsView:nil];
    }
}

- (void)closeAboutView {
    [self closeAboutView:nil];
}

- (IBAction)closeAboutView:(id)sender {
    _aboutButton.selected = NO;
    _aboutView.hidden = YES;
}

#pragma mark IBAction - Monitor Enable

- (IBAction)monitorPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self updateMonitorState];
}

#pragma mark IBAction - Record Enable

- (IBAction)recordEnablePressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self updateRecordEnableState];
}

#pragma mark IBAction - MPE

- (IBAction)mpePressed:(UIButton*)sender {
    NSUInteger index = [@[_mpeButton1, _mpeButton2, _mpeButton3, _mpeButton4] indexOfObject:sender];
    if (index == NSNotFound) {
        return;
    }

    _state->scheduledSendMCM[index] = true;
}

#pragma mark IBAction - Mute

- (IBAction)mutePressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self updateMuteState];
}

#pragma mark IBAction - Menu

- (IBAction)menuPressed:(UIButton*)sender {
    [self hideMenuPopups];

    NSLayoutConstraint* width_constraint = nil;
    UIView* menu_popup_view = nil;
    
    if (sender == _menuButton1) {
        width_constraint = _menuPopupWidth1;
        menu_popup_view = _menuPopup1;
    }
    else if (sender == _menuButton2) {
        width_constraint = _menuPopupWidth2;
        menu_popup_view = _menuPopup2;
    }
    else if (sender == _menuButton3) {
        width_constraint = _menuPopupWidth3;
        menu_popup_view = _menuPopup3;
    }
    else if (sender == _menuButton4) {
        width_constraint = _menuPopupWidth4;
        menu_popup_view = _menuPopup4;
    }
    
    if (width_constraint != nil && menu_popup_view != nil) {
        width_constraint.constant = 40.0;
        
        menu_popup_view.alpha = 0.0;
        for (UIButton* b in menu_popup_view.subviews) {
            b.selected = NO;
            b.alpha = 0.0;
        }
        
        menu_popup_view.hidden = NO;
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             width_constraint.constant = self->_extendedMenuPopupWidth;
                             
                             menu_popup_view.alpha = 1.0;
                             for (UIView* v in menu_popup_view.subviews) {
                                 v.alpha = 1.0;
                             }

                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {}];
    }
}

- (void)hideMenuPopups {
    UIView* menu_popup[MIDI_TRACKS] = { _menuPopup1, _menuPopup2, _menuPopup3, _menuPopup4 };
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        menu_popup[t].hidden = YES;
    }
}

- (IBAction)closeMenuPressed:(UIButton*)sender {
    [self hideMenuPopups];
}

#pragma mark IBAction - Import

- (IBAction)importPressed:(UIButton*)sender {
    [self hideMenuPopups];

    NSUInteger index = [@[_importButton1, _importButton2, _importButton3, _importButton4] indexOfObject:sender];
    if (index == NSNotFound) {
        return;
    }
    
    ImportMidiDocumentPickerViewController* import_midi = [[ImportMidiDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.midi-audio"] inMode:UIDocumentPickerModeImport];
    import_midi.track = (int)index;
    import_midi.title = [NSString stringWithFormat:@"Import track %d", (int)index+1];
    [import_midi setDelegate:self];
    [self presentViewController:import_midi animated:NO completion:nil];
}

#pragma mark IBAction - Export

- (IBAction)exportPressed:(UIButton*)sender {
    [self hideMenuPopups];

    NSUInteger index = [@[_exportButton1, _exportButton2, _exportButton3, _exportButton4] indexOfObject:sender];
    if (index == NSNotFound) {
        return;
    }

    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* file_url = [[fm temporaryDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"track%d.midi", (int)index+1]];
    NSData* recorded = [_midiQueueProcessor recordedTrackAsMidiFile:(int)index];
    [recorded writeToURL:file_url atomically:YES];
    
    UIDocumentPickerViewController* export_midi = [[UIDocumentPickerViewController alloc] initWithURL:file_url inMode:UIDocumentPickerModeExportToService];
    export_midi.title = [NSString stringWithFormat:@"Export track %d", (int)index+1];
    [export_midi setDelegate:self];
    [self presentViewController:export_midi animated:NO completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        if (urls.count == 0) {
            return;
        }
        
        NSURL* url = urls[0];
        NSData* contents = [NSData dataWithContentsOfURL:url];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];

        int track = ((ImportMidiDocumentPickerViewController*)controller).track;
        [_midiQueueProcessor midiFileToRecordedTrack:contents ordinal:track];
        
        [self renderPreviews];
        
        [self withMidiTrackViews:^(int t, MidiTrackView* view) {
            [view setNeedsLayout];
        }];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController*)controller {
}

#pragma mark IBAction - Clear

- (IBAction)clearPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self hideMenuPopups];

        NSUInteger index = [@[_clearButton1, _clearButton2, _clearButton3, _clearButton4] indexOfObject:sender];
        if (index == NSNotFound) {
            return;
        }
        
        MidiTrackView* midi_track[MIDI_TRACKS] = { _midiTrack1, _midiTrack2, _midiTrack3, _midiTrack4 };
        [[_midiQueueProcessor recorder:(int)index] clear];
        [midi_track[index] setNeedsLayout];
        
        // if the recorder is fully empty, reset transport
        if (![self hasRecordedDuration]) {
            [self clearAllMarkerPositions];
        }
    }
}

#pragma mark IBAction - Gestures

- (IBAction)timelineTapGesture:(UITapGestureRecognizer*)gesture {
    [self setPlayDurationForGesture:gesture];
}

- (IBAction)cropLeftDoubleTapGesture:(UITapGestureRecognizer*)sender {
    _state->startPositionSet = false;
    _state->startPositionBeats = 0.0;
}

- (IBAction)cropRightDoubleTapGesture:(UITapGestureRecognizer*)sender {
    _state->stopPositionSet = false;
    _state->stopPositionBeats = _state->maxDuration.load();
}

- (double)calculateBeatPositionForGesture:(UIGestureRecognizer*)gesture {
    return MIN(MAX([gesture locationInView:_tracks].x / PIXELS_PER_BEAT, 0.0), _timelineWidth.constant / PIXELS_PER_BEAT);
}

- (void)setPlayDurationForGesture:(UIGestureRecognizer*)gesture {
    if (gesture.numberOfTouches == 1) {
        _state->playPositionBeats = [self calculateBeatPositionForGesture:gesture];
    }
}

- (void)setCropLeftForGesture:(UIGestureRecognizer*)gesture {
    if (gesture.numberOfTouches == 1) {
        _state->startPositionSet = true;
        _state->startPositionBeats = MIN([self calculateBeatPositionForGesture:gesture], _state->stopPositionBeats.load());
    }
}

- (void)setCropRightForGesture:(UIGestureRecognizer*)gesture {
    if (gesture.numberOfTouches == 1) {
        _state->stopPositionSet = true;
        _state->stopPositionBeats = MAX([self calculateBeatPositionForGesture:gesture], _state->startPositionBeats.load());
    }
}

- (IBAction)markerPanGesture:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self resetAutomaticPanning];
        }
        
        _activePannedMarker = gesture.view;
        if (_activePannedMarker == _playhead) {
            [self setPlayDurationForGesture:gesture];
        }
        else if (_activePannedMarker == _cropLeft) {
            [self setCropLeftForGesture:gesture];
        }
        else if (_activePannedMarker == _cropRight) {
            [self setCropRightForGesture:gesture];
        }

        const CGPoint pos = [gesture locationInView:_tracks.superview];
        const CGRect frame = _tracks.frame;
        const CGFloat pan_margin = 5.0;
        const CGFloat pan_scale = 2.0;
        
        CGFloat left_boundary = frame.origin.x - 10.0 + pan_margin;
        CGFloat right_boundary = frame.origin.x + frame.size.width - 10.0 - pan_margin;
        CGFloat pan_x = 0.0;
        if (pos.x < left_boundary) {
            pan_x = (pos.x - left_boundary) / pan_scale;
        }
        else if (pos.x > right_boundary) {
            pan_x = (pos.x - right_boundary) / pan_scale;
        }
        if (ABS(pan_x) < 1.0) {
            CGFloat sign = (pan_x < 0.0) ? -1.0 : 1.0;
            pan_x = sign * pow(ABS(pan_x), 1.0/4.0);
        }
        
        _autoPan = CGPointMake(pan_x, 0);
    }
    else {
        [self resetAutomaticPanning];
        _activePannedMarker = nil;
    }
}

#pragma mark - State

- (void)readSettingsFromDict:(NSDictionary*)dict {
    id start_position_set = [dict objectForKey:@"startPositionSet"];
    id start_position_beats = [dict objectForKey:@"startPositionBeats"];
    id stop_position_set = [dict objectForKey:@"stopPositionSet"];
    id stop_position_beats = [dict objectForKey:@"stopPositionBeats"];
    id play_position_beats = [dict objectForKey:@"playPositionBeats"];

    id routing = [dict objectForKey:@"Routing"];
    
    id repeat = [dict objectForKey:@"Repeat"];
    
    id record1 = [dict objectForKey:@"Record1"];
    id record2 = [dict objectForKey:@"Record2"];
    id record3 = [dict objectForKey:@"Record3"];
    id record4 = [dict objectForKey:@"Record4"];
    id monitor1 = [dict objectForKey:@"Monitor1"];
    id monitor2 = [dict objectForKey:@"Monitor2"];
    id monitor3 = [dict objectForKey:@"Monitor3"];
    id monitor4 = [dict objectForKey:@"Monitor4"];
    id mute1 = [dict objectForKey:@"Mute1"];
    id mute2 = [dict objectForKey:@"Mute2"];
    id mute3 = [dict objectForKey:@"Mute3"];
    id mute4 = [dict objectForKey:@"Mute4"];
    
    id send_mpe = [dict objectForKey:@"SendMpeConfigOnPlay"];
    id mpe_details = [dict objectForKey:@"DisplayMpeConfigDetails"];
    id auto_trim = [dict objectForKey:@"AutoTrimRecordings"];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (start_position_set) {
            self->_state->startPositionSet = [start_position_set boolValue];
        }
        if (start_position_beats) {
            self->_state->startPositionBeats = [start_position_beats doubleValue];
        }
        if (stop_position_set) {
            self->_state->stopPositionSet = [stop_position_set boolValue];
        }
        if (stop_position_beats) {
            self->_state->stopPositionBeats = [stop_position_beats doubleValue];
        }
        if (play_position_beats) {
            self->_state->playPositionBeats = [play_position_beats doubleValue];
        }

        if (routing) {
            self->_routingButton.selected = [routing boolValue];
        }

        if (repeat) {
            self->_repeatButton.selected = [repeat boolValue];
        }
        
        if (record1) {
            self->_recordButton1.selected = [record1 boolValue];
        }
        if (record2) {
            self->_recordButton2.selected = [record2 boolValue];
        }
        if (record3) {
            self->_recordButton3.selected = [record3 boolValue];
        }
        if (record4) {
            self->_recordButton4.selected = [record4 boolValue];
        }

        if (monitor1) {
            self->_monitorButton1.selected = [monitor1 boolValue];
        }
        if (monitor2) {
            self->_monitorButton2.selected = [monitor2 boolValue];
        }
        if (monitor3) {
            self->_monitorButton3.selected = [monitor3 boolValue];
        }
        if (monitor4) {
            self->_monitorButton4.selected = [monitor4 boolValue];
        }

        if (mute1) {
            self->_muteButton1.selected = [mute1 boolValue];
        }
        if (mute2) {
            self->_muteButton2.selected = [mute2 boolValue];
        }
        if (mute3) {
            self->_muteButton3.selected = [mute3 boolValue];
        }
        if (mute4) {
            self->_muteButton4.selected = [mute4 boolValue];
        }
        
        if (send_mpe) {
            self->_state->sendMpeConfigOnPlay = [send_mpe boolValue];
        }
        if (mpe_details) {
            self->_state->displayMpeConfigDetails = [mpe_details boolValue];
        }
        if (auto_trim) {
            self->_state->autoTrimRecordings = [auto_trim boolValue];
        }

        [self updateRoutingState];
        [self updateRepeatState];
        [self updateMonitorState];
        [self updateRecordEnableState];
        [self updateMuteState];
        
        [self->_settingsViewController sync];
    });
}

- (void)readRecordingsFromDict:(NSDictionary*)dict {
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        NSString* key = [NSString stringWithFormat:@"Recorder%d", t];
        id recorded = [dict objectForKey:key];
        if (recorded) {
            [[_midiQueueProcessor recorder:t] dictToRecorded:recorded];
        }
    }
}

- (NSDictionary*)currentSettingsToDict {
    return @{
        @"startPositionSet" : @(_state->startPositionSet.load()),
        @"startPositionBeats" : @(_state->startPositionBeats.load()),
        @"stopPositionSet" : @(_state->stopPositionSet.load()),
        @"stopPositionBeats" : @(_state->stopPositionBeats.load()),
        @"playPositionBeats" : @(_state->playPositionBeats.load()),
        @"Routing" : @(_routingButton.selected),
        @"Repeat" : @(_repeatButton.selected),
        @"Record1" : @(_recordButton1.selected),
        @"Record2" : @(_recordButton2.selected),
        @"Record3" : @(_recordButton3.selected),
        @"Record4" : @(_recordButton4.selected),
        @"Monitor1" : @(_monitorButton1.selected),
        @"Monitor2" : @(_monitorButton2.selected),
        @"Monitor3" : @(_monitorButton3.selected),
        @"Monitor4" : @(_monitorButton4.selected),
        @"Mute1" : @(_muteButton1.selected),
        @"Mute2" : @(_muteButton2.selected),
        @"Mute3" : @(_muteButton3.selected),
        @"Mute4" : @(_muteButton4.selected),
        @"SendMpeConfigOnPlay" : @(_state->sendMpeConfigOnPlay.load()),
        @"DisplayMpeConfigDetails" : @(_state->displayMpeConfigDetails.load()),
        @"AutoTrimRecordings" : @(_state->autoTrimRecordings.load())
    };
}

- (NSDictionary*)currentRecordingsToDict {
    NSMutableDictionary* result = [NSMutableDictionary new];
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        [result setObject:[[_midiQueueProcessor recorder:t] recordedAsDict] forKey:[NSString stringWithFormat:@"Recorder%d", t]];
    }
    return result;
}

- (MidiRecorderState*)state {
    return _state;
}

#pragma mark Update State

- (void)updateRoutingState {
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_routingButton.selected) {
            _state->track[t].sourceCable = t;
        }
        else {
            _state->track[t].sourceCable = 0;
        }
    }
}

- (void)updateRecordEnableState {
    UIButton* record_button[MIDI_TRACKS] = { _recordButton1, _recordButton2, _recordButton3, _recordButton4 };

    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_state->track[t].recordEnabled != record_button[t].selected) {
            _state->track[t].recordEnabled = record_button[t].selected;
            
            if (_state->hostParamChange) {
                _state->hostParamChange(ID_RECORD_1 + t, _state->track[t].recordEnabled);
            }
        }
    }
    
    [self applyRecordEnableState];
}

- (void)applyRecordEnableState {
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        [_midiQueueProcessor recorder:t].record = (_recordButton.selected && _state->track[t].recordEnabled);
    }
}

- (void)updateMonitorState {
    UIButton* monitor_button[MIDI_TRACKS] = { _monitorButton1, _monitorButton2, _monitorButton3, _monitorButton4 };

    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_state->track[t].monitorEnabled != monitor_button[t].selected) {
            _state->track[t].monitorEnabled = monitor_button[t].selected;
            
            if (_state->hostParamChange) {
                _state->hostParamChange(ID_MONITOR_1 + t, _state->track[t].monitorEnabled);
            }
        }
    }
}

- (void)updateMuteState {
    UIButton* mute_button[MIDI_TRACKS] = { _muteButton1, _muteButton2, _muteButton3, _muteButton4 };

    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_state->track[t].muteEnabled != mute_button[t].selected) {
            _state->track[t].muteEnabled = mute_button[t].selected;
            
            if (_state->hostParamChange) {
                _state->hostParamChange(ID_MUTE_1 + t, _state->track[t].muteEnabled);
            }
        }
    }
}

- (void)updateRepeatState {
    if (_state->repeat != _repeatButton.selected) {
        _state->repeat = _repeatButton.selected;
        
        if (_state->hostParamChange) {
            _state->hostParamChange(ID_REPEAT, _state->repeat);
        }
    }
}

#pragma mark - Rendering

- (void)viewDidLayoutSubviews {
    [_timeline setNeedsLayout];

    [self withMidiTrackViews:^(int t, MidiTrackView* view) {
        [view setNeedsLayout];
    }];
}

- (void)checkActivityIndicators {
    ActivityIndicatorView* inputs[MIDI_TRACKS] = { _midiActivityInput1, _midiActivityInput2, _midiActivityInput3, _midiActivityInput4 };
    ActivityIndicatorView* outputs[MIDI_TRACKS] = { _midiActivityOutput1, _midiActivityOutput2, _midiActivityOutput3, _midiActivityOutput4 };

    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_state->track[t].activityInput) {
            _state->track[t].activityInput = false;
            inputs[t].showActivity = YES;
        }
        else {
            inputs[t].showActivity = NO;
        }
        
        if (_state->track[t].activityOutput) {
            _state->track[t].activityOutput = false;
            outputs[t].showActivity = YES;
        }
        else {
            outputs[t].showActivity = NO;
        }
    }
}

- (void)handleScheduledActions {
    // rewind UI
    {
        bool active = true;
        if (_state->scheduledUIStopAndRewind.compare_exchange_strong(active, false)) {
            [self setPlay:NO];
            _state->scheduledRewind = true;
        }
    }

    // play UI
    {
        bool active = true;
        if (_state->scheduledUIPlay.compare_exchange_strong(active, false)) {
            [self setPlay:YES];
        }
    }

    // stop UI
    {
        bool active = true;
        if (_state->scheduledUIStop.compare_exchange_strong(active, false)) {
            [self setPlay:NO];
        }
    }
}

- (void)renderPreviews {
    // update the previews and the timeline
    __block double max_duration = 0.0;
    
    [self withMidiTrackViews:^(int t, MidiTrackView* view) {
        view.preview = [self->_midiQueueProcessor recorder:t].preview;
        
        max_duration = MAX(max_duration, [self->_midiQueueProcessor recorder:t].duration);
        
        if (self->_recordButton.selected) {
            [view setNeedsLayout];
        }
    }];
    
    _state->maxDuration = max_duration;
    _timelineWidth.constant = max_duration * PIXELS_PER_BEAT;
}

- (BOOL)hasRecordedDuration {
    BOOL has_recorder_duration = NO;
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if ([_midiQueueProcessor recorder:t].duration != 0.0) {
            has_recorder_duration = YES;
            break;
        }
    }
    
    return has_recorder_duration;
}

- (void)renderPlayhead {
    // playhead position
    _playheadLeading.constant = _state->playPositionBeats * PIXELS_PER_BEAT;
    _playhead.hidden = ![self hasRecordedDuration];

    // scroll view location
    if (!_playhead.hidden && !_activePannedMarker && (_playButton.selected || _recordButton.selected)) {
        CGFloat content_offset;
        if (_playhead.frame.origin.x < _tracks.frame.size.width / 2.0) {
            content_offset = 0.0;
        }
        else {
            content_offset = MAX(MIN(_playhead.frame.origin.x - _tracks.frame.size.width / 2.0,
                                 _tracks.contentSize.width - _tracks.bounds.size.width + _tracks.contentInset.left), 0.0);
        }
        [_tracks setContentOffset:CGPointMake(content_offset, 0) animated:NO];
    }
    
    // start position crop marker
    _overlayLeft.hidden = _playhead.hidden;
    _cropLeft.hidden = _playhead.hidden;
    if (!_cropLeft.hidden) {
        if (!_state->startPositionSet && !_activePannedMarker) {
            _state->startPositionBeats = 0.0;
        }
        _cropLeftLeading.constant = _state->startPositionBeats * PIXELS_PER_BEAT;
    }

    // stop position crop marker
    _overlayRight.hidden = _playhead.hidden;
    _cropRight.hidden = _playhead.hidden;
    if (!_cropRight.hidden) {
        if (!_state->stopPositionSet && !_activePannedMarker) {
            _state->stopPositionBeats = _state->maxDuration.load();
        }
        _cropRightLeading.constant = _state->stopPositionBeats * PIXELS_PER_BEAT;
    }
}

- (void)renderMpeIndicators {
    bool active = true;
    bool refresh_mpe_buttons = _state->scheduledUIMpeConfigChange.compare_exchange_strong(active, false);

    MPEButton* mpe_button[MIDI_TRACKS] = { _mpeButton1, _mpeButton2, _mpeButton3, _mpeButton4 };
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        MPEState& state = _state->track[t].mpeState;
        BOOL button_hidden = (state.enabled == false);
        if (button_hidden != mpe_button[t].hidden || refresh_mpe_buttons) {
            mpe_button[t].hidden = button_hidden;
            NSString* mpe_label = @"";
            if (state.enabled) {
                mpe_label = @"MPE";
                if (_state->displayMpeConfigDetails) {
                    if (state.zone1Active) {
                        mpe_label = [mpe_label stringByAppendingFormat:@" L:%d", state.zone1Members.load()];
                    }
                    if (state.zone2Active) {
                        mpe_label = [mpe_label stringByAppendingFormat:@" U:%d", state.zone2Members.load()];
                    }
                }
            }
            
            [mpe_button[t] setTitle:mpe_label forState:UIControlStateNormal];
        }
    }
}

- (void)applyAutoPan {
    if (_autoPan.x != 0.0f) {
        CGFloat offset_x = _tracks.contentOffset.x + _autoPan.x;
        offset_x = MAX(MIN(offset_x, _tracks.contentSize.width - _tracks.bounds.size.width + _tracks.contentInset.left), 0.0);
        [_tracks setContentOffset:CGPointMake(offset_x, 0) animated:NO];

        if (_activePannedMarker == _playhead) {
            [self setPlayDurationForGesture:_playheadPanGesture];
        }
        else if (_activePannedMarker == _cropLeft) {
            [self setCropLeftForGesture:_cropLeftPanGesture];
        }
        else if (_activePannedMarker == _cropRight) {
            [self setCropRightForGesture:_cropRightPanGesture];
        }
    }
}

- (void)resetAutomaticPanning {
    _autoPan = CGPointZero;
}

- (void)renderloop {
    if (_audioUnit) {
        [self checkActivityIndicators];

        [_midiQueueProcessor processMidiQueue:&_state->midiBuffer];

        [self handleScheduledActions];
        
        [self renderPreviews];
        [self renderPlayhead];
        [self renderMpeIndicators];
        [self applyAutoPan];
    }
}

#pragma mark - MidiRecorderDelegate methods

- (void)startRecord {
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        if (_state->track[t].recordEnabled) {
            _state->scheduledBeginRecording[t] = true;
        }
    }
    if (!self.playButton.selected) {
        _autoPlayFromRecord = YES;
        self.playButton.selected = YES;
    }
    _state->scheduledPlay = true;
}

- (void)finishRecording:(int)ordinal
                   data:(RecordedData)data
            beatToIndex:(RecordedBookmarks)beatToIndex
                preview:(RecordedPreview)preview
               duration:(double)duration {
    _state->scheduledEndRecording[ordinal] = true;
    
    MidiTrackState& state = _state->track[ordinal];
    state.recordedMessages = std::move(data);
    state.recordedBeatToIndex = std::move(beatToIndex);
    state.recordedPreview = preview;
    state.recordedLength = (state.recordedMessages ? state.recordedMessages->size() : 0);
    state.recordedDuration = duration;
}

- (void)invalidateRecording:(int)ordinal {
    _state->scheduledNotesOff[ordinal] = true;
    _state->scheduledInvalidate[ordinal] = true;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [_timeline setNeedsLayout];
    
    [self withMidiTrackViews:^(int ordinal, MidiTrackView* view) {
        [view setNeedsLayout];
    }];
}

#pragma mark - Collection processors

- (void)withMidiTrackViews:(void (^)(int t, MidiTrackView* view))block {
    MidiTrackView* midi_track[MIDI_TRACKS] = { _midiTrack1, _midiTrack2, _midiTrack3, _midiTrack4 };
    for (int t = 0; t < MIDI_TRACKS; ++t) {
        block(t, midi_track[t]);
    }
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:AboutViewController.class]) {
        _aboutViewController = segue.destinationViewController;
        _aboutViewController.mainViewController = self;
    }
    else if ([segue.destinationViewController isKindOfClass:SettingsViewController.class]) {
        _settingsViewController = segue.destinationViewController;
        _settingsViewController.mainViewController = self;
    }
}

@end
