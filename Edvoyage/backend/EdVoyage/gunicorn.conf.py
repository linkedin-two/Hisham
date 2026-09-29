# Gunicorn configuration for 1-core 1GB VPS
import multiprocessing

# Server socket
bind = "127.0.0.1:8000"
backlog = 64  # Reduced for small VPS

# Worker processes
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
accesslog = "-" # Log to stdout
errorlog = "-"  # Log to stderr

# Process naming
proc_name = 'edvoyage_gunicorn'
