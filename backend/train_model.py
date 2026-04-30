# train_model.py
# Trains a Random Forest model on mock Pakistan crop data
# Saves the model to app/models/ for the predictor service to use

import numpy as np
import joblib
import os
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error

os.makedirs('app/models', exist_ok=True)

print('Generating training data...')

# Generate realistic Pakistan crop yield data
np.random.seed(42)
n = 1000

ndvi = np.random.uniform(0.2, 0.9, n)
rainfall = np.random.uniform(30, 500, n)
temp_max = np.random.uniform(25, 48, n)
soil_moisture = np.random.uniform(15, 75, n)
year = np.random.randint(2005, 2024, n)

# Yield formula based on agronomic relationships
yield_base = (
    2.0
    + ndvi * 2.5
    + rainfall * 0.003
    - (temp_max - 35) * 0.08
    + soil_moisture * 0.02
    + (year - 2005) * 0.04
    + np.random.normal(0, 0.2, n)
)
yield_t_acre = np.clip(yield_base, 0.5, 4.5)

X = np.column_stack([ndvi, rainfall, temp_max, soil_moisture, year])
y = yield_t_acre

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train Random Forest
print('Training Random Forest...')
rf = RandomForestRegressor(
    n_estimators=100,
    max_depth=8,
    random_state=42,
    n_jobs=-1
)
rf.fit(X_train_scaled, y_train)
rf_pred = rf.predict(X_test_scaled)
rf_r2 = r2_score(y_test, rf_pred)
rf_rmse = mean_squared_error(y_test, rf_pred, squared=False)
print(f'Random Forest — R²: {rf_r2:.3f}, RMSE: {rf_rmse:.3f}')

# Train Linear Regression
print('Training Linear Regression...')
lr = LinearRegression()
lr.fit(X_train_scaled, y_train)
lr_pred = lr.predict(X_test_scaled)
lr_r2 = r2_score(y_test, lr_pred)
lr_rmse = mean_squared_error(y_test, lr_pred, squared=False)
print(f'Linear Regression — R²: {lr_r2:.3f}, RMSE: {lr_rmse:.3f}')

# Save models and scaler
joblib.dump(rf, 'app/models/rf_model.pkl')
joblib.dump(lr, 'app/models/regression.pkl')
joblib.dump(scaler, 'app/models/scaler.pkl')

print('\nModels saved to app/models/')
print('Training complete!')