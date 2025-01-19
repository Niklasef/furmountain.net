import wave
import numpy as np

# Input and output files
raw_data_file = "raw_sound_data.txt"
wav_output_file = "sound_recording.wav"

# Load raw data
print(f"Converting {raw_data_file} to {wav_output_file}...")
with open(raw_data_file, "r") as file:
    raw_values = [int(line.strip()) for line in file]

# Measure actual sample rate
num_samples = len(raw_values)
recording_duration = 5  # seconds (used in raw data recording)
actual_sample_rate = num_samples / recording_duration
print(f"Number of samples: {num_samples}")
print(f"Actual sample rate: {actual_sample_rate:.2f} Hz")
print(f"Recording duration: {recording_duration:.2f} seconds")

# Convert raw ADC values to 16-bit audio format
audio_samples = np.array(raw_values, dtype=np.int32) - 32768
audio_samples = np.clip(audio_samples, -32768, 32767)
audio_samples = audio_samples.astype(np.int16)

# Write to WAV file with the actual sample rate
with wave.open(wav_output_file, "w") as wav_file:
    wav_file.setnchannels(1)  # Mono
    wav_file.setsampwidth(2)  # 16-bit
    wav_file.setframerate(int(actual_sample_rate))
    wav_file.writeframes(audio_samples.tobytes())

print(f"WAV file saved as {wav_output_file}.")
