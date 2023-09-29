#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MIN_CHAR 48  // Minimum ASCII value for numbers ('0')
#define MAX_CHAR 122 // Maximum ASCII value for alphanumeric characters ('z')
#define NUM_CHARS 36 // Total number of alphanumeric characters (26 letters + 10 numbers)

void createRandomAlphanumericFile() {
    FILE* file = fopen("output123.txt", "w"); // Open the file in write mode

    if (file == NULL) {
        printf("Unable to create the file.\n");
        return;
    }

    const int fileSize = 125000; // Desired file size in bytes

    // Seed the random number generator with the current time
    srand(time(NULL));

    for (int i = 0; i < fileSize; ++i) {
        char randomChar = (rand() % NUM_CHARS) + MIN_CHAR; // Generate a random alphanumeric character

        if (randomChar > 57 && randomChar < 65)
            randomChar += 7; // Skip special characters between '9' and 'A'

        fputc(randomChar, file); // Write the random character to the file
    }

    fclose(file); // Close the file

    printf("File created successfully.\n");
}

int main() {
    createRandomAlphanumericFile();

    return 0;
}