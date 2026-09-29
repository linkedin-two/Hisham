"""Helpers for secure file URL generation (local media vs private S3)."""

import logging

from django.conf import settings

logger = logging.getLogger(__name__)

DEFAULT_PRESIGNED_EXPIRY = int(getattr(settings, 'AWS_PRESIGNED_URL_EXPIRY', 3600))


def get_file_access_url(file_field, request=None, expires=None):
    """
    Return a URL suitable for client access to an uploaded file.

    - Local/dev: absolute URI via request when available, else relative .url
    - Private S3: time-limited presigned URL
    - Public S3 (legacy): direct .url
    """
    if not file_field:
        return ''

    expires = expires or DEFAULT_PRESIGNED_EXPIRY

    use_s3 = getattr(settings, 'USE_S3', False)
    is_private = use_s3 and getattr(settings, 'AWS_QUERYSTRING_AUTH', False)

    try:
        if use_s3 and is_private:
            import boto3
            from botocore.exceptions import ClientError

            client = boto3.client(
                's3',
                region_name=getattr(settings, 'AWS_S3_REGION_NAME', 'us-east-1'),
                aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', None),
                aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', None),
            )
            bucket = getattr(settings, 'AWS_STORAGE_BUCKET_NAME', '')
            key = file_field.name
            location = getattr(settings, 'AWS_LOCATION', '')
            if location and not key.startswith(f'{location}/'):
                key = f'{location}/{key.lstrip("/")}'

            return client.generate_presigned_url(
                'get_object',
                Params={'Bucket': bucket, 'Key': key},
                ExpiresIn=expires,
            )

        relative_url = file_field.url
        if relative_url.startswith(('http://', 'https://', '//')):
            return relative_url
        if request is not None:
            # Keep leading slash so build_absolute_uri resolves from site root,
            # not from the current API path (e.g. /api/messages).
            if not relative_url.startswith('/'):
                relative_url = f'/{relative_url.lstrip("/")}'
            return request.build_absolute_uri(relative_url)
        return relative_url
    except Exception:
        logger.exception('Failed to build file access URL')
        try:
            return file_field.url
        except Exception:
            return ''
