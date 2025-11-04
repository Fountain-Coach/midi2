#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int ump_alsa_open(void);
int ump_alsa_get_event(uint32_t *words, int *count, int *group);
int ump_alsa_send(const uint32_t *words, int count, int group);

#ifdef __cplusplus
}
#endif

