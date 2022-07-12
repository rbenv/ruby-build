#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_SIZE 4096

typedef struct {
  unsigned int initial_size;
  unsigned int size;
  unsigned int pos;
  char *data;
} buf_t;

void *buf_malloc(size_t size) {
  void *result = malloc(size);

  if (result == NULL) {
    fprintf(stderr, "error allocating memory, aborting\n");
    exit(1);
  }

  return result;
}

void buf_init(buf_t *this, unsigned int size) {
  this->initial_size = size;
  this->size = size;
  this->pos = 0;
  this->data = buf_malloc(size);
}

void buf_grow(buf_t *this) {
  unsigned int size = this->size + this->initial_size;
  char *data = buf_malloc(size);

  memcpy(data, this->data, this->size);
  free(this->data);
  this->data = data;
  this->size = size;
}

int buf_putc(buf_t *this, int chr) {
  if (this->pos == this->size) {
    buf_grow(this);
  }

  this->data[this->pos] = chr;
  this->pos++;
  return chr;
}

void buf_append(buf_t *this, char *src, unsigned int length) {
  unsigned int i;
  for (i = 0; i < length; i++) {
    buf_putc(this, src[i]);
  }
}

void buf_concat(buf_t *this, buf_t *src) {
  buf_append(this, src->data, src->pos);
}

void buf_print(buf_t *this, FILE *out) {
  unsigned int i;
  for (i = 0; i < this->pos; i++) {
    fputc(this->data[i], out);
  }
}

void buf_reset(buf_t *this) {
  this->pos = 0;
}

void buf_destroy(buf_t *this) {
  buf_reset(this);
  free(this->data);
  this->data = NULL;
}

void rewrite_chunk(buf_t *in, FILE *out, char *src_prefix, char *dst_prefix) {
  unsigned int src_prefix_len, dst_prefix_len, chr, i;
  buf_t result;

  buf_init(&result, BUF_SIZE);
  src_prefix_len = strlen(src_prefix);
  dst_prefix_len = strlen(dst_prefix);
  i = 0;

  while (i < in->pos) {
    buf_append(&result, dst_prefix, dst_prefix_len);
    i += src_prefix_len;

    while (i < in->pos && (chr = in->data[i++])) {
      buf_putc(&result, chr);
    }

    buf_putc(&result, 0);
  }

  for (i = result.pos; i < in->pos; i++) {
    buf_putc(&result, 0);
  }

  buf_print(&result, out);
  buf_destroy(&result);
}

void rewrite(FILE *in, FILE *out, char *src_prefix, char *dst_prefix) {
  unsigned int src_prefix_len, chr;
  buf_t chunk, buf;

  buf_init(&chunk, BUF_SIZE);
  buf_init(&buf, BUF_SIZE);
  src_prefix_len = strlen(src_prefix);

  while ((chr = fgetc(in)) != EOF) {
    if (buf.pos < src_prefix_len && chr == src_prefix[buf.pos]) {
      buf_putc(&buf, chr);
      continue;

    } else if (buf.pos >= src_prefix_len && chr != 0) {
      buf_putc(&buf, chr);
      continue;

    } else if (buf.pos > 0 && chr == 0) {
      buf_concat(&chunk, &buf);
      buf_putc(&chunk, 0);
      buf_reset(&buf);
      continue;
    }

    if (chunk.pos > 0) {
      if (chunk.pos > src_prefix_len) {
        rewrite_chunk(&chunk, out, src_prefix, dst_prefix);
      } else {
        buf_print(&chunk, out);
      }
      buf_reset(&chunk);
    }

    if (buf.pos > 0) {
      buf_print(&buf, out);
      buf_reset(&buf);
    }

    fputc(chr, out);
  }

  buf_destroy(&buf);
  buf_destroy(&chunk);
}

int main(int argc, char **argv) {
  char *src_prefix, *dst_prefix;
  int src_prefix_length;

  if (argc != 3) {
    fprintf(stderr, "usage: %s SRC_PREFIX DST_PREFIX\n", argv[0]);
    return 1;
  }

  src_prefix = argv[1];
  src_prefix_length = strlen(src_prefix);
  dst_prefix = argv[2];

  if (strlen(dst_prefix) > strlen(src_prefix)) {
    fprintf(stderr, "error: destination prefix must be %d bytes or less\n", src_prefix_length);
    return 2;
  }

  rewrite(stdin, stdout, src_prefix, dst_prefix);

  return 0;
}
