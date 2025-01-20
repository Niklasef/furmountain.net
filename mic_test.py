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
duration = 5  # seconds

print(f"Recording audio for {duration} seconds at maximum speed...")

# Initialize variables for max-speed recording
start_time = time.perf_counter()
sample_count = 0

# Record samples at max speed
while time.perf_counter() - start_time < duration:
    _ = mic_channel.value  # Read value (no storing)
    sample_count += 1

# Calculate actual sample rate
actual_sample_rate = sample_count / duration
print(f"Recording complete. Total samples recorded: {sample_count}")
print(f"Actual sample rate: {actual_sample_rate:.2f} Hz")
