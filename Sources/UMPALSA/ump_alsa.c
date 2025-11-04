#include "ump_alsa.h"
#include <unistd.h>

#ifdef __APPLE__
// Stubs for non-Linux builds
int ump_alsa_open(void) { return -1; }
int ump_alsa_get_event(uint32_t *words, int *count, int *group) { return -1; }
int ump_alsa_send(const uint32_t *words, int count, int group) { return -1; }
#else
#include <alsa/asoundlib.h>

static snd_seq_t *seq = NULL;
static int in_port = -1;
static int out_port = -1;

int ump_alsa_open(void) {
    int err;
    if ((err = snd_seq_open(&seq, "default", SND_SEQ_OPEN_DUPLEX, 0)) < 0) {
        return err;
    }
    snd_seq_set_client_name(seq, "MIDI 2.0");
#ifdef SND_SEQ_CLIENT_UMP
    snd_seq_set_client_midi_version(seq, 2);
#endif
    in_port = snd_seq_create_simple_port(seq, "in",
            SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE,
            SND_SEQ_PORT_TYPE_MIDI_GENERIC);
    out_port = snd_seq_create_simple_port(seq, "out",
            SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ,
            SND_SEQ_PORT_TYPE_MIDI_GENERIC);
    return (in_port < 0 || out_port < 0) ? -1 : 0;
}

int ump_alsa_get_event(uint32_t *words, int *count, int *group) {
    if (!seq) return -1;
    snd_seq_event_t *ev = NULL;
    int rc = snd_seq_event_input(seq, &ev);
    if (rc < 0 || !ev) return -1;
    if (ev->type != SND_SEQ_EVENT_UMP) { snd_seq_free_event(ev); return -1; }
    // Extract up to 4 words
    words[0] = ev->data.raw32.d[0];
    words[1] = ev->data.raw32.d[1];
    words[2] = ev->data.raw32.d[2];
    words[3] = ev->data.raw32.d[3];
    // Guess count by MT nibble
    uint8_t mt = (words[0] >> 28) & 0xF;
    if (mt == 0x5) *count = 4; // Data 128-bit
    else if (mt == 0x4) *count = 2; // MIDI 2.0 CV
    else *count = 1; // Stream or MIDI1 32-bit
    *group = (words[0] >> 24) & 0xF;
    snd_seq_free_event(ev);
    return 0;
}

int ump_alsa_send(const uint32_t *w, int count, int group) {
    if (!seq) return -1;
    snd_seq_event_t ev; snd_seq_ev_clear(&ev);
    ev.type = SND_SEQ_EVENT_UMP;
    ev.flags = SND_SEQ_TIME_STAMP_REAL;
    ev.source.port = out_port;
    ev.dest.client = SND_SEQ_ADDRESS_SUBSCRIBERS;
    ev.dest.port = out_port;
    ev.data.raw32.d[0] = w[0];
    ev.data.raw32.d[1] = (count > 1) ? w[1] : 0;
    ev.data.raw32.d[2] = (count > 2) ? w[2] : 0;
    ev.data.raw32.d[3] = (count > 3) ? w[3] : 0;
    return snd_seq_event_output_direct(seq, &ev);
}

#endif // __APPLE__
