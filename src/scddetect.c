#include "ccv.h"
#include <sys/time.h>
#include <ctype.h>

const ccv_scd_param_t ccv_scd_params = {
	.interval = 5,
	.min_neighbors = 1,
	.step_through = 4,
	.size = {
		.width = 24,
		.height = 24,
	},
};

int main(int argc, char** argv) {
	assert(argc >= 3);
	int i;
	ccv_enable_default_cache();
	ccv_dense_matrix_t* image = 0;
	ccv_scd_classifier_cascade_t* cascade = ccv_scd_classifier_cascade_read(argv[2]);
	ccv_read(argv[1], &image, CCV_IO_RGB_COLOR | CCV_IO_ANY_FILE);
	if (image != 0) {
		ccv_array_t* seq = ccv_scd_detect_objects(image, &cascade, 1, ccv_scd_params);
		printf("[");
		for (i = 0; i < seq->rnum; i++) {
			ccv_comp_t* comp = (ccv_comp_t*)ccv_array_get(seq, i);
			if (i == seq->rnum-1)
				printf("{\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d, \"confidence\": %f}", comp->rect.x, comp->rect.y, comp->rect.width, comp->rect.height, comp->classification.confidence);
			else
				printf("{\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d, \"confidence\": %f},", comp->rect.x, comp->rect.y, comp->rect.width, comp->rect.height, comp->classification.confidence);
		}
		printf("]");
		ccv_array_free(seq);
		ccv_matrix_free(image);
	} else {
		// TODO: Should error when failed to load image
		printf("[]");
	}
	ccv_scd_classifier_cascade_free(cascade);
	ccv_disable_cache();
	return 0;
}
