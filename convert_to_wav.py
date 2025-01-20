import wave
import numpy as np

# Input and output files
raw_data_file = "raw_audio_scaled.bin"
wav_output_file = "sound_recording.wav"

# Load raw binary data
print(f"Converting {raw_data_file} to {wav_output_file}...")
with open(raw_data_file, "rb") as file:
    raw_values = np.fromfile(file, dtype=np.int16)

# Measure actual sample rate
num_samples = len(raw_values)
recording_duration = 5  # seconds (as defined in C program)
actual_sample_rate = num_samples / recording_duration
print(f"Number of samples: {num_samples}")
print(f"Actual sample rate: {actual_sample_rate:.2f} Hz")
print(f"Recording duration: {recording_duration:.2f} seconds")

# Since data is already centered and scaled in C, no further processing is needed
# Write to WAV file with the actual sample rate
with wave.open(wav_output_file, "w") as wav_file:
    wav_file.setnchannels(1)  # Mono
    wav_file.setsampwidth(2)  # 16-bit
    wav_file.setframerate(int(actual_sample_rate))
    wav_file.writeframes(raw_values.tobytes())

print(f"WAV file saved as {wav_output_file}.")
