import time
import busio
import digitalio
from board import SCLK, MOSI, MISO, D8  # Adjust GPIO pins if needed
from adafruit_mcp3xxx.mcp3008 import MCP3008
from adafruit_mcp3xxx.analog_in import AnalogIn

# Initialize SPI bus
spi = busio.SPI(clock=SCLK, MOSI=MOSI, MISO=MISO)

# Chip select (CS) pin setup
cs = digitalio.DigitalInOut(D8)  # CE0 pin

# MCP3008 initialization
mcp = MCP3008(spi, cs)

# Create an analog input channel on CH0
mic_channel = AnalogIn(mcp, MCP3008.P0)

print("Reading microphone data...")
try:
    while True:
        # Read voltage and raw ADC value
        print(f"Raw Value: {mic_channel.value}, Voltage: {mic_channel.voltage:.2f} V")
        time.sleep(0.5)  # Adjust as needed
except KeyboardInterrupt:
    print("\nExiting...")
