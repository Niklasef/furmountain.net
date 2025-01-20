#include <time.h>

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

        usleep(delay);
    }

    close(spi_fd);
    return 0;
}
