import time
import busio
import digitalio
import numpy as np
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
duration = 5  # seconds

print(f"Recording audio for {duration} seconds at maximum speed...")

# Pre-allocate buffer with a reasonable estimate for maximum samples
max_estimated_samples = 500000  # Adjust if needed based on your system
data_buffer = np.zeros(max_estimated_samples, dtype=np.uint16)

# Start recording at max speed
start_time = time.perf_counter()
index = 0

while time.perf_counter() - start_time < duration:
    # Read and store the sample
    data_buffer[index] = mic_channel.value
    index += 1

# Trim the buffer to actual size
data_buffer = data_buffer[:index]

print(f"Recording complete. Total samples recorded: {len(data_buffer)}")

# Write buffered data to file
np.savetxt(raw_data_file, data_buffer, fmt="%d")
print(f"Raw data saved to {raw_data_file}.")

# Debugging information
actual_sample_rate = len(data_buffer) / duration
print(f"Actual sample rate: {actual_sample_rate:.2f} Hz")
