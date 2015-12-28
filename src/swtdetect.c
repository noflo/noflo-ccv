#include "ccv.h"
#include <ctype.h>

int main(int argc, char** argv) {
	int i;
	ccv_enable_default_cache();
	ccv_dense_matrix_t* image = 0;
	ccv_read(argv[1], &image, CCV_IO_GRAY | CCV_IO_ANY_FILE);
	if (image != 0) {
		ccv_array_t* words = ccv_swt_detect_words(image, ccv_swt_default_params);
		if (words) {
			printf("[");
			for (i = 0; i < words->rnum; i++) {
				ccv_rect_t* rect = (ccv_rect_t*)ccv_array_get(words, i);
				if (i == words->rnum-1)
					printf("{\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d}", rect->x, rect->y, rect->width, rect->height);
				else
					printf("{\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d},", rect->x, rect->y, rect->width, rect->height);
			}
			printf("]");
			ccv_array_free(words);
		}
		ccv_matrix_free(image);
	} else {
		printf("[]");
	}
	ccv_drain_cache();
	return 0;
}
