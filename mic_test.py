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
sample_rate = 8000  # Hz
duration = 5  # seconds

print(f"Recording {duration} seconds of raw data at {sample_rate} Hz to {raw_data_file}...")

# Record raw ADC data with precise timing
with open(raw_data_file, "w") as file:
    start_time = time.perf_counter()
    for i in range(sample_rate * duration):
        raw_value = mic_channel.value
        file.write(f"{raw_value}\n")
        while time.perf_counter() - start_time < (i + 1) / sample_rate:
            pass

print(f"Raw data saved to {raw_data_file}.")
