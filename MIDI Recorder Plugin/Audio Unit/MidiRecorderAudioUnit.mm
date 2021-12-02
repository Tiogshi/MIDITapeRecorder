//
//  MidiRecorderAudioUnit.mm
//  MIDI Tape Recorder Plugin
//
//  Created by Geert Bevin on 11/27/21.
//  MIDI Tape Recorder ©2021 by Geert Bevin is licensed under CC BY 4.0
//

#import "MidiRecorderAudioUnit.h"

#import <AVFoundation/AVFoundation.h>

#import "AudioUnitViewController.h"

// Define parameter addresses.
const AudioUnitParameterID myParam1 = 0;

@interface MidiRecorderAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree* parameterTree;
@property AUAudioUnitBusArray* inputBusArray;
@property AUAudioUnitBusArray* outputBusArray;

@end


@implementation MidiRecorderAudioUnit {
    AudioUnitViewController* _vc;
}

@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError**)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) { return nil; }
    
    _kernelAdapter = [[DSPKernelAdapter alloc] init];
    
    [self setupAudioBuses];
    [self setupParameterTree];
    [self setupParameterCallbacks];
    
    _vc = nil;
    
    return self;
}

- (void)setVC:(AudioUnitViewController*)vc {
    _vc = vc;
}

#pragma mark - AUAudioUnit Setup

- (void)setupAudioBuses {
    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput
                                                              busses: @[_kernelAdapter.inputBus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_kernelAdapter.outputBus]];
}

- (void)setupParameterTree {
    // Create parameter objects.
    AUParameter* param1 = [AUParameterTree createParameterWithIdentifier:@"param1"
                                                                    name:@"Parameter 1"
                                                                 address:myParam1
                                                                     min:0
                                                                     max:100
                                                                    unit:kAudioUnitParameterUnit_Percent
                                                                unitName:nil
                                                                   flags:kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable
                                                            valueStrings:nil
                                                     dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ /* param1 */  ]];
}

- (void)setupParameterCallbacks {
    // Make a local pointer to the kernel to avoid capturing self.
    __block DSPKernelAdapter*  kernelAdapter = _kernelAdapter;
    
    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter* param, AUValue value) {
        [kernelAdapter setParameter:param value:value];
    };
    
    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter* param) {
        return [kernelAdapter valueForParameter:param];
    };
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter* param, const AUValue* __nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        return [NSString stringWithFormat:@"%.f", value];
    };
}

#pragma mark - AUAudioUnit Overrides

- (AUAudioFrameCount)maximumFramesToRender {
    return _kernelAdapter.maximumFramesToRender;
}

- (void)setMaximumFramesToRender:(AUAudioFrameCount)maximumFramesToRender {
    _kernelAdapter.maximumFramesToRender = maximumFramesToRender;
}

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray*)inputBusses {
    return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray*)outputBusses {
    return _outputBusArray;
}

- (void)setMIDIOutputEventBlock:(AUMIDIOutputEventBlock)MIDIOutputEventBlock {
    _kernelAdapter.ioState->midiOutputEventBlock = MIDIOutputEventBlock;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError**)outError {
    if (_kernelAdapter.outputBus.format.channelCount != _kernelAdapter.inputBus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
        }
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;
        
        return NO;
    }
    
    [super allocateRenderResourcesAndReturnError:outError];
    [_kernelAdapter allocateRenderResources];
    
    _kernelAdapter.ioState->transportStateBlock = self.transportStateBlock;
    _kernelAdapter.ioState->musicalContext = self.musicalContextBlock;
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    [_kernelAdapter deallocateRenderResources];
    
    // Deallocate your resources.
    [super deallocateRenderResources];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    return _kernelAdapter.internalRenderBlock;
}

- (NSInteger)virtualMIDICableCount {
    return 4;
}

- (NSArray<NSString*>*)MIDIOutputNames {
    return @[@"MIDI Out 1", @"MIDI Out 2", @"MIDI Out 3", @"MIDI Out 4"];
}

- (BOOL)supportsMPE {
    return YES;
}

#pragma mark - AUAudioUnit fullState
- (void)setFullState:(NSDictionary<NSString *,id>*)fullState {
    [super setFullState:fullState];
    
    if (_vc == nil) {
        return;
    }

    [_vc readSettingsFromDict:fullState];
    [_vc readRecordingsFromDict:fullState];
}

- (NSDictionary<NSString *,id>*)fullState {
    if (_vc == nil) {
        return [super fullState];
    }

    NSMutableDictionary* state = [NSMutableDictionary new];
    [state addEntriesFromDictionary:[_vc currentSettingsToDict]];
    [state addEntriesFromDictionary:[_vc currentRecordingsToDict]];
    [state addEntriesFromDictionary:[super fullState]];
    return state;
}

@end

