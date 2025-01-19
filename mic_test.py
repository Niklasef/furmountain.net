import time
import wave
import numpy as np
import busio
import digitalio
from board import SCLK, MOSI, MISO, D8
from adafruit_mcp3xxx.mcp3008 import MCP3008
from adafruit_mcp3xxx.analog_in import AnalogIn

# SPI and MCP3008 initialization
spi = busio.SPI(clock=SCLK, MOSI=MOSI, MISO=MISO)
cs = digitalio.DigitalInOut(D8)  # Chip select pin
mcp = MCP3008(spi, cs)

# Create an analog input channel on CH0
mic_channel = AnalogIn(mcp, 0)

# WAV file configuration
filename = "mic_recording.wav"
sample_rate = 8000  # Hz
duration = 5  # seconds
num_samples = sample_rate * duration

# WAV file setup
print(f"Recording {duration} seconds of audio to {filename}...")
with wave.open(filename, "w") as wav_file:
    wav_file.setnchannels(1)  # Mono
    wav_file.setsampwidth(2)  # 16-bit
    wav_file.setframerate(sample_rate)

    # Start recording
    start_time = time.perf_counter()
    samples_written = 0
    audio_buffer = []  # Buffer to hold samples temporarily

    try:
        while samples_written < num_samples:
            # Read raw ADC value and scale it to 16-bit audio
            raw_value = mic_channel.value
            audio_sample = int((raw_value - 32768) / 2)  # Center around 0
            audio_buffer.append(audio_sample)

            # Write samples in batches to reduce overhead
            if len(audio_buffer) >= 100:
                wav_file.writeframes(np.array(audio_buffer, dtype=np.int16).tobytes())
                samples_written += len(audio_buffer)
                audio_buffer = []  # Clear the buffer

            # Adjust timing for sample rate
            elapsed_time = time.perf_counter() - start_time
            expected_samples = int(elapsed_time * sample_rate)
            if samples_written < expected_samples:
                continue  # Catch up if behind
    except KeyboardInterrupt:
        print("\nRecording stopped.")
    finally:
        # Write remaining buffer if any
        if audio_buffer:
            wav_file.writeframes(np.array(audio_buffer, dtype=np.int16).tobytes())
            samples_written += len(audio_buffer)
        print(f"Audio saved to {filename}.")
