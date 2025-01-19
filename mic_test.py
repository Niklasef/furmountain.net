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
sample_rate = 1000  # Hz
duration = 5  # seconds
num_samples = sample_rate * duration

print(f"Recording {duration} seconds of raw data at {sample_rate} Hz...")

# Buffer to store raw ADC values
data_buffer = []

# Record raw ADC data into memory
start_time = time.time()
for _ in range(num_samples):
    raw_value = mic_channel.value
    data_buffer.append(raw_value)

    # Sleep to maintain sampling rate
    elapsed_time = time.time() - start_time
    target_time = len(data_buffer) / sample_rate
    if target_time > elapsed_time:
        time.sleep(target_time - elapsed_time)

print("Recording complete. Writing data to file...")

# Write buffered data to file
with open(raw_data_file, "w") as file:
    file.write("\n".join(map(str, data_buffer)))

print(f"Raw data saved to {raw_data_file}.")
