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

# File to store raw ADC values
raw_data_file = "raw_sound_data.txt"
sample_rate = 1000  # Hz
duration = 5  # seconds

print(f"Recording {duration} seconds of raw data at max sample rate Hz to {raw_data_file}...")
data_buffer = []

# Record raw ADC data with consistent sleep timing
with open(raw_data_file, "w") as file:
    start_time = time.time()
    while time.time() - start_time < duration:
        raw_value = mic_channel.value
        data_buffer.append(raw_value)

print(f"Raw data saved to {raw_data_file}.")

print("Recording complete. Writing data to file...")

# Write buffered data to file
with open(raw_data_file, "w") as file:
    file.write("\n".join(map(str, data_buffer)))
