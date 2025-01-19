import wave
import numpy as np

# Input and output files
raw_data_file = "raw_sound_data.txt"
wav_output_file = "sound_recording.wav"

# WAV file configuration
sample_rate = 8000  # Hz

# Load raw data
print(f"Converting {raw_data_file} to {wav_output_file}...")
with open(raw_data_file, "r") as file:
    raw_values = [int(line.strip()) for line in file]

# Convert raw ADC values to 16-bit audio format
# Scale to fit within the range of -32768 to 32767
audio_samples = np.array(raw_values, dtype=np.int32) - 32768
audio_samples = np.clip(audio_samples, -32768, 32767)  # Ensure no overflow
audio_samples = audio_samples.astype(np.int16)  # Convert to 16-bit

# Write to WAV file
with wave.open(wav_output_file, "w") as wav_file:
    wav_file.setnchannels(1)  # Mono
    wav_file.setsampwidth(2)  # 16-bit
    wav_file.setframerate(sample_rate)
    wav_file.writeframes(audio_samples.tobytes())

print(f"WAV file saved as {wav_output_file}.")
