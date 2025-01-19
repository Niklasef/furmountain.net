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

# Recording configuration
sample_rate = 8000  # Hz
duration = 5  # seconds
num_samples = sample_rate * duration

print(f"Recording {duration} seconds of raw data to {raw_data_file}...")

# Record raw ADC data
with open(raw_data_file, "w") as file:
    start_time = time.time()
    while time.time() - start_time < duration:
        raw_value = mic_channel.value
        file.write(f"{raw_value}\n")
        time.sleep(1 / sample_rate)

print(f"Raw data saved to {raw_data_file}.")
