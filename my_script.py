import os

with open("env_output.txt", "w") as f:
    for key, value in os.environ.items():
        f.write(f"{key}={value}\n")
