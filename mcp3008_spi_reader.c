#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <stdlib.h>
#include <time.h>


#define SPI_PATH "/dev/spidev0.0" // Adjust if using a different SPI device
#define SPI_SPEED 3600000
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

    uint8_t mode = SPI_MODE_0;
    uint8_t bits = SPI_BITS;
    uint32_t speed = SPI_SPEED;

    if (ioctl(spi_fd, SPI_IOC_WR_MODE, &mode) < 0 ||
        ioctl(spi_fd, SPI_IOC_RD_MODE, &mode) < 0 ||
        ioctl(spi_fd, SPI_IOC_WR_BITS_PER_WORD, &bits) < 0 ||
        ioctl(spi_fd, SPI_IOC_RD_BITS_PER_WORD, &bits) < 0 ||
        ioctl(spi_fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0 ||
        ioctl(spi_fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed) < 0) {
        perror("Failed to configure SPI");
        close(spi_fd);
        return 1;
    }

    useconds_t delay = 1000000 / samples_per_second; // Microseconds per sample
    struct timespec start, end;

    clock_gettime(CLOCK_MONOTONIC, &start);

    int samples = 0;
    while (1) {
        uint16_t value = read_adc(spi_fd, channel);
        samples++;
        
        clock_gettime(CLOCK_MONOTONIC, &end);
        double elapsed_time = (end.tv_sec - start.tv_sec) +
                              (end.tv_nsec - start.tv_nsec) / 1e9;

        if (elapsed_time >= 1.0) {
            printf("Sample rate: %.2f samples/sec\n", samples / elapsed_time);
            fflush(stdout);
            samples = 0;
            clock_gettime(CLOCK_MONOTONIC, &start);
        }

        // usleep(delay);
    }

    close(spi_fd);
    return 0;
}
