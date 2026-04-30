import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from app.routes import districts, yield_data, risk_map, ai_advise, stats

load_dotenv()

app = FastAPI(
    title='CropSense API',
    description='Pakistan Smart Farm Intelligence Platform',
    version='1.0.0',
)

origins = os.getenv('CORS_ORIGINS', 'http://localhost:8080').split(',')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

app.include_router(districts.router, prefix='/api')
app.include_router(yield_data.router, prefix='/api')
app.include_router(risk_map.router, prefix='/api')
app.include_router(ai_advise.router, prefix='/api')
app.include_router(stats.router, prefix='/api')

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
    return {'status': 'healthy'}
