import time
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

# Configuration
raw_data_file = "raw_sound_data.txt"
sample_rate = 3000  # Hz
duration = 5  # seconds
num_samples = sample_rate * duration

print(f"Recording {duration} seconds of audio at {sample_rate} Hz...")

# Buffer to store raw ADC values
data_buffer = []
time_per_sample = 1 / sample_rate  # Target time per sample in seconds

# Record raw ADC data
start_time = time.perf_counter()
for _ in range(num_samples):
    raw_value = mic_channel.value
    data_buffer.append(raw_value)

    # Maintain precise timing
    elapsed_time = time.perf_counter() - start_time
    expected_time = len(data_buffer) * time_per_sample
    if expected_time > elapsed_time:
        time.sleep(expected_time - elapsed_time)

print("Recording complete. Writing data to file...")

# Write buffered data to file
with open(raw_data_file, "w") as file:
    file.write("\n".join(map(str, data_buffer)))

print(f"Raw data saved to {raw_data_file}.")

# Debugging information
print(f"Number of samples: {len(data_buffer)}")
actual_sample_rate = len(data_buffer) / duration
print(f"Actual sample rate: {actual_sample_rate:.2f} Hz")
