import time
import busio
import digitalio
from board import SCLK, MOSI, MISO, D8  # Adjust GPIO pins if needed
from adafruit_mcp3xxx.analog_in import AnalogIn
from adafruit_mcp3xxx.mcp3008 import MCP3008

# SPI and MCP3008 initialization (unchanged)
spi = busio.SPI(clock=SCLK, MOSI=MOSI, MISO=MISO)
cs = digitalio.DigitalInOut(D8)  # Chip select pin
mcp = MCP3008(spi, cs)

# Correct way to create an AnalogIn channel
mic_channel = AnalogIn(mcp, MCP3008.Pin.CH0)  # Corrected here

print("Reading microphone data...")
try:
    while True:
        # Read voltage and raw ADC value
        print(f"Raw Value: {mic_channel.value}, Voltage: {mic_channel.voltage:.2f} V")
        time.sleep(0.5)  # Adjust as needed
except KeyboardInterrupt:
    print("\nExiting...")
