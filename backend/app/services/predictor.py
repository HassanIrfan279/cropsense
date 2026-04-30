# predictor.py
# Loads trained ML models and makes yield predictions

import joblib
import numpy as np
import os

MODEL_DIR = os.path.join(os.path.dirname(__file__), '..', 'models')

_rf = None
_lr = None
_scaler = None

def _load_models():
    global _rf, _lr, _scaler
    try:
        _rf = joblib.load(os.path.join(MODEL_DIR, 'rf_model.pkl'))
        _lr = joblib.load(os.path.join(MODEL_DIR, 'regression.pkl'))
        _scaler = joblib.load(os.path.join(MODEL_DIR, 'scaler.pkl'))
        return True
    except Exception as e:
        print(f'Model load failed: {e}')
        return False

def predict_yield(
    ndvi: float,
    rainfall_mm: float,
    temp_max_c: float,
    soil_moisture_pct: float,
    year: int = 2024,
) -> dict:
    if _rf is None:
        _load_models()

    features = np.array([[ndvi, rainfall_mm, temp_max_c,
                           soil_moisture_pct, year]])

    if _scaler is not None:
        features_scaled = _scaler.transform(features)
    else:
        features_scaled = features

    if _rf is not None:
        predicted = float(_rf.predict(features_scaled)[0])
    else:
        # Fallback formula if model not loaded
        predicted = (1.8 + ndvi * 1.2
                     + rainfall_mm * 0.002
                     - (temp_max_c - 35) * 0.05)

    predicted = round(max(0.5, min(4.5, predicted)), 2)
    ci_range = 0.25

    return {
        'predictedYield': predicted,
        'confidenceLow': round(predicted - ci_range, 2),
        'confidenceHigh': round(predicted + ci_range, 2),
        'modelUsed': 'RandomForest' if _rf is not None else 'formula',
    }