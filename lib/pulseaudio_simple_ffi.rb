#!/usr/bin/env ruby
require 'ffi'

module PulseAudioSimpleFFI
  extend FFI::Library
  ffi_lib 'pulse-simple'

  class IntPtr < FFI::Struct
    layout  :value, :int
  end

  enum :sample_format, [
    :u8, :alaw, :ulaw,
    :s16le, :s16be,
    :f32le, :f32be,
    :s32le, :s32be,
    :s24le, :s24be,
    :s2432le, :s2432be,
    :max, -1,:invalid
  ]

  enum :stream_direction, [
    :nodirection, # invalid direction
    :playback,    # playback stream
    :record,      # record stream
    :upload       # sample upload stream
  ]

  class PulseSampleSpec < FFI::Struct
    layout :format,   :sample_format,
           :rate,     :uint32,
           :channels, :uint8
  end
  
  attach_function :simple_new, :pa_simple_new, [
    :string,  # server name or NULL for default
    :string,  # A descriptive name for this client (application name, ...)
    :stream_direction, # Open this stream for recording or playback?
    :string,  # Sink (resp. source) name, or NULL for default
    :string,  # A descriptive name for this stream (application name, song title, ...)
    PulseSampleSpec,  # The sample type to use
    :pointer, # (UNIMPLEMENTED) The channel map to use, or NULL for default
    :pointer, # (UNIMPLEMENTED) Buffering attributes, or NULL for default
    IntPtr    # A pointer where the error code is stored when the routine returns NULL. It is OK to pass NULL here.
  ], :pointer # Returns type pa_simple*, intentionally undefined in user API.
  
  attach_function :simple_get_latency, :pa_simple_get_latency, [:pointer,:int], :uint64
  attach_function :simple_write, :pa_simple_write, [:pointer,:strptr,:uint64,IntPtr], :int
  attach_function :simple_free, :pa_simple_free, [:pointer], :void

  class PulseAudioSimpleO
    def initialize name,desc,server:nil,device:nil,map:nil,buffer:nil,format: :f32le,rate:44100,channels:2
      ps=PulseSampleSpec.new
      ps[:format]=format
      ps[:rate]=rate
      ps[:channels]=channels
      @err=IntPtr.new
      @err[:value]=0
      # "correct form" is commented below, map and buffer unimplemented in active code
      #@handle=PulseAudioSimpleFFI.simple_new(server,name,:playback,device,desc,ps,map,buffer,@err)
      @handle=PulseAudioSimpleFFI.simple_new(server,name,:playback,device,desc,ps,nil,nil,@err)
      throw [@err[:value],'Error in simple_new(), PulseSimpleO.initialize.'] unless 0 == @err[:value] 
    end
    def write buf
      @err[:value]=0
      PulseAudioSimpleFFI.simple_write @handle,buf,buf.length,@err
      throw [@err[:value],'Error in simple_write(), PulseSimpleO.write.'] unless 0 == @err[:value] 
    end
    def free
      PulseAudioSimpleFFI.simple_free @handle
      @handle=nil
    end
    def latency
      @err[:value]=0
      val=PulseAudioSimpleFFI.simple_get_latency @handle,@err
      throw [@err[:value],'Error in simple_get_latency(), PulseSimpleO.latency.'] unless 0 == @err[:value] 
      val
    end
    alias :close :free
  end
end
