#include <stdio.h>
#include <stdlib.h>
int main(int argc, char** argv) {
    FILE* f = fopen("5.txt", "r");
    char* line = malloc(10);
    int* arr = malloc(4 * 2048);
    int i = 0;
    while(fgets(line, sizeof(line), f) != NULL) {
        arr[i] = atoi(line);
        i++;
    }
    free(line);
    int len = i;
    fclose(f);
    i = 0;
    int steps = 0;
    int cur;
    while(i >= 0 && i < len) {
        cur = arr[i];
        if(cur >= 3) {
            arr[i] = cur - 1;
        } else {
            arr[i] = cur + 1;
        }
        i += cur;
        steps++;
    }
    printf("%d steps", steps);
    free(arr);
    return 0;
}
