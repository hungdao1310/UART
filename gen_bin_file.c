#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void split_text_file(const char* file_path, const char* split_character, const char* output_file_path) {
    FILE* input_file = fopen(file_path, "r");
    if (input_file == NULL) {
        printf("Unable to open the input file.\n");
        return;
    }

    // Get the size of the input file
    fseek(input_file, 0, SEEK_END);
    long input_file_size = ftell(input_file);
    rewind(input_file);

    // Allocate memory to store the input file contents
    char* text = (char*)malloc((input_file_size + 1) * sizeof(char));
    if (text == NULL) {
        printf("Memory allocation failed.\n");
        fclose(input_file);
        return;
    }

    // Read the input file contents
    size_t read_size = fread(text, sizeof(char), input_file_size, input_file);
    if (read_size != input_file_size) {
        printf("Error reading the input file.\n");
        free(text);
        fclose(input_file);
        return;
    }

    text[input_file_size] = '\0';  // Add null terminator

    // Find the split character in the text
    char* split_index = strstr(text, split_character);
    if (split_index != NULL) {
        // Calculate the length of the right-half portion
        size_t right_half_length = strlen(split_index + strlen(split_character));

        // Open the output file for writing
        FILE* output_file = fopen(output_file_path, "w");
        if (output_file == NULL) {
            printf("Unable to open the output file.\n");
            free(text);
            fclose(input_file);
            return;
        }

        // Write the right-half portion to the output file
        fwrite(split_index + strlen(split_character), sizeof(char), right_half_length, output_file);

        fclose(output_file);
        printf("Successfully written the right-half portion to %s\n", output_file_path);
    } else {
        printf("The split character '%s' was not found in the file.\n", split_character);
    }

    free(text);
    fclose(input_file);
}

unsigned int xor_files(const char* file1_path, const char* file2_path) {
    FILE* file1 = fopen(file1_path, "r");
    FILE* file2 = fopen(file2_path, "r");

    if (file1 == NULL || file2 == NULL) {
        printf("Unable to open input files.\n");
        return 0;
    }

    unsigned int xor_sum = 0;
    int byte1, byte2;
    while ((byte1 = fgetc(file1)) != EOF && (byte2 = fgetc(file2)) != EOF) {
        xor_sum ^= byte1 ^ byte2;
    }

    fclose(file1);
    fclose(file2);

    return xor_sum;
}

int main() {
    //createRandomFile();
    split_text_file("teratermabcd.log", "seperateforme123", "output1.txt");
    unsigned int result = xor_files("output123.txt", "output1.txt");
    printf("Sum of all 1-bit XOR results: %u\n", result);
    return 0;
}