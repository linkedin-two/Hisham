# Gunicorn configuration for Render.com free plan (512MB RAM, 1 vCPU)
import multiprocessing

# Server socket — overridden by --bind in render.yaml startCommand
bind = "0.0.0.0:8000"
backlog = 64

# Worker processes — 2 is the safe ceiling for Render's 512MB plan
workers = 2
worker_class = "sync"
worker_connections = 100
timeout = 30
keepalive = 2

# Memory management
max_requests = 500
max_requests_jitter = 50

# Server mechanics
preload_app = True
loglevel = "info"
accesslog = "-"  # Log to stdout (Render captures this)
errorlog = "-"   # Log to stderr (Render captures this)

# Process naming
proc_name = 'edzkool_gunicorn'

# NOTE: proxy_protocol must NOT be set to True on Render.com.
# Render uses standard HTTP proxying — not HAProxy PROXY protocol.
# Setting proxy_protocol=True causes Gunicorn to silently drop all connections.
