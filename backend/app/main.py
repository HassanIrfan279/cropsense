import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from app.database import database_config_summary, init_db

load_dotenv()

logging.basicConfig(level=logging.INFO)
log = logging.getLogger('cropsense')

app = FastAPI(
    title='CropSense API',
    description='Pakistan Smart Farm Intelligence Platform',
    version='1.0.0',
)

_PRODUCTION_FRONTEND_ORIGIN = 'https://cropsensebyhassan.netlify.app'
_LOCAL_DEV_ORIGINS = [
    'http://localhost',
    'http://localhost:8080',
    'http://localhost:5000',
    'http://localhost:5173',
    'http://localhost:8000',
    'http://127.0.0.1',
    'http://127.0.0.1:8080',
    'http://127.0.0.1:5173',
    'http://127.0.0.1:8000',
]


def _is_production_runtime() -> bool:
    env_name = os.getenv('APP_ENV') or os.getenv('ENVIRONMENT') or ''
    return (
        os.getenv('RENDER', '').lower() == 'true'
        or env_name.lower() in {'production', 'prod'}
    )


_CORS_ORIGINS = []
for _origin in os.getenv('CORS_ORIGINS', '').split(','):
    _origin = _origin.strip()
    if _origin and _origin not in _CORS_ORIGINS:
        _CORS_ORIGINS.append(_origin)

if _PRODUCTION_FRONTEND_ORIGIN not in _CORS_ORIGINS:
    _CORS_ORIGINS.append(_PRODUCTION_FRONTEND_ORIGIN)

if not _is_production_runtime():
    for _origin in _LOCAL_DEV_ORIGINS:
        if _origin not in _CORS_ORIGINS:
            _CORS_ORIGINS.append(_origin)

_CORS_ALLOW_ALL = os.getenv('CORS_ALLOW_ALL', 'false').lower() == 'true'
_LOCALHOST_REGEX = (
    None if _is_production_runtime() else r'https?://(localhost|127\.0\.0\.1)(:\d+)?'
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'] if _CORS_ALLOW_ALL else _CORS_ORIGINS,
    allow_origin_regex=None if _CORS_ALLOW_ALL else _LOCALHOST_REGEX,
    allow_credentials=False,       # Bearer tokens in headers, not cookies
    allow_methods=['*'],
    allow_headers=['*'],
    expose_headers=['*'],
)

log.info(
    'CORS configured: allow_all=%s origins=%s local_regex=%s',
    _CORS_ALLOW_ALL,
    _CORS_ORIGINS,
    bool(_LOCALHOST_REGEX),
)

# ── Route registration ────────────────────────────────────────────────────────
# Each route is wrapped in try/except so one broken module never kills startup.

_ROUTES = [
    ('app.routes.districts',   'districts'),
    ('app.routes.yield_data',  'yield_data'),
    ('app.routes.risk_map',    'risk_map'),
    ('app.routes.ai_advise',   'ai_advise'),
    ('app.routes.stats',       'stats'),
    ('app.routes.weather',     'weather'),
    ('app.routes.comparison',  'comparison'),
    ('app.routes.analytics',   'analytics'),
    ('app.routes.future_prediction', 'future_prediction'),
    ('app.routes.auth',        'auth'),
    ('app.routes.field_management', 'field_management'),
]

for _module_path, _name in _ROUTES:
    try:
        import importlib
        _mod = importlib.import_module(_module_path)
        app.include_router(_mod.router, prefix='/api')
        log.info('Route loaded: %s', _name)
    except Exception as _e:
        log.error('Route FAILED to load: %s — %s', _name, _e)

@app.on_event('startup')
async def startup():
    try:
        db_summary = database_config_summary()
        log.info(
            'Database config: mode=%s target=%s',
            db_summary['mode'],
            db_summary['target'],
        )
        if init_db():
            log.info('Database tables checked/created')
        else:
            log.warning('Database not configured; protected farmer data APIs will return 503')
    except Exception as exc:
        log.error('Database initialization failed: %s', exc)


@app.get('/')
async def root():
    return {
        'app': 'CropSense API',
        'version': '1.0.0',
        'status': 'running',
        'docs': '/docs',
    }


@app.get('/health')
async def health():
    return {'status': 'ok'}


@app.get('/api/health')
async def api_health():
    return {'status': 'ok'}
