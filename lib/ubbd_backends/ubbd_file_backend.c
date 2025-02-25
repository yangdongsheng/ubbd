#define _GNU_SOURCE
#include "ubbd_uio.h"
#include "ubbd_backend.h"

#define FILE_BACKEND(ubbd_b) ((struct ubbd_file_backend *)container_of(ubbd_b, struct ubbd_file_backend, ubbd_b))

struct ubbd_backend_ops file_backend_ops;

static struct ubbd_backend *file_backend_create(struct __ubbd_dev_info *info)
{
	struct ubbd_backend *ubbd_b;
	struct ubbd_file_backend *file_backend;

	file_backend = calloc(1, sizeof(*file_backend));
	if (!file_backend)
		return NULL;

	ubbd_b = &file_backend->ubbd_b;
	ubbd_b->dev_type = UBBD_DEV_TYPE_FILE;
	ubbd_b->backend_ops = &file_backend_ops;
	strcpy(file_backend->filepath, info->file.path);

	return ubbd_b;
}

static int file_backend_open(struct ubbd_backend *ubbd_b)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);
	int ret;

	ret = ubbd_util_get_file_size(file_b->filepath, &ubbd_b->dev_size);
	if (ret)
		return ret;

	file_b->fd = open(file_b->filepath, O_RDWR | O_DIRECT);
	if (file_b->fd < 0) {
		return file_b->fd;
	}

	return 0;
}

static void file_backend_close(struct ubbd_backend *ubbd_b)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);

	close(file_b->fd);
}

static void file_backend_release(struct ubbd_backend *ubbd_b)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);
	if (file_b)
		free(file_b);
}

static int file_backend_writev(struct ubbd_backend *ubbd_b, struct ubbd_backend_io *io)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);
	ssize_t ret;

	ret = pwritev(file_b->fd, io->iov, io->iov_cnt, io->offset);
	if (ret < 0)
		ubbd_err("result of pwritev: %ld\n", ret);
	ubbd_backend_io_finish(io, (ret == io->len? 0 : ret));

	return 0;
}

static int file_backend_readv(struct ubbd_backend *ubbd_b, struct ubbd_backend_io *io)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);
	ssize_t ret;

	ret = preadv(file_b->fd, io->iov, io->iov_cnt, io->offset);
	if (ret < 0)
		ubbd_err("result of preadv: %ld\n", ret);
	ubbd_backend_io_finish(io, (ret == io->len? 0 : ret));
	
	return 0;
}

static int file_backend_flush(struct ubbd_backend *ubbd_b, struct ubbd_backend_io *io)
{
	struct ubbd_file_backend *file_b = FILE_BACKEND(ubbd_b);
	int ret;

	ret = fsync(file_b->fd);
	ubbd_backend_io_finish(io, ret);

	return 0;
}

struct ubbd_backend_ops file_backend_ops = {
	.create = file_backend_create,
	.open = file_backend_open,
	.close = file_backend_close,
	.release = file_backend_release,
	.writev = file_backend_writev,
	.readv = file_backend_readv,
	.flush = file_backend_flush,
};
