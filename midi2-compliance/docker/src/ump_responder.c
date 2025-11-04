#include <alsa/asoundlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

// Minimal ALSA sequencer UMP-capable client.
// Creates a client named "MIDI 2.0" with one input (we receive) and one output (we send).
// Echoes back basic Stream messages and ignores others. This is a stub to let the
// Workbench discover a UMP endpoint for report generation. It does not claim full spec.

static snd_seq_t *seq = NULL;
static int in_port = -1;
static int out_port = -1;

static void setup() {
    int err;
    if ((err = snd_seq_open(&seq, "default", SND_SEQ_OPEN_DUPLEX, 0)) < 0) {
        fprintf(stderr, "snd_seq_open failed: %s\n", snd_strerror(err));
        exit(1);
    }
    snd_seq_set_client_name(seq, "MIDI 2.0");
#ifdef SND_SEQ_CLIENT_UMP
    // Best effort: request MIDI 2.0 client; function name may vary by alsa-lib
    snd_seq_set_client_midi_version(seq, 2);
#endif
    in_port = snd_seq_create_simple_port(seq, "in",
            SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE,
            SND_SEQ_PORT_TYPE_MIDI_GENERIC);
    out_port = snd_seq_create_simple_port(seq, "out",
            SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ,
            SND_SEQ_PORT_TYPE_MIDI_GENERIC);
    if (in_port < 0 || out_port < 0) {
        fprintf(stderr, "create_simple_port failed\n");
        exit(2);
    }
    fprintf(stderr, "[ump-responder] client ready (in=%d out=%d)\n", in_port, out_port);
}

static void send_ump32(uint32_t word) {
    snd_seq_event_t ev;
    snd_seq_ev_clear(&ev);
    ev.type = SND_SEQ_EVENT_UMP;
    ev.flags = SND_SEQ_TIME_STAMP_REAL;
    ev.source.port = out_port;
    ev.dest.client = SND_SEQ_ADDRESS_SUBSCRIBERS;
    ev.dest.port = out_port;
    ev.data.raw32.d[0] = word;
    ev.data.raw32.d[1] = 0;
    ev.data.raw32.d[2] = 0;
    ev.data.raw32.d[3] = 0;
    snd_seq_event_output_direct(seq, &ev);
}

int main() {
    setup();
    // Main loop: poll events and respond minimally to Stream §5 queries by echoing Endpoint Discovery.
    int npfd = snd_seq_poll_descriptors_count(seq, POLLIN);
    struct pollfd *pfd = calloc(npfd, sizeof(struct pollfd));
    snd_seq_poll_descriptors(seq, pfd, npfd, POLLIN);

    while (1) {
        if (poll(pfd, npfd, 250) <= 0) continue;
        snd_seq_event_t *ev = NULL;
        do {
            int rc = snd_seq_event_input(seq, &ev);
            if (rc < 0) break;
            if (!ev) break;
            if (ev->type == SND_SEQ_EVENT_UMP) {
                // Read first word
                uint32_t w0 = ev->data.raw32.d[0];
                uint8_t mt = (w0 >> 28) & 0xF;
                uint8_t group = (w0 >> 24) & 0xF;
                if (mt == 0xF) {
                    uint8_t opcode = (w0 >> 16) & 0xFF;
                    uint8_t data1 = (w0 >> 8) & 0xFF;
                    uint8_t data2 = (w0) & 0xFF;
                    // 0x00: Endpoint Discovery (per typical mapping)
                    if (opcode == 0x00) {
                        // Echo a sane endpoint discovery (major=1 minor=0, maxGroups=8)
                        uint32_t reply = (0xF << 28) | (group << 24) | (0x00 << 16) | (0x10 << 8) | (0x08);
                        send_ump32(reply);
                    }
                }
            }
            snd_seq_free_event(ev);
        } while (snd_seq_event_input_pending(seq, 0) > 0);
    }
    return 0;
}

