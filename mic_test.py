import time
import wave
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

print(f"Recording {duration} seconds of audio to {filename}...")

# Open a WAV file for writing
with wave.open(filename, "w") as wav_file:
    wav_file.setnchannels(1)  # Mono audio
    wav_file.setsampwidth(2)  # 16-bit audio
    wav_file.setframerate(sample_rate)

    # Start recording
    start_time = time.perf_counter()
    samples_written = 0

    try:
        while samples_written < num_samples:
            # Scale raw ADC value to 16-bit range
            raw_value = mic_channel.value
            audio_sample = int((raw_value - 32768) / 2)  # Center around 0
            
            # Write sample to WAV file
            wav_file.writeframes(audio_sample.to_bytes(2, byteorder="little", signed=True))
            samples_written += 1

            # Maintain accurate sampling rate
            elapsed_time = time.perf_counter() - start_time
            expected_samples = int(elapsed_time * sample_rate)
            while samples_written < expected_samples:
                samples_written += 1
    except KeyboardInterrupt:
        print("\nRecording stopped.")
    finally:
        print(f"Audio saved to {filename}.")
