#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <stdlib.h>

#define SPI_PATH "/dev/spidev0.0" // Adjust if using a different SPI device
#define SPI_SPEED 1000000          // SPI speed (1 MHz)
#define SPI_BITS 8                 // Bits per word
#define SPI_DELAY 0

// Function to read data from MCP3008
uint16_t read_adc(int spi_fd, uint8_t channel) {
    if (channel > 7) {
        fprintf(stderr, "Invalid channel: %d\n", channel);
        exit(1);
    }

    uint8_t tx[] = {
        0x01, // Start bit
        (uint8_t)((0x08 | channel) << 4), // Configuration byte
        0x00  // Dummy byte to receive data
    };

    uint8_t rx[3] = {0};
    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)tx,
        .rx_buf = (unsigned long)rx,
        .len = sizeof(tx),
        .delay_usecs = SPI_DELAY,
        .speed_hz = SPI_SPEED,
        .bits_per_word = SPI_BITS,
    };

    if (ioctl(spi_fd, SPI_IOC_MESSAGE(1), &tr) < 0) {
        perror("Failed to communicate with MCP3008");
        exit(1);
    }

    // Combine the received bytes to form the 10-bit ADC value
    return ((rx[1] & 0x03) << 8) | rx[2];
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <channel> <samples_per_second>\n", argv[0]);
        return 1;
    }

    int channel = atoi(argv[1]);
    int samples_per_second = atoi(argv[2]);

    if (channel < 0 || channel > 7) {
        fprintf(stderr, "Channel must be between 0 and 7.\n");
        return 1;
    }

    if (samples_per_second <= 0) {
        fprintf(stderr, "Samples per second must be positive.\n");
        return 1;
    }

    int spi_fd = open(SPI_PATH, O_RDWR);
    if (spi_fd < 0) {
        perror("Failed to open SPI device");
        return 1;
    }

    // Configure SPI mode
    uint8_t mode = SPI_MODE_0;
    if (ioctl(spi_fd, SPI_IOC_WR_MODE, &mode) < 0 || ioctl(spi_fd, SPI_IOC_RD_MODE, &mode) < 0) {
        perror("Failed to set SPI mode");
        close(spi_fd);
        return 1;
    }

    // Configure SPI bits per word
    uint8_t bits = SPI_BITS;
    if (ioctl(spi_fd, SPI_IOC_WR_BITS_PER_WORD, &bits) < 0 || ioctl(spi_fd, SPI_IOC_RD_BITS_PER_WORD, &bits) < 0) {
        perror("Failed to set SPI bits per word");
        close(spi_fd);
        return 1;
    }

    // Configure SPI speed
    uint32_t speed = SPI_SPEED;
    if (ioctl(spi_fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0 || ioctl(spi_fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed) < 0) {
        perror("Failed to set SPI speed");
        close(spi_fd);
        return 1;
    }

    // Sampling loop
    useconds_t delay = 1000000 / samples_per_second; // Microseconds per sample
    while (1) {
        uint16_t value = read_adc(spi_fd, channel);
        printf("%u\n", value);
        fflush(stdout);
        usleep(delay);
    }

    close(spi_fd);
    return 0;
}
